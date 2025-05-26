<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\UserTeamLink;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
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
            'image' => 'nullable|string',
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

        // Créer l'équipe avec les champs fillable
        $team = Team::create([
            'name' => $request->name,
            'total_score' => 0,
            'image' => $request->image,
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
     * Créer une nouvelle équipe pour l'utilisateur 1 (mode test)
     */
    public function createTeamTest(Request $request)
    {
        try {
            \Log::info('Creating test team with request:', ['data' => $request->all()]);
            
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255|unique:teams',
                'sport_id' => 'required|exists:sports,id',
                'image' => 'nullable|string',
            ]);

            // Vérifier si l'utilisateur est déjà capitaine d'une équipe du même sport
            $existingTeams = UserTeamLink::where('user_id', 1)
                ->where('is_captain', true)
                ->whereHas('team', function ($query) use ($request) {
                    $query->where('sport_id', $request->sport_id);
                })
                ->get();

            foreach ($existingTeams as $link) {
                // Si l'utilisateur a un lien actif (n'a pas quitté l'équipe)
                if (!$link->has_left_team) {
                    return response()->json([
                        'message' => 'Vous êtes déjà capitaine d\'une équipe active de ce sport',
                        'team' => $link->team
                    ], 400);
                }
            }

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Créer l'équipe avec les champs fillable
        $team = Team::create([
            'name' => $request->name,
            'sport_id' => $request->sport_id,  // Ajout du sport_id ici
            'total_score' => 0,
            'image' => $request->image,
            'average_rating' => 0.0,
        ]);

        try {
            // Créer le lien avec l'utilisateur 1
            UserTeamLink::create([
                'user_id' => 1, // Toujours utiliser l'utilisateur 1 pour les tests
                'team_id' => $team->id,
                'start_date' => now(),
                'end_date' => null,
                'has_left_team' => false,
                'leave_reason' => null,
                'is_captain' => true,
            ]);

            // Load sport relationship and UserTeamLink
            $team->load(['sport', 'userTeamLinks']);

            \Log::info('Team created successfully:', ['team' => $team->toArray()]);
        } catch (\Exception $e) {
            \Log::error('Error creating team link:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            throw $e;
        }

        // Charger les relations nécessaires
        $team->load(['userTeamLinks.user', 'sport']);

        return response()->json([
            'message' => 'Team created successfully',
            'team' => $team
        ], 201);
    }
        catch (\Exception $e) {
            \Log::error('Error in createTeamTest:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur lors de la création de l\'équipe de test: ' . $e->getMessage()
            ], 500);
        }
    }

}

