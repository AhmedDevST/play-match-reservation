<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use Illuminate\Http\Request;
use App\Enums\InvitationStatus;
use App\Enums\TypeInvitation;
use App\Models\Game;
use App\Models\User;
use Illuminate\Validation\Rules\Enum;

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

}
