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

    $excludedUserIds = Invitation::where(function ($query) use ($currentUser) {
        $query->where('sender_id', $currentUser->id)
              ->orWhere('receiver_id', $currentUser->id);
    })
    ->whereIn('status', ['pending', 'accepted']) // Exclude users with pending or accepted invitations
    ->pluck('sender_id', 'receiver_id')
    ->flatten()
    ->unique();

    $users = User::whereNotIn('id', $excludedUserIds)
                 ->where('id', '!=', $currentUser->id)
                 ->select('id', 'username', 'email', 'profile_picture')
                 ->get();

    return response()->json($users);
}
}