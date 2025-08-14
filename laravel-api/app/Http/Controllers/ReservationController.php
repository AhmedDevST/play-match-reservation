<?php

namespace App\Http\Controllers;

use App\Helpers\ApiResponse;
use App\Http\Requests\CreateReservationRequest;
use App\Http\Resources\ReservationResource;
use App\Models\Sport;
use App\Http\Resources\SportResource;
use App\Http\Resources\SportFacilityResource;
use App\Models\Reservation;
use App\Services\MatchReservationService;
use App\Services\ReservationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReservationController extends Controller
{
    public function __construct(
        private ReservationService $reservationService,
        private MatchReservationService $matchReservationService
    ) {}

    public function getUserReservations()
    {
        $userId = Auth::user()->id ?? null;
        $reservations = Reservation::with([
            'TimeSlotInstance.recurringTimeSlot.sportFacility',
            'user',
            'game.teamMatches.team.players',
            'game.teamMatches.team.sport',
        ])->where('user_id', $userId)->get();
        return  ApiResponse::success(ReservationResource::collection($reservations), 'User reservations retrieved successfully.', 200);
    }

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

    public function store(CreateReservationRequest $request)
    {
        $userId = Auth::user()->id ?? null;
        $data = $request->validated();
        $reservation = null;
        if ($request->is_match) {
            $reservation = $this->matchReservationService->createMatchReservation($data, $userId);
        } else {
            $reservation = $this->reservationService->createSimpleReservation($data, $userId);
        }
        return response()->json([
            'message' => 'Reservation created successfully.',
            'success' => true,
            'data' => $reservation
        ], 201);
    }
}
