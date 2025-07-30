<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use Illuminate\Http\Request;
use App\Enums\InvitationStatus;
use App\Enums\TypeInvitation;
use App\Models\Game;
use App\Models\User;
use Illuminate\Validation\Rules\Enum;
use Illuminate\Support\Facades\Auth;

use App\Enums\NotificationType;
use App\Exceptions\ValidationException;
use App\Models\Team;
use App\Services\FacilityValidationService;
use App\Services\InvitationService;
use App\Services\NotificationService;
use App\Services\TeamValidationService;

class InvitationController extends Controller
{

    public function __construct(
        private TeamValidationService $teamValidator,
        private InvitationService $invitationService,
        private NotificationService $notificationService,
    ) {}
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:accepted,rejected',
        ]);

        try {
            $invitation = Invitation::find($id);

            if (!$invitation) {
                return response()->json([
                    'message' => 'Invitation not found.',
                    'success' => false,
                ], 404);
            }
            $invitation->status = InvitationStatus::from($request->status);
            $invitation->save();

            return response()->json([
                'message' => 'Invitation status updated successfully',
                'success' => true,
            ]);
        } catch (\Exception $e) {

            return response()->json([
                'message' => 'failed.',
                'success' => false,
            ], 500);
        }
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => ['required', new Enum(TypeInvitation::class)],
            'invitable_id' => ['nullable', 'integer'],
            'sender_id' => ['required', 'integer', 'exists:users,id'],
            'receiver_id' => ['required', 'integer', 'exists:users,id'],
        ]);
        //test invitation is not duplicat
        try {
            $type = TypeInvitation::from($validated['type']);
            if ($type === TypeInvitation::MATCH) {
                return $this->handleMatchInvitation($validated);
            }
            // Handle other invitation types
            return $this->handleGeneralInvitation($validated);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to send invitation.',
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function sendFriendInvitation(Request $request)
    {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
        ]);

        $sender = Auth::user();
        $receiver = User::find($request->receiver_id);

        // Check if an invitation already exists
        $existingInvitation = Invitation::where('sender_id', $sender->id)
            ->where('receiver_id', $receiver->id)
            ->where('type', 'friend')
            ->first();

        if ($existingInvitation) {
            return response()->json(['message' => 'Invitation already sent.'], 400);
        }

        // Create a new invitation
        $invitation = Invitation::create([
            'sender_id' => $sender->id,
            'receiver_id' => $receiver->id,
            'type' => 'friend',
            'status' => 'pending',
        ]);
        $notificationController = new \App\Http\Controllers\NotificationController();
        $notificationController->create(
            $request->receiver_id,
            NotificationType::INVITATION_NOTIFICATION,
            "Invitation d'ami",
            "Vous avez reçu une invitation  de {$sender->username} pour rejoindre votre réseau",
            //  $team->id,
            //  Team::class
            $invitation->id,
            Invitation::class
        );

        return response()->json(['message' => 'Invitation sent successfully.', 'invitation' => $invitation], 201);
    }

    public function handleGeneralInvitation(array $validated)
    {
        $invitation = $this->invitationService->createInvitation($validated['type'], $validated['sender_id'], $validated['receiver_id'], $validated['invitable_id']);
        if ($invitation) {
            return response()->json([
                'message' => 'Invitation sent successfully.',
                'success' => true,
            ], 201);
        }
    }
    public function handleMatchInvitation(array $validated)
    {
        $game = Game::findOrFail($validated['invitable_id']);
        $sender = User::findOrFail($validated['sender_id']);
        $receiver = User::findOrFail($validated['receiver_id']);

        // Get receiver's team from the match
        $receiverTeam = $this->invitationService->getReceiverTeamFromMatch($game, $receiver);
        if (!$receiverTeam) {
            return response()->json([
                'message' => 'Receiver is not part of any team in this match.',
                'success' => false,
            ], 403);
        }
        // Get sender's captain team in the same sport as receiver's team
        $senderTeam = $this->invitationService->getSenderCaptainTeamInSameSport($sender, $receiverTeam->sport_id);
        if (!$senderTeam) {
            return response()->json([
                'message' => 'You must be a captain of a team in the same sport to send this invitation.',
                'success' => false,
            ], 403);
        }
        // Check if sender's team has enough players
        $errors = $this->teamValidator->validateTeamPlayerCount($senderTeam, 'team1');
        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
        $invitation = $this->invitationService->createInvitation($validated['type'], $validated['sender_id'], $validated['receiver_id'], $validated['invitable_id']);
        if ($invitation) {
            $this->notificationService->create(
                $validated['sender_id'],
                NotificationType::INVITATION_NOTIFICATION,
                'Invitation de match',
                "Vous avez reçu une invitation pour le  match  contre {$senderTeam->name}.",
                $invitation->id,
                Invitation::class
            );
            return response()->json([
                'message' => 'Invitation sent successfully.',
                'success' => true,
            ], 201);
        }
    }
}
