<?php

namespace App\Http\Controllers\Invitations;

use App\Http\Controllers\Controller;
use App\Models\Invitation;
use App\Models\Team;
use App\Models\User;
use App\Enums\TypeInvitation;
use App\Enums\InvitationStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TeamInvitationController extends Controller
{
    /**
     * Envoyer une invitation d'équipe
     */
    public function send(Request $request)
    {
        // Validation
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
        ]);

        // Vérifier si l'utilisateur est capitaine d'au moins une équipe
        // $isCaptain = Auth::user()->userTeamLinks()
        $isCaptain = User::find(1)->userTeamLinks()// Auth::user() pour plus de clarté
            ->where('is_captain', true)
            ->where('has_left_team', false)
            ->exists();

        if (!$isCaptain) {
            return response()->json([
                'message' => 'Vous devez être capitaine d\'une équipe pour envoyer des invitations'
            ], 403);
        }

        // Vérifier si une invitation est déjà en attente
        $existingInvitation = Invitation::where('sender_id', Auth::id())
            ->where('receiver_id', $request->receiver_id)
            ->where('type', TypeInvitation::TEAM)
            ->where('status', InvitationStatus::PENDING)
            ->first();

        if ($existingInvitation) {
            return response()->json([
                'message' => 'Une invitation est déjà en attente pour cet utilisateur'
            ], 400);
        }

        // Créer l'invitation
        $invitation = Invitation::create([
            // 'sender_id' => Auth::id(),
            'sender_id' => 1, // Utiliser Auth::user() pour plus de clarté
            'receiver_id' => $request->receiver_id,
            'type' => TypeInvitation::TEAM,
            'status' => InvitationStatus::PENDING
        ]);

        return response()->json([
            'message' => 'Invitation envoyée avec succès',
            'invitation' => $invitation->load(['sender', 'receiver'])
        ], 201);
    }

    /**
     * Recevoir les invitations d'équipe en attente
     */
    public function getPendingInvitations()
    {
        $invitations = Invitation::where('receiver_id', 2)// Auth::id() pour l'utilisateur connecté
            ->where('type', TypeInvitation::TEAM)
            ->where('status', InvitationStatus::PENDING)
            ->with(['sender', 'receiver'])
            ->get();

        return response()->json([
            'invitations' => $invitations
        ]);
    }

    /**
     * Répondre à une invitation d'équipe
     */
    public function respond(Request $request, Invitation $invitation)
    {
        // Validation
        $request->validate([
            'status' => 'required|in:accepted,rejected'
        ]);

        // Vérifier si l'utilisateur est bien le destinataire
        if ($invitation->receiver_id !== Auth::id()) {
            return response()->json([
                'message' => 'Non autorisé à répondre à cette invitation'
            ], 403);
        }

        // Vérifier si l'invitation est toujours en attente
        if ($invitation->status !== InvitationStatus::PENDING) {
            return response()->json([
                'message' => 'Cette invitation a déjà été traitée'
            ], 400);
        }

        $newStatus = InvitationStatus::from($request->status);
        $invitation->status = $newStatus;
        $invitation->save();

        if ($newStatus === InvitationStatus::ACCEPTED) {
            // Ajouter l'utilisateur à l'équipe du capitaine
            $team = Team::whereHas('userTeamLinks', function($query) use ($invitation) {
                $query->where('user_id', $invitation->sender_id)
                    ->where('is_captain', true);
            })->first();

            if ($team) {
                $team->userTeamLinks()->create([
                    'user_id' => Auth::id(),
                    'start_date' => now(),
                    'is_captain' => false,
                    'has_left_team' => false
                ]);
            }
        }

        return response()->json([
            'message' => 'Réponse enregistrée avec succès',
            'invitation' => $invitation->load(['sender', 'receiver'])
        ]);
    }

    /**
     * Get all invited users for a team
     */

    public function getInvitedUsers(Team $team)
    {
        // Vérifier si l'équipe existe
        if (!$team) {
            return response()->json([
                'message' => 'Équipe non trouvée'
            ], 404);
        }

        // Récupérer le capitaine de l'équipe
        $captain = $team->userTeamLinks()
            ->where('is_captain', true)
            ->first();

        if (!$captain) {
            return response()->json([
                'message' => 'Capitaine non trouvé pour cette équipe'
            ], 404);
        }

        // Récupérer les invitations en attente envoyées par le capitaine
        $invitedUsers = Invitation::where('sender_id', $captain->user_id)
            ->where('type', TypeInvitation::TEAM)
            ->where('status', InvitationStatus::PENDING)
            ->with('receiver')
            ->get();

        return response()->json([
            'invited_users' => $invitedUsers,
            'team' => $team->name
        ]);
    }


}