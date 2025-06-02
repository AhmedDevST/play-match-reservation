<?php
 namespace Database\Seeders;

use App\Enums\TimeSlotsStatus;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class TimeSlotInstanceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $recurringTimeSlotId = DB::table('recurring_time_slots')->first()->id;

        // Fetch all time zones
        $timeZones = DB::table('time_zones')->get();

        $timeSlotInstances = [];
        $startDate = Carbon::now()->startOfDay();

        for ($i = 0; $i < 7; $i++) {
            $date = $startDate->copy()->addDays($i);

            foreach ($timeZones as $timeZone) {
                // Adjust end time if it is past midnight (like Night time zone)
                $startDateTime = Carbon::parse($date->format('Y-m-d') . ' ' . $timeZone->start_time);
                $endDateTime = Carbon::parse($date->format('Y-m-d') . ' ' . $timeZone->end_time);

                // If end time is before or equal to start time, it means it goes past midnight
                if ($endDateTime->lessThanOrEqualTo($startDateTime)) {
                    $endDateTime->addDay();
                }

                $timeSlotInstances[] = [
                    'date' => $date->format('Y-m-d'),
                    'start_time' => $startDateTime->format('H:i:s'),
                    'end_time' => $endDateTime->format('H:i:s'),
                    'recurring_time_slot_id' => $recurringTimeSlotId,
                    'time_zone_id' => $timeZone->id,
                    'status' => TimeSlotsStatus::AVAILABLE->value,
                    'is_exception' => false,
                    'exception_reason' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
        }

        DB::table('time_slot_instances')->insert($timeSlotInstances);
    }
}
