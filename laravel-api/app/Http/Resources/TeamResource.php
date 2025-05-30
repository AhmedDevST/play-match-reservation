<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TeamResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array<string, mixed>
     */
    public function toArray($request)
    {
        // Get the UserTeamLink for current user
        $userTeamLink = $this->userTeamLinks->first();
        
        return [
            'id' => $this->id,
            'name' => $this->name,
            'image' => $this->image,
            'total_score' => $this->total_score,
            'sport' => new SportResource($this->whenLoaded('sport')),
            'average_rating' => $this->average_rating,
            'sport' => $this->sport,
            'has_left_team' => $userTeamLink ? $userTeamLink->has_left_team : false,
            'is_captain' => $userTeamLink ? $userTeamLink->is_captain : false,
        ];
    }
}
