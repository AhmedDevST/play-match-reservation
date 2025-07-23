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
use App\Services\FacilityValidationService;
use App\Services\NotificationService;
use App\Services\TeamValidationService;

class InvitationController extends Controller
{

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

        try {
            //ivitation of match
            //send should be  a captain of team of the sport of the same theam of reciever in match
            //test is captain of team
            //test the validation coutn players of the team sender
            $type = TypeInvitation::from($validated['type']);

            $invitableType = match ($type) {
                TypeInvitation::MATCH => \App\Models\Game::class,
                TypeInvitation::TEAM => \App\Models\Team::class,
                TypeInvitation::FRIEND => null,
            };

            $invitationData = [
                'type' => $type,
                'sender_id' => $validated['sender_id'],
                'receiver_id' => $validated['receiver_id'],
                'status' => InvitationStatus::PENDING,
            ];

            // Only set morph data if applicable
            if ($invitableType && !empty($validated['invitable_id'])) {
                $invitationData['invitable_type'] = $invitableType;
                $invitationData['invitable_id'] = $validated['invitable_id'];
            }


            $invitation = Invitation::create($invitationData);

            return response()->json([
                'message' => 'Invitation sent successfully.',
                'success' => true,
                'data' => $invitation
            ], 201);
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
}
