<?php

namespace App\Http\Controllers;

use App\Enums\TimeSlotsStatus;
use App\Models\SportFacility;
use App\Http\Resources\TimeSlotInstanceResource;
use App\Http\Resources\TimeZoneResource;
use App\Models\TimeZone;
use Illuminate\Http\Request;

class TimeSlotInstanceController extends Controller
{
    //
    public function getAvailableTimeSlots(Request $request, $facilityId)
    {
        $date = $request->date ?? now()->format('Y-m-d');
        $facility = SportFacility::find($facilityId);
        $timeSlotInstances = $this->getTimeSlotsInstances($facility,$date);
        return response()->json([
            'time_slots' => TimeSlotInstanceResource::collection($timeSlotInstances)
        ]);
    }
    public function initTimeSlotInstances($facilityId)
    {
        $date = now()->format('Y-m-d');
        $facility = SportFacility::find($facilityId);
        $timeSlotInstances = $this->getTimeSlotsInstances($facility,$date);
        $timesZones = TimeZone::all();
        return response()->json([
            'dates' => $this->getDates(),
            'time_slots' => TimeSlotInstanceResource::collection($timeSlotInstances),
            'time_zones' => TimeZoneResource::collection($timesZones)
        ]);
    }

    public function getTimeSlotsInstances($facility, $date)
    {
        $now = now();
        $recurringTimeSlots = $facility->recurringTimeSlots()
            ->with(['timeSlotInstances' => function ($query) use ($date, $now) {
                $query->where('date', $date)
                    // ->where('status', TimeSlotsStatus::AVAILABLE->value)
                    ->with('timeZone')
                    ->where(function ($q) use ($now, $date) {
                        // Only filter by start_time if the date is today
                        if ($date === $now->format('Y-m-d')) {
                            $q->where('start_time', '>', $now->format('H:i:s'));
                        }
                    });
            }])
            ->get();
        $timeSlotInstances = $recurringTimeSlots->flatMap(function ($recurringSlot) {
            return $recurringSlot->timeSlotInstances;
        });
        return $timeSlotInstances;
    }
    public function getDates()
    {
        $startDate = now();
        $dates = collect(range(0, 6))->map(function ($day) use ($startDate) {
            return $startDate->copy()->addDays($day)->format('Y-m-d');
        });
        return $dates;
    }
}
