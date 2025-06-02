<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\TeamResource;
use App\Http\Resources\GameResource;
use App\Models\Team;
use App\Models\Game;

class NotificationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'type' => $this->type,
            'title' => $this->title,
            'message' => $this->message,
            'is_read' => $this->is_read,
            'created_at' => $this->created_at,
            'notifiable_id' => $this->notifiable_id,
            'notifiable' => $this->getNotifiableResource(),
        ];
    }

    /**
     * Get the notifiable resource based on type
     */
    private function getNotifiableResource()
    {
        if (!$this->notifiable_type || !$this->notifiable_id) {
            return null;
        }

        switch ($this->notifiable_type) {
            case Invitation::class:
            case 'App\\Models\\Invitation':
                return new InvitationResource($this->notifiable);
            
            default:
                return null;
        }
    }
}
