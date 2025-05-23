<?php

namespace App\Http\Controllers;

use App\Http\Resources\TeamResource;
use App\Models\Team;
use Illuminate\Http\Request;

class TeamController extends Controller
{
    public function search(Request $request)
    {
        //update serach to serach team that have the same sport as the user captain based on seletion team sport it will be in request
        $search = $request->input('q');

        $teams = Team::where('name', 'like', '%' . $search . '%')
            ->limit(10)
            ->get();

        return response()->json(
            [
                'teams' => TeamResource::collection($teams),
            ]
        );
    }
}
