<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TimeZoneSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $timeZones = [
            [
                'name' => 'Morning',
                'start_time' => '06:00:00',
                'end_time' => '12:00:00',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Afternoon',
                'start_time' => '12:00:00',
                'end_time' => '18:00:00',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Evening',
                'start_time' => '18:00:00',
                'end_time' => '22:00:00',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Night',
                'start_time' => '22:00:00',
                'end_time' => '06:00:00',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('time_zones')->insert($timeZones);
    }
} 