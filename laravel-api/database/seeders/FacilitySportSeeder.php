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
        $facilityIds = DB::table('sport_facilities')->pluck('id')->toArray();
        $sportIds = DB::table('sports')->pluck('id')->toArray();

        $data = [];

        for ($i = 0; $i < 10; $i++) {
            $data[] = [
                'sport_facility_id' => $facilityIds[array_rand($facilityIds)],
                'sport_id' => $sportIds[array_rand($sportIds)],
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        DB::table('facility_sport')->insert($data);
    }
}
