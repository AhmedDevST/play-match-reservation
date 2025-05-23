<?php

namespace Database\Seeders;

use App\Enums\DayOfWeek;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RecurringTimeSlotSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get the first sport facility ID
        $sportFacilityId = DB::table('sport_facilities')->first()->id;

        $recurringTimeSlots = [
            [
                'sport_facility_id' => $sportFacilityId,
                'day' => DayOfWeek::MONDAY->value,
                'start_time' => '09:00:00',
                'end_time' => '17:00:00',
                'duration_minutes' => 60,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => $sportFacilityId,
                'day' => DayOfWeek::WEDNESDAY->value,
                'start_time' => '09:00:00',
                'end_time' => '17:00:00',
                'duration_minutes' => 60,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => $sportFacilityId,
                'day' => DayOfWeek::FRIDAY->value,
                'start_time' => '09:00:00',
                'end_time' => '17:00:00',
                'duration_minutes' => 60,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('recurring_time_slots')->insert($recurringTimeSlots);
    }
} 