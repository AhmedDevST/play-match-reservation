<?php

namespace App\Http\Controllers;

use App\Http\Resources\TeamResource;
use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function search(Request $request)
    {
        $name = $request->input('name');
        $sportId = $request->input('sport');
        $limit = $request->input('limit', 10);
        $selectedTeamId = $request->input('exclude');

        $teams = Team::with('sport')
            ->when($name, fn($query) => $query->where('name', 'like', '%' . $name . '%'))
            ->when($sportId, fn($query) => $query->where('sport_id', $sportId))
            ->when($selectedTeamId, fn($query) => $query->where('id', '!=', $selectedTeamId))
            ->limit($limit)
            ->get();

        return response()->json(
            [
                'teams' => TeamResource::collection($teams),
            ]
        );
    }
}
