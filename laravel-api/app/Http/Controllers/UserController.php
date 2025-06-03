<?php
namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Invitation;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function search(Request $request): JsonResponse
    {
        $query = $request->query('query');

        if (empty($query)) {
            return response()->json([
                'data' => [],
                'message' => 'Query parameter is required'
            ], 400);
        }

        $users = User::where('username', 'like', "%{$query}%")
            ->orWhere('email', 'like', "%{$query}%")
            ->select('id', 'username', 'email', 'profile_picture')
            ->limit(10)
            ->get();;

        return response()->json($users);
    }

   public function index(): JsonResponse
{
    $users = User::select('id', 'username', 'email', 'profile_picture')->get();

    return response()->json([
        'users' => $users
    ], 200);
}

    public function getProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'avatar' => $user->avatar,
            'cover' => $user->cover,
        ]);
    }

    public function getAvailableUsers(Request $request): JsonResponse
{
    $currentUser = $request->user();

    // Get all user IDs that have any invitation relationship with current user
    $excludedUserIds = Invitation::where(function ($query) use ($currentUser) {
        $query->where('sender_id', $currentUser->id)
              ->orWhere('receiver_id', $currentUser->id);
    })
    ->where('type', 'friend') // Only check friend invitations
    ->get()
    ->map(function ($invitation) use ($currentUser) {
        // Return the other user's ID (not the current user's ID)
        return $invitation->sender_id === $currentUser->id 
            ? $invitation->receiver_id 
            : $invitation->sender_id;
    })
    ->unique();

    $users = User::whereNotIn('id', $excludedUserIds)
                 ->where('id', '!=', $currentUser->id)
                 ->select('id', 'username', 'email', 'profile_picture')
                 ->get();

    return response()->json($users);
}

// get friends of the user
    public function getFriends(Request $request): JsonResponse
    {
        $currentUser = $request->user();

        // Get all friends of the current user
        $friends = Invitation::where(function ($query) use ($currentUser) {
            $query->where('sender_id', $currentUser->id)
                  ->orWhere('receiver_id', $currentUser->id);
        })
        ->where('type', 'friend')
        ->where('status', 'accepted')
        ->with(['sender:id,username,email,profile_picture', 'receiver:id,username,email,profile_picture'])
        ->get()
        ->map(function ($invitation) use ($currentUser) {
            return $invitation->sender_id === $currentUser->id 
                ? $invitation->receiver 
                : $invitation->sender;
        });

        return response()->json($friends);
    }
}