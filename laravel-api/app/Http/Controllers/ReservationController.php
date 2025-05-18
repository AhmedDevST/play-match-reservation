<?php

namespace App\Http\Controllers;

use App\Models\Sport;
use App\Models\SportFacility;
use App\Http\Resources\SportResource;
use App\Http\Resources\SportFacilityResource;
use Illuminate\Http\Request;

class ReservationController extends Controller
{
    public function index() {}
    public function init(Request $request)
    {
        $sports = Sport::all();
        $defaultSport = Sport::where('id', 1)->first();
        $sportFacilites = [];
        if ($defaultSport) {
            $sportFacilites = $defaultSport->sportFacilities->load('images');
        }
        return response()->json([
            'sports' => SportResource::collection($sports),
            'defaultSport' => new SportResource($defaultSport),
            'sportFacilites' => SportFacilityResource::collection($sportFacilites),
        ]);
    }
}
