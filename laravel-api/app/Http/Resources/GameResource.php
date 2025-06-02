<?php

namespace App\Http\Resources;

use App\Models\TeamMatch;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GameResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'     => $this->id,
            'status' => $this->status->value, // Enum cast
            'type'   => $this->type,
            'teams' => $this->whenLoaded('teamMatches', function () {
                return TeamMatchResource::collection($this->teamMatches);
            }),
        ];
    }
}
