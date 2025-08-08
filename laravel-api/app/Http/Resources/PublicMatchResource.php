<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\GameResource;
use App\Http\Resources\SportFacilityResource;
use App\Http\Resources\TimeSlotInstanceResource;
use App\Http\Resources\TeamMatchResource;
use App\Http\Resources\InvitationResource;

class PublicMatchResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'game' => new GameResource($this),
            'facility' => new SportFacilityResource(
                $this->whenLoaded('reservation', function () {
                    return $this->reservation->TimeSlotInstance->recurringTimeSlot->sportFacility;
                })
            ),
            'time_slot' => new TimeSlotInstanceResource(
                $this->whenLoaded('reservation', function () {
                    return $this->reservation->TimeSlotInstance;
                })
            ),
          'invitation' => $this->invitation ? new InvitationResource($this->invitation) : null,
        ];
    }
}
