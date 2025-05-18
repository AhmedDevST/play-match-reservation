<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SportSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('sports')->insert([
            [
                'name' => 'Football5',
                'image' => null,
                'min_players' => 8,
                'max_players' => 10,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Basketball',
                'image' => null,
                'min_players' => 2,
                'max_players' => 10,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Football',
                'image' => null,
                'min_players' => 20,
                'max_players' => 22,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Tennis',
                'image' => null,
                'min_players' => 2,
                'max_players' => 4,
                'created_at' => now(),
                'updated_at' => now(),
            ],
          
        ]);
    }
} 