<?php

namespace App\Http\Controllers;

use App\Models\Invitation;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class InvitationController extends Controller
{
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

        return response()->json(['message' => 'Invitation sent successfully.', 'invitation' => $invitation], 201);
    }
}
