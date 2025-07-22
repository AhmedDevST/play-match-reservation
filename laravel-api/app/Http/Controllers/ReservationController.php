<?php

namespace App\Http\Controllers;
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
        if (!$userId) {
            return response()->json([
                'message' => 'User not authenticated.',
                'success' => false,
            ], 401);
        }
        $reservations = Reservation::with([
            'TimeSlotInstance.recurringTimeSlot.sportFacility',
            'user',
            'game.teamMatches.team.players',
            'game.teamMatches.team.sport',
        ])->where('user_id', $userId)->get();


        return response()->json([
            'reservations' => ReservationResource::collection($reservations),
            'message' => 'User reservations retrieved successfully.',
            'success' => true,
        ]);
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
        if ($request->is_match) {
            return $this->createMatchReservation($request);
        }
        return $this->createSimpleReservation($request);
    }

    private function createSimpleReservation(CreateReservationRequest $request)
    {
        try {
            $reservation = $this->reservationService->createSimpleReservation(
                $request->validated(),
                $request->user()->id
            );
            return response()->json([
                'message' => 'Reservation created successfully.',
                'success' => true,
                'data' => ['reservation_id' => $reservation->id]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Reservation failed.',
                'success' => false,
            ], 500);
        }
    }
    private function createMatchReservation(CreateReservationRequest $request)
    {
        try {
            $result = $this->matchReservationService->createMatchReservation(
                $request->validated(),
                $request->user()->id
            );

            return response()->json([
                'message' => 'Match reservation created successfully.',
                'success' => true,
                'data' => $result
            ], 201);
        } catch (\App\Exceptions\ValidationException $e) {
            return response()->json([
                'errors' => $e->getErrors(),
                'success' => false,
                'message' => 'Business validation failed.'
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Match reservation failed.',
                'success' => false,
            ], 500);
        }
    }
}
