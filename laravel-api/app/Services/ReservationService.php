<?php

namespace App\Services;

use App\Enums\ReservationStatus;
use App\Enums\TimeSlotsStatus;
use App\Models\Reservation;
use App\Models\TimeSlotInstance;
use Illuminate\Support\Facades\DB;

class ReservationService
{
    public function createSimpleReservation(array $data, int $userId): Reservation
    {
        return DB::transaction(function () use ($data, $userId) {
            $reservation = Reservation::create([
                'time_slot_instance_id' => $data['time_slot_id'],
                'user_id' => $userId,
                'date' => now(),
                'total_price' => 0,
                'status' => ReservationStatus::COMPLETED,
            ]);
            $this->reserveTimeSlot($reservation->timeSlotInstance);
            return $reservation;
        });
    }
    public function reserveTimeSlot(TimeSlotInstance $timeSlotInstance): void
    {
        $timeSlotInstance->update(['status' => TimeSlotsStatus::RESERVED]);
    }
}
