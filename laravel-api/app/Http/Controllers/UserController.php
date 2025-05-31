<?php
namespace App\Http\Controllers;

use App\Models\User;
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
}