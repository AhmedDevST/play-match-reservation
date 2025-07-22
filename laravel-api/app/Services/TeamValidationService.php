<?php
namespace App\Services;

use App\Models\Team;
use App\Enums\MatchType;

class TeamValidationService
{
    public function validateTeams(array $teams, string $matchType): array
    {
        $errors = [];
        $errors = array_merge($errors, $this->validateTeam($teams['team1'], 'Team 1'));

        if ($teams['team2']) {
            $errors = array_merge($errors, $this->validateTeam($teams['team2'], 'Team 2'));
            $errors = array_merge($errors, $this->validateTeamCompatibility($teams['team1'], $teams['team2']));
        } elseif ($matchType === MatchType::PRIVATE->value) {
            $errors[] = 'Private matches require a second team.';
        }

        return $errors;
    }

    private function validateTeam(Team $team, string $teamLabel): array
    {
        $errors = [];

        if (!$team->captain) {
            $errors[] = "{$teamLabel} must have a captain.";
        }

        $playerCount = $team->players()->count();
        $sport = $team->sport;

        if ($playerCount < $sport->min_players || $playerCount > $sport->max_players) {
            $errors[] = "{$teamLabel} must have between {$sport->min_players} and {$sport->max_players} players.";
        }

        return $errors;
    }

    private function validateTeamCompatibility(Team $team1, Team $team2): array
    {
        $errors = [];

        if ($team1->sport_id !== $team2->sport_id) {
            $errors[] = 'Both teams must belong to the same sport.';
        }

        if ($team1->id === $team2->id) {
            $errors[] = 'Teams must be different.';
        }

        return $errors;
    }
}
