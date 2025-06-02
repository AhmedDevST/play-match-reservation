<?php

namespace App\Http\Resources;

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

        switch ($this->invitable_type) {
            case Team::class:
            case 'App\\Models\\Team':
                $team = Team::find($this->invitable_id);
                return $team ? [
                    'id' => $team->id,
                    'name' => $team->name,
                    'image' => $team->image
                ] : null;

            case Game::class:
            case 'App\\Models\\Game':
                $game = Game::find($this->invitable_id);
                return $game ? new GameResource($game) : null;

            default:
                return null;
        }
    }
}
