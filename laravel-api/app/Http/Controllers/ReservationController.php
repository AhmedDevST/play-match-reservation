<?php

namespace App\Http\Controllers;

use App\Enums\InvitationStatus;
use App\Enums\MatchStatus;
use App\Enums\MatchType;
use App\Enums\ReservationStatus;
use App\Enums\TimeSlotsStatus;
use App\Enums\TypeInvitation;
use App\Http\Resources\ReservationResource;
use App\Models\Sport;
use Illuminate\Support\Facades\Validator;
use App\Http\Resources\SportResource;
use App\Http\Resources\SportFacilityResource;
use App\Models\Game;
use App\Models\Invitation;
use App\Models\Reservation;
use App\Models\Team;
use App\Models\TeamMatch;
use App\Models\TimeSlotInstance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;

class ReservationController extends Controller
{
    public function getUserReservations($userId)
    {
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




    public function store(Request $request)
    {
        if ($request->has('is_match') == false) {
            $validator = Validator::make($request->all(), [
                'time_slot_id' => [
                    'required',
                    Rule::exists('time_slot_instances', 'id')->where('status', 'available'),
                ],
                'user_id' => 'required|exists:users,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'errors' => $validator->errors()->all(),
                    'success' => false,
                    'message' => 'Validation failed.'
                ], 422);
            }

            $validated = $validator->validated();
            try {
                DB::beginTransaction();

                $reservation = Reservation::create([
                    'time_slot_instance_id' => $validated['time_slot_id'],
                    'user_id' => $validated['user_id'],
                    'date' => now(),
                    'total_price' => 0,
                    'status' => ReservationStatus::COMPLETED,
                ]);

                // Update the status of the time slot instance to reserved
                $timeSlotInstance = $reservation->TimeSlotInstance;
                $timeSlotInstance->status = TimeSlotsStatus::RESERVED;
                $timeSlotInstance->save();

                DB::commit();

                return response()->json([
                    'message' => 'Reservation created successfully.',
                    'success' => true,
                    //'reservation' => $reservation,
                ], 201);
            } catch (\Exception $e) {
                DB::rollBack();

                return response()->json([
                    'message' => 'Reservation failed.',
                    'success' => false,
                    //'error' => $e->getMessage(),
                ], 500);
            }
        } else {

            // Step 1: Basic Laravel validation
            $validator = Validator::make($request->all(), [
                'time_slot_id' => [
                    'required',
                    Rule::exists('time_slot_instances', 'id')->where('status', 'available'),
                ],
                'user_id' => 'required|exists:users,id',
                'auto_confirm' => 'boolean',
                'match_type' => ['required', new Enum(MatchType::class)],
                'team1_id' => 'required|exists:teams,id',
                'team2_id' => 'nullable|exists:teams,id',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'errors' => $validator->errors()->all(),
                    'success' => false,
                    'message' => 'Validation failed.'
                ], 422);
            }

            $validated = $validator->validated();
            // Step 2: Load models
            $matchType = $validated['match_type'];
            $team1 = Team::find($validated['team1_id']);
            $team2 = isset($validated['team2_id']) ? Team::find($validated['team2_id']) : null;
            $sport = $team1->sport;
            $errors = [];

            // Step 3: Business rule validation
            if (!$team1->captain) {
                $errors[] = 'Team 1 must have a captain.';
            }
            if ($team2 && !$team2->captain) {
                $errors[] = 'Team 2 must have a captain.';
            }

            $team1PlayerCount = $team1->players()->count();
            if ($team1PlayerCount < $sport->min_players || $team1PlayerCount > $sport->max_players) {
                $errors[] = "Team 1 must have between {$sport->min_players} and {$sport->max_players} players.";
            }

            if ($team2) {
                $team2PlayerCount = $team2->players()->count();
                if ($team2PlayerCount < $sport->min_players || $team2PlayerCount > $sport->max_players) {
                    $errors[] = "Team 2 must have between {$sport->min_players} and {$sport->max_players} players.";
                }
            }

            // Step 4: Facility and sport compatibility
            $timeSlot = TimeSlotInstance::with('recurringTimeSlot.sportFacility.sports')->findOrFail($validated['time_slot_id']);
            $facilitySportIds = $timeSlot->recurringTimeSlot->sportFacility->sports->pluck('id')->toArray();

            if (!in_array($team1->sport_id, $facilitySportIds)) {
                $errors[] = 'Team 1 sport does not match the facility sports.';
            }

            if ($team2 && !in_array($team2->sport_id, $facilitySportIds)) {
                $errors[] = 'Team 2 sport does not match the facility sports.';
            }

            if ($team2) {
                if ($team1->sport_id !== $team2->sport_id) {
                    $errors[] = 'Both teams must belong to the same sport.';
                }
                if ($team1->id == $team2->id) {
                    $errors[] = 'Teams must be different.';
                }
            } elseif ($matchType === MatchType::PRIVATE->value) {
                $errors[] = 'Private matches require a second team.';
            }

            // Step 5: If any errors exist, return them
            if (!empty($errors)) {
                return response()->json([
                    'errors' => $errors,
                    'success' => false,
                    'message' => 'Validation failed.'
                ], 422);
            }
            try {
                DB::beginTransaction();
                // Step 6: Proceed with match, reservation, etc.
                $match = Game::create([
                    'type' => $matchType,
                    'status' => MatchStatus::PENDING,
                ]);

                TeamMatch::create([
                    'team_id' => $validated['team1_id'],
                    'match_id' => $match->id,
                    'score' => 0,
                    'is_winner' => false,
                ]);

                if ($matchType === MatchType::PRIVATE->value) {
                    TeamMatch::create([
                        'team_id' => $validated['team2_id'],
                        'match_id' => $match->id,
                        'score' => 0,
                        'is_winner' => false,
                    ]);
                }

                $reservation = Reservation::create([
                    'time_slot_instance_id' => $validated['time_slot_id'],
                    'user_id' => $validated['user_id'],
                    'date' => now(),
                    'match_id' => $match->id,
                    'auto_confirm' => $validated['auto_confirm'] ?? false,
                    'total_price' => 0,
                    'status' => ReservationStatus::PENDING,
                ]);

                $timeSlotInstance = $reservation->TimeSlotInstance;
                $timeSlotInstance->status = TimeSlotsStatus::RESERVED;
                $timeSlotInstance->save();

                if ($matchType === MatchType::PRIVATE->value) {
                    $invitation = new Invitation([
                        'sender_id' => $team1->captain->user_id,
                        'receiver_id' => $team2->captain->user_id,
                        'type' => TypeInvitation::MATCH->value,
                        'status' => InvitationStatus::PENDING->value,
                    ]);
                    $invitation->invitabl()->associate($match);
                    $invitation->save();
                }

                return response()->json([
                    'message' => 'Reservation created successfully.',
                    'success' => true,
                ], 201);
            } catch (\Exception $e) {
                DB::rollBack();

                return response()->json([
                    'message' => 'Reservation failed.',
                    'success' => false,
                ], 500);
            }
        }
    }
}
