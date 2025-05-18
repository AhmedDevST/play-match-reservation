<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class FacilitySportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('facility_sport')->insert([
            // Stade Municipal (ID: 1) - Football and Football5
            [
                'sport_facility_id' => 1,
                'sport_id' => 1, // Football
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 1,
                'sport_id' => 2, // Football5
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Complexe Sportif Central (ID: 2) - Basketball and Tennis
            [
                'sport_facility_id' => 2,
                'sport_id' => 3, // Basketball
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 2,
                'sport_id' => 4, // Tennis
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Centre Sportif Olympique (ID: 3) - All sports
            [
                'sport_facility_id' => 3,
                'sport_id' => 1, // Football
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 3,
                'sport_id' => 2, // Football5
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 3,
                'sport_id' => 3, // Basketball
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 3,
                'sport_id' => 4, // Tennis
                'created_at' => now(),
                'updated_at' => now(),
            ],

            // Espace Sportif Moderne (ID: 4) - Basketball and Tennis
            [
                'sport_facility_id' => 4,
                'sport_id' => 3, // Basketball
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'sport_facility_id' => 4,
                'sport_id' => 4, // Tennis
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
} 