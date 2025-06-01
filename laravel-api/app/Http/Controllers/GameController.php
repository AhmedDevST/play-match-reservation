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

class GameController extends Controller
{


    public function initGame(Request $request, $facilityId)
    {
        // $user = $request->user();
        $user = User::find(1);
        $sports = SportFacility::find($facilityId)->sports;
        $sportIds = $sports->pluck('id');
        $userTeams = $user->userTeamLinks()
            ->where('is_captain', true)
            ->where('has_left_team', false)
            ->get()
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
        $game = Game::with(['teamMatches.team.players','teamMatches.team.sport','reservation.TimeSlotInstance.recurringTimeSlot.sportFacility'])->findOrFail($gameId);
        return response()->json([
            'game' => new GameResource($game),
            'facility' => new SportFacilityResource($game->reservation->timeSlotInstance->recurringTimeSlot->sportFacility),
            'time_slot' => new TimeSlotInstanceResource($game->reservation->timeSlotInstance),
        ]);
    }
}
