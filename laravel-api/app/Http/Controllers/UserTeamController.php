<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\UserTeamLink;
use App\Models\Invitation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class UserTeamController extends Controller
{
    /**
     * Créer une nouvelle équipe et définir l'utilisateur connecté comme capitaine
     */
    public function createTeam(Request $request)
    {

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:teams',
            'sport_id' => 'required|exists:sports,id',
            'image' => 'nullable|string|regex:/^data:image\/[^;]+;base64,/',
        ]);

        // Vérifier si l'utilisateur est déjà capitaine d'une équipe du même sport
        $existingTeam = UserTeamLink::where('user_id', Auth::id())
            ->where('is_captain', true)
            ->where('has_left_team', false)
            ->whereHas('team', function ($query) use ($request) {
                $query->where('sport_id', $request->sport_id);
            })
            ->first();

        if ($existingTeam) {
            return response()->json([
                'message' => 'Vous êtes déjà capitaine d\'une équipe de ce sport',
                'team' => $existingTeam->team
            ], 400);
        }

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Sauvegarder l'image si elle existe
        $imageUrl = null;
        if ($request->image) {
            $imageUrl = $this->saveImage($request->image);
        }

        // Créer l'équipe avec les champs fillable
        $team = Team::create([
            'name' => $request->name,
            'sport_id' => $request->sport_id,
            'total_score' => 0,
            'image' => $imageUrl,
            'average_rating' => 0.0,
        ]);

        // Créer le lien entre l'utilisateur et l'équipe avec le statut de capitaine
        UserTeamLink::create([
            'user_id' => Auth::id(),
            'team_id' => $team->id,
            'start_date' => now(),
            'end_date' => null,
            'has_left_team' => false,
            'leave_reason' => null,
            'is_captain' => true,
        ]);


        return response()->json([
            'message' => 'Team created successfully',
            'team' => $team->load(['userTeamLinks.user', 'sport'])
        ], 201);
    }


    /**
     * Enregistrer une image à partir d'une chaîne Base64
     */
    private function saveImage($base64Image)
    {
        try {
            // Extraire le type MIME et les données de l'image
            list($type, $data) = explode(';', $base64Image);
            list(, $data) = explode(',', $data);
            list(, $type) = explode(':', $type);
            list(, $extension) = explode('/', $type);

            // Générer un nom de fichier unique
            $filename = 'team_' . time() . '_' . uniqid() . '.' . $extension;
            
            // Décoder et sauvegarder l'image
            $decodedImage = base64_decode($data);
            
            // Sauvegarder dans storage/app/public/team_images
            Storage::disk('public')->put('team_images/' . $filename, $decodedImage);
            
            // Retourner le chemin relatif de l'image (sans APP_URL)
            return '/storage/team_images/' . $filename;
        } catch (\Exception $e) {
            \Log::error('Error saving image: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Récupérer les membres d'une équipe
     */
    public function getTeamMembers($teamId)
    {
        $team = Team::findOrFail($teamId);
        
        // Récupérer tous les membres de l'équipe qui n'ont pas quitté
        $teamMembers = UserTeamLink::where('team_id', $teamId)
            ->where('has_left_team', false)
            ->with([
                'user:id,username,email,profile_picture',
                'team:id,name,image,total_score,average_rating,sport_id',
                'team.sport:id,name,max_players'
            ])
            ->get();

        return response()->json([
            'team_members' => $teamMembers
        ]);
    }


    /**
     * Méthode pour faire le disband d'une équipe
     */
    public function disbandTeam($teamId)
    {
        $team = Team::findOrFail($teamId);

        // Vérifier si l'utilisateur connecté est le capitaine de l'équipe
        $userTeamLink = $team->userTeamLinks()
            ->where('user_id', Auth::id())
            ->where('is_captain', true)
            ->where('has_left_team', false)
            ->first();

        if (!$userTeamLink) {
            return response()->json([
                'message' => 'Vous devez être le capitaine de cette équipe pour la dissoudre'
            ], 403);
        }

        // Marquer tous les membres comme ayant quitté l'équipe
        $team->userTeamLinks()->update([
            'has_left_team' => true, 
            'leave_reason' => 'Team disbanded',
            'end_date' => now()
        ]);

        // Debug: Vérifier les invitations avant suppression
        $invitationsToDelete = Invitation::where('invitable_type', Team::class)
                  ->where('invitable_id', $team->id)
                  ->get();
        
        \Log::info("Found {$invitationsToDelete->count()} invitations to delete for team {$team->id}");
        
        // Supprimer toutes les invitations liées à cette équipe
        $deletedInvitations = Invitation::where('invitable_type', Team::class)
                  ->where('invitable_id', $team->id)
                  ->delete();
        
        \Log::info("Disbanded team {$team->id}: Deleted {$deletedInvitations} invitations");

        // NE PAS supprimer l'équipe pour qu'elle reste dans l'historique
        // L'équipe est maintenant "inactive" car tous les membres l'ont quittée

        return response()->json([
            'message' => 'L\'équipe a été dissoute avec succès'
        ]);
    }


    /**
     * Méthode pour getter les historique des teams d'un utilisateur
     */
    public function getUserTeamHistory()
    {
        $userId = Auth::id();

        // Récupérer TOUTES les équipes de l'utilisateur (actuelles et passées)
        $teams = UserTeamLink::where('user_id', $userId)
            ->with(['team.sport', 'user'])
            ->get();

        // Retourner les données complètes des UserTeamLink avec leurs équipes
        return response()->json([
            'team_history' => $teams
        ]);
    }

    /**
     * Récupérer tous les membres d'une équipe (y compris les équipes dissoutes)
     */
    public function getAllTeamMembers($teamId)
    {
        // Vérifier que l'équipe existe
        $team = Team::find($teamId);
        if (!$team) {
            return response()->json([
                'message' => 'Équipe introuvable'
            ], 404);
        }

        // Vérifier que l'utilisateur actuel fait ou faisait partie de cette équipe
        $userTeamLink = UserTeamLink::where('user_id', Auth::id())
            ->where('team_id', $teamId)
            ->first();

        if (!$userTeamLink) {
            return response()->json([
                'message' => 'Vous n\'avez pas accès à cette équipe'
            ], 403);
        }

        // Récupérer TOUS les membres de l'équipe (actuels et anciens)
        $teamMembers = UserTeamLink::where('team_id', $teamId)
            ->with(['user', 'team.sport'])
            ->get();

        return response()->json([
            'team_members' => $teamMembers
        ]);
    }

    /**
     * Nettoyer les invitations orphelines (équipes qui n'existent plus)
     */
    public function cleanupOrphanedInvitations()
    {
        // Supprimer les invitations pour des équipes qui n'existent plus
        $orphanedInvitations = Invitation::where('invitable_type', Team::class)
            ->whereNotIn('invitable_id', Team::pluck('id'))
            ->delete();
        
        \Log::info("Cleaned up {$orphanedInvitations} orphaned team invitations");
        
        return response()->json([
            'message' => "Nettoyage terminé: {$orphanedInvitations} invitations orphelines supprimées"
        ]);
    }

}

