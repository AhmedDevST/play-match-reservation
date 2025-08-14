<?php

namespace App\Services;

use App\Enums\InvitationStatus;
use App\Enums\NotificationType;
use App\Enums\TypeInvitation;
use App\Models\Game;
use App\Models\Invitation;
use App\Models\Team;
use App\Models\TimeSlotInstance;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class InvitationService
{
    public function __construct(
        private TeamValidationService $teamValidator,
        private NotificationService $notificationService
    ) {}



    public function handleGeneralInvitation(array $validated)
    {
        $invitation = $this->createInvitation($validated['type'], $validated['sender_id'], $validated['receiver_id'], $validated['invitable_id']);
        return $invitation;
    }
    public function handleMatchInvitation(array $validated)
    {
        $game = Game::findOrFail($validated['invitable_id']);
        $sender = User::findOrFail($validated['sender_id']);
        $receiver = User::findOrFail($validated['receiver_id']);

        // Check if an invitation already exists
        $existingInvitation = Invitation::where('sender_id', $sender->id)
            ->where('receiver_id', $receiver->id)
            ->where('type', TypeInvitation::MATCH->value)
            ->where('invitable_id', $game->id)
            ->first();
        if ($existingInvitation) {
            throw ValidationException::withMessages([
                'invitation' => ['An invitation already exists for this match.']
            ]);
        }

        // Get receiver's team from the match
        $receiverTeam = $this->getReceiverTeamFromMatch($game, $receiver);
        if (!$receiverTeam) {
            throw ValidationException::withMessages([
                'invitation' => ['Receiver is not part of any team in this match.']
            ]);
        }

        // Get sender's captain team in the same sport as receiver's team
        $senderTeam = $this->getSenderCaptainTeamInSameSport($sender, $receiverTeam->sport_id);
        if (!$senderTeam) {
            throw ValidationException::withMessages([
                'invitation' => ['You must be a captain of a team in the same sport to send this invitation.']
            ]);
        }
        // Check if sender's team has enough players
        $errors = $this->teamValidator->validateTeamPlayerCount($senderTeam, 'team1');
        if (!empty($errors)) {
            throw new ValidationException($errors);
        }
        $invitation = $this->createInvitation($validated['type'], $validated['receiver_id'], $validated['sender_id'], $validated['invitable_id']);
        if ($invitation) {
            $this->notificationService->create(
                $validated['receiver_id'],
                NotificationType::INVITATION_NOTIFICATION,
                'Invitation de match',
                "Vous avez reçu une invitation pour le  match  contre {$senderTeam->name}.",
                $invitation->id,
                Invitation::class
            );
            return $invitation;
        }
    }

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
