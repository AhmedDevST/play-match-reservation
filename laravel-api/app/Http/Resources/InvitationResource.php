<?php

namespace App\Http\Resources;

use App\Enums\TypeInvitation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\TeamResource;
use App\Http\Resources\GameResource;
use App\Models\Team;
use App\Models\Game;

class InvitationResource extends JsonResource
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
            'sender' => new UserResource($this->sender),
            'receiver' => new UserResource($this->receiver),
            'type' => $this->type,
            'status' => $this->status,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'invitable_id' => $this->invitable_id,
            'invitable' => $this->getInvitableResource(),
        ];
    }

    /**
     * Get the notifiable resource based on type
     */
    private function getInvitableResource()
    {
        if (!$this->invitable_type || !$this->invitable_id) {
            return null;
        }

        switch ($this->type) {
            case TypeInvitation::TEAM:
            $team = Team::find($this->invitable_id);
            return $team ? [
                'id' => $team->id,
                'name' => $team->name,
                'image' => $team->image
            ] : null;

            case TypeInvitation::MATCH:
            $game = Game::find($this->invitable_id);
            return $game ? [
                'id' => $game->id,
                'type' => $game->type,
                'status' => $game->status,
            ] : null;

            default:
            return null;
        }
    }
}
