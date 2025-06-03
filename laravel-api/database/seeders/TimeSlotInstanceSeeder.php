<?php

namespace Database\Seeders;

use App\Enums\DayOfWeek;
use App\Enums\TimeSlotsStatus;
use App\Models\RecurringTimeSlot;
use App\Models\TimeSlotInstance;
use App\Models\TimeZone;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TimeSlotInstanceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->generateTimeSlotInstances();
    }

    /**
     * Generate time slot instances for the next 7 days
     */
    private function generateTimeSlotInstances(): void
    {
        // Get all recurring time slots
        $recurringTimeSlots = RecurringTimeSlot::with('sportFacility')->get();

        if ($recurringTimeSlots->isEmpty()) {
            $this->command->info('No recurring time slots found. Please seed recurring time slots first.');
            return;
        }

        // Generate instances for the next 7 days
        $today = Carbon::today();

        for ($i = 0; $i < 7; $i++) {
            $currentDate = $today->copy()->addDays($i);
            $dayOfWeek = $this->carbonDayToEnum($currentDate->dayOfWeek);

            $this->generateInstancesForDate($currentDate, $dayOfWeek, $recurringTimeSlots);
        }

        $this->command->info('Time slot instances generated successfully for the next 7 days.');
    }

    /**
     * Generate time slot instances for a specific date
     */
    private function generateInstancesForDate(Carbon $date, DayOfWeek $dayOfWeek, $recurringTimeSlots): void
    {

        foreach ($recurringTimeSlots as $recurringSlot) {
            // Skip if this recurring slot is not for this day

            $recurringSlotDayValue = $recurringSlot->day instanceof \App\Enums\DayOfWeek
                ? $recurringSlot->day->value
                : (string)$recurringSlot->day;

            $this->command->info(
                'Date: ' . $date->toDateString() .
                    ', DayOfWeek Enum: ' . $dayOfWeek->value .
                    ', Recurring Slot Day: ' . $recurringSlotDayValue
            );
            if ($recurringSlot->day !== $dayOfWeek) {
                $this->command->info('not match .');
                continue;
            }


            $this->command->info('pass.');
            // Check if instance already exists for this date and recurring slot
            /*   $existingInstance = TimeSlotInstance::where('date', $date->toDateString())
                ->where('recurring_time_slot_id', $recurringSlot->id)
                ->first();

            if ($existingInstance) {
                continue; // Skip if already exists
            }
*/
            // Generate time slot instances based on duration
            $this->generateInstancesForRecurringSlot($date, $recurringSlot);
        }
    }

    /**
     * Generate individual time slot instances for a recurring time slot
     */
    private function generateInstancesForRecurringSlot(Carbon $date, RecurringTimeSlot $recurringSlot): void
    {
        $this->command->info('not generateInstancesForRecurringSlot .');

        $this->command->info('Raw start_time: ' . $recurringSlot->start_time);

        // Try parsing full datetime
        $startTime = Carbon::createFromFormat('Y-m-d H:i:s', $recurringSlot->start_time);
        $endTime = Carbon::createFromFormat('Y-m-d H:i:s', $recurringSlot->end_time);

        $durationMinutes = $recurringSlot->duration_minutes;

        $currentTime = $startTime->copy();
        $this->command->info('not in  while .');
        while ($currentTime->addMinutes($durationMinutes)->lte($endTime)) {
            $this->command->info('in while .');
            $slotStartTime = $currentTime->copy()->subMinutes($durationMinutes);
            $slotEndTime = $currentTime->copy();

            // Find appropriate time zone (you may need to adjust this logic)
            $timeZone = $this->findTimeZoneForSlot($slotStartTime, $slotEndTime);

            TimeSlotInstance::create([
                'date' => $date->toDateString(),
                'start_time' => $slotStartTime->format('H:i:s'),
                'end_time' => $slotEndTime->format('H:i:s'),
                'recurring_time_slot_id' => $recurringSlot->id,
                'time_zone_id' => $timeZone?->id,
                'status' => TimeSlotsStatus::AVAILABLE->value,
                'is_exception' => false,
                'exception_reason' => null,
            ]);
        }
    }

    /**
     * Find appropriate time zone for a time slot
     * You may need to adjust this logic based on your business requirements
     */
    private function findTimeZoneForSlot(Carbon $startTime, Carbon $endTime): ?TimeZone
    {
        return TimeZone::where('start_time', '<=', $startTime->format('H:i:s'))
            ->where('end_time', '>=', $endTime->format('H:i:s'))
            ->first();
    }

    /**
     * Convert Carbon day of week to DayOfWeek enum
     */
    private function carbonDayToEnum(int $carbonDay): DayOfWeek
    {
        return match ($carbonDay) {
            0 => DayOfWeek::SUNDAY,
            1 => DayOfWeek::MONDAY,
            2 => DayOfWeek::TUESDAY,
            3 => DayOfWeek::WEDNESDAY,
            4 => DayOfWeek::THURSDAY,
            5 => DayOfWeek::FRIDAY,
            6 => DayOfWeek::SATURDAY,
        };
    }

    /**
     * Clean up old time slot instances (optional)
     * Call this method if you want to remove instances older than today
     */
    public function cleanupOldInstances(): void
    {
        $yesterday = Carbon::yesterday();

        TimeSlotInstance::where('date', '<', $yesterday->toDateString())
            ->where('status', TimeSlotsStatus::AVAILABLE->value)
            ->delete();

        $this->command->info('Old time slot instances cleaned up.');
    }
}
