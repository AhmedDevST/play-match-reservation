<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class TeamMatchResource extends JsonResource
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
            'team'   => new TeamsplayersResource( $this->team),
            'score'     => $this->score,
            'is_winner' => $this->is_winner,
        ];
    }
}
