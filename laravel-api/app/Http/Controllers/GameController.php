<?php

namespace App\Http\Controllers;

use App\Http\Resources\GameResource;
use App\Http\Resources\SportFacilityResource;
use App\Http\Resources\TeamResource;
use App\Http\Resources\TimeSlotInstanceResource;
use App\Models\Game;
use App\Models\SportFacility;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class GameController extends Controller
{


    public function initGame(Request $request, $facilityId)
    {
        // Step 1: Check if the user is authenticated
        $user = Auth::user();
        if (!$user) {
            return response()->json([
                'message' => 'User not authenticated.',
                'success' => false,
            ], 401);
        }

        $sports = SportFacility::find($facilityId)->sports;
        $sportIds = $sports->pluck('id');

        $userTeams = $user->userTeamLinks
            ->where('is_captain', true)
            ->where('has_left_team', false)
            ->map(function ($link) use ($sportIds) {
                $team = $link->team()->with('sport')->first();
                return $team && $sportIds->contains($team->sport_id) ? $team : null;
            })
            ->filter();

        return response()->json([
            'user_teams' => TeamResource::collection($userTeams),
        ]);
    }

    public function show($gameId)
    {
        $game = Game::with(['teamMatches.team.players', 'teamMatches.team.sport', 'reservation.TimeSlotInstance.recurringTimeSlot.sportFacility'])->findOrFail($gameId);
        return response()->json([
            'game' => new GameResource($game),
            'facility' => new SportFacilityResource($game->reservation->timeSlotInstance->recurringTimeSlot->sportFacility),
            'time_slot' => new TimeSlotInstanceResource($game->reservation->timeSlotInstance),
        ]);
    }

    public function getPublicPendingMatches()
    {
        try {
            $matches = Game::publicPendingMatches()
                ->with([
                    'teamMatches.team.players',
                    'teamMatches.team.sport',
                    'reservation.TimeSlotInstance.recurringTimeSlot.sportFacility'
                ])
                ->orderBy('created_at', 'desc')
                ->get();

            //ajouter invitation objet au collection
            // get user auth
            // get invitation de user auth et match id if exist
            //use new resource : public match (match + invitation asscoie if exist)
            return response()->json([
                'matches' => GameResource::collection($matches),
                'message' => 'Public pending matches retrieved successfully',
                'success' => true
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to retrieve public pending matches',
                'success' => false
            ], 500);
        }
    }
}
