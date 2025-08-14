<?php

namespace App\Services;

use App\Models\Team;
use App\Enums\MatchType;

class TeamValidationService
{
    public function validateTeams(array $teams, string $matchType): array
    {
        $errors = [];
        $errors = array_merge(
            $errors,
            $this->validateTeam($teams['team1'], 'team1')
        );
        if ($teams['team2']) {
            $errors = array_merge(
                $errors,
                $this->validateTeam($teams['team2'], 'team2')
            );
            $errors = array_merge(
                $errors,
                $this->validateTeamCompatibility($teams['team1'], $teams['team2'])
            );
        } elseif ($matchType === MatchType::PRIVATE->value) {
            $errors['team2.required'] = 'Private matches require a second team.';
        }
        return $errors;
    }

    public function validateTeamPlayerCount(Team $team, string $teamKey): array
    {
        $errors = [];
        $sport = $team->sport;
        $playerCount = $team->getCurrentPlayerCount();
        if ($playerCount < $sport->min_players) {
            $errors["{$teamKey}.players"] = "{$teamKey} must have at least {$sport->min_players} players (currently has {$playerCount}).";
        }
        if ($playerCount > $sport->max_players) {
            $errors["{$teamKey}.players"] = "{$teamKey} cannot have more than {$sport->max_players} players (currently has {$playerCount}).";
        }
        return $errors;
    }

    private function validateTeam(Team $team, string $teamKey): array
    {
        $errors = [];
        if (!$team->captain) {
            $errors["{$teamKey}.captain"] = ucfirst($teamKey) . ' must have a captain.';
        }
        $playerCount = $team->players()->count();
        $sport = $team->sport;
        if ($playerCount < $sport->min_players || $playerCount > $sport->max_players) {
            $errors["{$teamKey}.players"] = ucfirst($teamKey) . " must have between {$sport->min_players} and {$sport->max_players} players.";
        }
        return $errors;
    }

    private function validateTeamCompatibility(Team $team1, Team $team2): array
    {
        $errors = [];
        if ($team1->sport_id !== $team2->sport_id) {
            $errors['teams.sport'] = 'Both teams must belong to the same sport.';
        }
        if ($team1->id === $team2->id) {
            $errors['teams.different'] = 'Teams must be different.';
        }
        return $errors;
    }
}
