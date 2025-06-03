<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Carbon\Carbon;

class ReservationResource extends JsonResource
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
            'user_id' => $this->user_id,
            'date' => Carbon::parse($this->date)->format('Y-m-d'),
            'total_price' => $this->total_price,
            'status' => $this->status,
            'auto_confirm' => $this->auto_confirm,
            'facility' => new SportFacilityResource(
                optional($this->TimeSlotInstance->recurringTimeSlot->sportFacility)
            ),
            'time_slot' => new TimeSlotInstanceResource($this->whenLoaded('TimeSlotInstance')),
            'game' =>  new GameResource($this->whenLoaded('game')),
        ];
    }
}
