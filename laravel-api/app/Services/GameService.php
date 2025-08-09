<?php

namespace App\Services;

use App\Enums\TypeInvitation;
use App\Models\Game;

class GameService
{
    /**
     * Get public pending matches for the authenticated user.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getPublicPendingMatches($userId, $limit = null)
    {
        $query = Game::publicPendingMatches()
            ->with([
                'teamMatches.team.players',
                'teamMatches.team.sport',
                'reservation.TimeSlotInstance.recurringTimeSlot.sportFacility',
                'invitations' => function ($query) use ($userId) {
                    $query->where('sender_id', $userId)
                        ->where('type',TypeInvitation::MATCH);
                }
            ])
            ->orderBy('created_at', 'desc');

        if ($limit !== null) {
            $query->take($limit);
        }

        $matches = $query->get();

        $matchesWithInvitations = $matches->map(function ($match) {
            $match->invitation = $match->invitations->first();
            unset($match->invitations);
            return $match;
        });

        return $matchesWithInvitations;
    }
}
