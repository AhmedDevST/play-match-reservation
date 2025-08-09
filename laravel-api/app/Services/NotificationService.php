<?php

namespace App\Services;

use App\Models\Invitation;
use App\Controllers\NotificationController;
use App\Enums\NotificationType;
use App\Models\Notification;

class NotificationService
{
    public function createMatchInvitationNotification(Invitation $invitation, array $teams): void
    {
        $this->create(
            $teams['team2']->captain->user_id,
            NotificationType::INVITATION_NOTIFICATION,
            'Invitation de match',
            "Vous avez reçu une invitation pour un match de {$teams['team1']->sport->name} contre {$teams['team1']->name}.",
            $invitation->id,
            Invitation::class
        );
    }


    public function create($userId, $type, $title, $message, $notifiableId = null, $notifiableType = null)
    {
        $notification = Notification::create([
            'user_id' => $userId,
            'type' => $type instanceof NotificationType ? $type : NotificationType::from($type),
            'title' => $title,
            'message' => $message,
            'is_read' => false,
            'notifiable_id' => $notifiableId,
            'notifiable_type' => $notifiableType,
        ]);

        return $notification;
    }

    public function countNotifications($userId): int
    {
        return Notification::where('user_id', $userId)
            ->where('is_read', false)
            ->count();
    }
}
