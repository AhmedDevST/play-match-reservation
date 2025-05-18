<?php

namespace App\Http\Controllers;

use App\Http\Resources\SportFacilityResource;
use App\Models\Sport;
use App\Models\SportFacility;
use Illuminate\Http\Request;

class SportFacilityController extends Controller
{
    public function index(Request $request)
    {
        $sport = Sport::find($request->sport_id);
        $sportFacilites = [];
        if ($sport) {
            $sportFacilites = $sport->sportFacilities->load('images');
        }
        return response()->json([
            'sportFacilites' => SportFacilityResource::collection($sportFacilites),
        ]);
    }
}
