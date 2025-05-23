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
        // Get the first recurring time slot and time zone IDs
        $recurringTimeSlotId = DB::table('recurring_time_slots')->first()->id;
        $timeZoneId = DB::table('time_zones')->first()->id;

        // Create time slot instances for the next 7 days
        $timeSlotInstances = [];
        $startDate = Carbon::now()->startOfDay();

        for ($i = 0; $i < 7; $i++) {
            $date = $startDate->copy()->addDays($i);
            
            // Morning slot
            $timeSlotInstances[] = [
                'date' => $date->format('Y-m-d'),
                'start_time' => '09:00:00',
                'end_time' => '10:00:00',
                'recurring_time_slot_id' => $recurringTimeSlotId,
                'time_zone_id' => $timeZoneId,
                'status' => TimeSlotsStatus::AVAILABLE->value,
                'is_exception' => false,
                'exception_reason' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Afternoon slot
            $timeSlotInstances[] = [
                'date' => $date->format('Y-m-d'),
                'start_time' => '14:00:00',
                'end_time' => '15:00:00',
                'recurring_time_slot_id' => $recurringTimeSlotId,
                'time_zone_id' => $timeZoneId,
                'status' => TimeSlotsStatus::AVAILABLE->value,
                'is_exception' => false,
                'exception_reason' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Evening slot
            $timeSlotInstances[] = [
                'date' => $date->format('Y-m-d'),
                'start_time' => '19:00:00',
                'end_time' => '20:00:00',
                'recurring_time_slot_id' => $recurringTimeSlotId,
                'time_zone_id' => $timeZoneId,
                'status' => TimeSlotsStatus::AVAILABLE->value,
                'is_exception' => false,
                'exception_reason' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        DB::table('time_slot_instances')->insert($timeSlotInstances);
    }
} 