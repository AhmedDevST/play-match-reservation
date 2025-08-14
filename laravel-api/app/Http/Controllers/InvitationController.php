<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use Illuminate\Http\Request;
use App\Enums\InvitationStatus;
use App\Enums\TypeInvitation;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

use App\Enums\NotificationType;
use App\Helpers\ApiResponse;
//use App\Exceptions\ValidationException;
use App\Http\Resources\InvitationResource;
use App\Services\InvitationService;
use App\Http\Requests\StoreInvitationRequest;

class InvitationController extends Controller
{

    public function __construct(
        private InvitationService $invitationService,
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

    public function store(StoreInvitationRequest $request)
    {
        $userId = Auth::user()->id ?? null;
        $validated = $request->validated();
        $validated['sender_id'] = $userId;
        $type = TypeInvitation::from($validated['type']);
        $invitation = null;
        if ($type === TypeInvitation::MATCH) {
            $invitation = $this->invitationService->handleMatchInvitation($validated);
        } else {
            $invitation = $this->invitationService->handleGeneralInvitation($validated);
        }
        return  ApiResponse::success(new InvitationResource($invitation), 'Invitation sent successfully', 201);
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
