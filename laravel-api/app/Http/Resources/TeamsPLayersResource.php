<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TeamsplayersResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array<string, mixed>
     */
    public function toArray($request)
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'image' => $this->image,
            'total_score' => $this->total_score,
            'sport' => new SportResource($this->whenLoaded('sport')),
            'average_rating' => $this->average_rating,
            'players' => $this->players->map(function ($user) {
                return [
                    'user' => new UserResource($user),
                    'is_captain' => $user->pivot->is_captain,
                    //'has_left_team' => $user->pivot->has_left_team,
                ];
            }),

        ];
    }
}
