<?php

namespace App\Http\Controllers;

use App\Enums\InvitationStatus;
use App\Enums\MatchStatus;
use App\Enums\MatchType;
use App\Enums\ReservationStatus;
use App\Enums\TimeSlotsStatus;
use App\Enums\TypeInvitation;
use App\Models\Sport;
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




    public function store(Request $request)
    {
        if ($request->has('is_match') == false) {
            dd('Reservation logic goes here');
            $validated = $request->validate([
                'time_slot_id' => [
                    'required',
                    Rule::exists('time_slot_instances', 'id')->where('status', 'available'),
                ],
                'user_id' => 'required|exists:users,id',
            ]);
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
                    //'reservation' => $reservation,
                ], 201);
            } catch (\Exception $e) {
                DB::rollBack();

                return response()->json([
                    'message' => 'Reservation failed.',
                    //'error' => $e->getMessage(),
                ], 500);
            }
        } else {
            //validate the request for match reservation
            $validated = $request->validate([
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
            $matchType = $validated['match_type'];
            $team1 = Team::find($validated['team1_id']);
            $team2 = isset($validated['team2_id']) ? Team::find($validated['team2_id']) : null;

            // Check if the captain of team1 adn team2 are exists
            if (!$team1->captain || ($team2 && !$team2->captain)) {
                return response()->json([
                    'message' => 'Both teams must have a captain.',
                ], 422);
            }
            // Validate team 1 player count
            $team1PlayerCount = $team1->players()->count();
            $sport = $team1->sport;
            if ($team1PlayerCount < $sport->min_players || $team1PlayerCount > $sport->max_players) {
                return response()->json([
                    'message' => "Team 1 must have between {$sport->min_players} and {$sport->max_players} players.",
                ], 422);
            }
            // Validate team 2 player count only if team2 exists
            if ($team2) {
                $team2PlayerCount = $team2->players()->count();
                if ($team2PlayerCount < $sport->min_players || $team2PlayerCount > $sport->max_players) {
                    return response()->json([
                        'message' => "Team 2 must have between {$sport->min_players} and {$sport->max_players} players.",
                    ], 422);
                }
            }

            //test facility sport match in the sport's team
            $timeSlot = TimeSlotInstance::with('recurringTimeSlot.sportFacility.sports')->findOrFail($validated['time_slot_id']);
            $sportFacility = $timeSlot->recurringTimeSlot->sportFacility;

            $facilitySportIds = $sportFacility->sports->pluck('id')->toArray();
            if (!in_array($team1->sport_id, $facilitySportIds)) {
                return response()->json([
                    'message' => 'Team 1 sport does not match the facility sports.',
                ], 422);
            }

            if ($team2 && !in_array($team2->sport_id, $facilitySportIds)) {
                return response()->json([
                    'message' => 'Team 2 sport does not match the facility sports.',
                ], 422);
            }

            if ($team2) {
                // Check if both teams belong to the same sport
                if ($team1->sport_id !== $team2->sport_id) {
                    return response()->json([
                        'message' => 'Both teams must belong to the same sport.',
                    ], 422);
                }
                if ($team1->id == $team2->id) {
                    return response()->json([
                        'message' => ' Teams must be different.',
                    ], 422);
                }
            } else {
                // If it's a private match, team2 must be provided
                return response()->json([
                    'message' => 'Private matches require a second team.',
                ], 422);
            }

           // try {
                //   DB::beginTransaction();
                //create match
                $match = Game::create([
                    'type' => $matchType,
                    'status' => MatchStatus::PENDING,
                ]);

                // Add team 1 (always)
                TeamMatch::create([
                    'team_id' => $validated['team1_id'],
                    'match_id' => $match->id,
                    'score' => 0,
                    'is_winner' => false,
                ]);
                // Add team 2 only if match is private and team2 exists
                if ($matchType === MatchType::PRIVATE->value) {
                    TeamMatch::create([
                        'team_id' => $validated['team2_id'],
                        'match_id' => $match->id,
                        'score' => 0,
                        'is_winner' => false,
                    ]);
                }
                // Create the reservation with status pending
                $reservation = Reservation::create([
                    'time_slot_instance_id' => $validated['time_slot_id'],
                    'user_id' => $validated['user_id'],
                    'date' => now(),
                    'match_id' => $match->id,
                    'auto_confirm' => $validated['auto_confirm'] ?? false,
                    'total_price' => 0,
                    'status' => ReservationStatus::PENDING,
                ]);

                // Update the status of the time slot instance to reserved
                $timeSlotInstance = $reservation->TimeSlotInstance;
                $timeSlotInstance->status = TimeSlotsStatus::RESERVED;
                $timeSlotInstance->save();

                // For private matches, create invitation
                if ($matchType === MatchType::PRIVATE->value) {
                    $captain1Id = $team1->captain->user_id;
                    $captain2Id = $team2->captain->user_id;
                    $invitation = new Invitation([
                        'sender_id' => $captain1Id,
                        'receiver_id' => $captain2Id,
                        'type' => TypeInvitation::MATCH->value,
                        'status' => InvitationStatus::PENDING->value,
                    ]);
                    $invitation->invitabl()->associate($match);
                    $invitation->save();
                }
                //   DB::commit();
                return response()->json([
                    'message' => 'Reservation created successfully.',
                    //'reservation' => $reservation,
                ], 201);
       //     } catch (\Exception $e) {
                /// DB::rollBack();

                //return response()->json([
               //     'message' => 'Reservation failed.',
                    //'error' => $e->getMessage(),
             //   ], 500);
           // }
        }
    }
}
