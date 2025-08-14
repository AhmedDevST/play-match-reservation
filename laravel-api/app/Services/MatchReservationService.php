<?php

namespace App\Services;
use App\Enums\MatchStatus;
use App\Enums\MatchType;
use App\Enums\ReservationStatus;
use App\Models\Game;
use App\Models\Reservation;
use App\Models\Team;
use App\Models\TeamMatch;
use App\Models\TimeSlotInstance;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class MatchReservationService
{
    public function __construct(
        private TeamValidationService $teamValidator,
        private FacilityValidationService $facilityValidator,
        private NotificationService $notificationService,
        private ReservationService $reservationService,
        private InvitationService $invitationService
    ) {}

    public function createMatchReservation(array $data, int $userId)
    {
        return DB::transaction(function () use ($data, $userId) {
            // Load and validate teams
            $teams = $this->loadAndValidateTeams($data);
            $timeSlot = $this->loadTimeSlot($data['time_slot_id']);

            // Validate business rules
            $this->validateBusinessRules($teams, $timeSlot, $data['match_type']);

            // Create match and reservation
            $match = $this->createMatch($data['match_type']);
            $this->createTeamMatches($match, $teams, $data['match_type']);

            $reservation = $this->createReservation($data, $userId, $match);
            $this->reservationService->reserveTimeSlot($timeSlot);

            // Handle private match invitations
            if ($data['match_type'] === MatchType::PRIVATE->value && isset($teams['team2'])) {
                $invitation = $this->invitationService->createInvitation(
                    'match',
                    $teams['team2']->captain->user_id,
                    $teams['team1']->captain->user_id,
                    $match->id
                );
                if ($invitation) {
                    $this->notificationService->createMatchInvitationNotification($invitation, $teams);
                }
            }
            return $reservation;
        });
    }

    private function loadAndValidateTeams(array $data): array
    {
        $team1 = Team::with(['captain.user', 'sport', 'players'])->findOrFail($data['team1_id']);
        $team2 = isset($data['team2_id'])
            ? Team::with(['captain.user', 'sport', 'players'])->findOrFail($data['team2_id'])
            : null;
        return compact('team1', 'team2');
    }

    private function loadTimeSlot(int $timeSlotId): TimeSlotInstance
    {
        return TimeSlotInstance::with('recurringTimeSlot.sportFacility.sports')
            ->findOrFail($timeSlotId);
    }

    private function validateBusinessRules(array $teams, TimeSlotInstance $timeSlot, string $matchType): void
    {
        $errors = [];
        // Team validation
        $errors = array_merge($errors, $this->teamValidator->validateTeams($teams, $matchType));
        // Facility validation
        $errors = array_merge($errors, $this->facilityValidator->validateFacilityCompatibility($teams, $timeSlot));
        if (!empty($errors)) {
            throw ValidationException::withMessages($errors);
        }
    }

    private function createMatch(string $matchType): Game
    {
        return Game::create([
            'type' => $matchType,
            'status' => MatchStatus::PENDING,
        ]);
    }

    private function createTeamMatches(Game $match, array $teams, string $matchType): void
    {
        TeamMatch::create([
            'team_id' => $teams['team1']->id,
            'match_id' => $match->id,
            'score' => 0,
            'is_winner' => false,
        ]);

        if ($matchType === MatchType::PRIVATE->value && $teams['team2']) {
            TeamMatch::create([
                'team_id' => $teams['team2']->id,
                'match_id' => $match->id,
                'score' => 0,
                'is_winner' => false,
            ]);
        }
    }

    private function createReservation(array $data, int $userId, Game $match): Reservation
    {
        return Reservation::create([
            'time_slot_instance_id' => $data['time_slot_id'],
            'user_id' => $userId,
            'date' => now(),
            'match_id' => $match->id,
            'auto_confirm' => $data['auto_confirm'] ?? false,
            'total_price' => 0,
            'status' => ReservationStatus::PENDING,
        ]);
    }
}
