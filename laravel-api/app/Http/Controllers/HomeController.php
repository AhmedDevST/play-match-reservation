<?php

namespace App\Http\Controllers;

use App\Http\Resources\PublicMatchResource;
use App\Services\GameService;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class HomeController extends Controller
{
    public function __construct(
        private GameService $gameService,
         private NotificationService $notificationService,
    ) {}
    public function index(Request $request)
    {
        // This method will return the data for home page
            $userId = Auth::id();
            // data for public pending matches
            $limit = $request->query('public_match_limit',4); // get ?limit=10 from URL, null if not provided
            $matches = $this->gameService->getPublicPendingMatches($userId, $limit);

            return response()->json([
                'matches' => PublicMatchResource::collection($matches),
                'notifications_count' => $this->notificationService->countNotifications($userId),
                'message' => 'Home Data retrieved successfully',
                'success' => true,
            ]);
    }
}
