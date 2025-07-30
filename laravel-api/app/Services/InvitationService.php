<?php

namespace App\Services;

use App\Enums\InvitationStatus;
use App\Enums\TypeInvitation;
use App\Exceptions\ValidationException;
use App\Models\Game;
use App\Models\Invitation;
use App\Models\Team;
use App\Models\TimeSlotInstance;
use App\Models\User;

class InvitationService
{
    public function __construct(
        private TeamValidationService $teamValidator,
    ) {}

    public function getSenderCaptainTeamInSameSport(User $sender, int $sportId): ?Team
    {
        // Find team where sender is captain in the same sport
        return Team::where('sport_id', $sportId)
            ->whereHas('userTeamLinks', function ($query) use ($sender) {
                $query->where('user_id', $sender->id)
                    ->where('is_captain', true)
                    ->where('has_left_team', false);
            })
            ->first();
    }

    public function getReceiverTeamFromMatch(Game $game, User $receiver): ?Team
    {
        // Find receiver's team that is participating in this match
        foreach ($game->teamMatches as $teamMatch) {
            $team = $teamMatch->team;
            // Check if receiver is a member of this team and hasn't left
            if ($team->userTeamLinks()
                ->where('user_id', $receiver->id)
                ->where('has_left_team', false)
                ->where('is_captain', true)
                ->exists()
            ) {
                return $team;
            }
        }
        return null;
    }

    public function createInvitation($type,$receiver_id,$sender_id,$invitable_id)
    {
        $type = TypeInvitation::from($type);
        $invitableType = match ($type) {
            TypeInvitation::MATCH => \App\Models\Game::class,
            TypeInvitation::TEAM => \App\Models\Team::class,
            TypeInvitation::FRIEND => null,
        };
        $invitationData = [
            'type' => $type,
            'sender_id' => $sender_id,
            'receiver_id' => $receiver_id,
            'status' => InvitationStatus::PENDING,
        ];
        // Only set morph data if applicable
        if ($invitableType && !empty($invitable_id)) {
            $invitationData['invitable_type'] = $invitableType;
            $invitationData['invitable_id'] = $invitable_id;
        }
        $invitation = Invitation::create($invitationData);
        return $invitation;
    }
}
