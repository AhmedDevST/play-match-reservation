<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class TeamsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $teams = [];
        for ($i = 1; $i <= 10; $i++) {
            $teams[] = [
                'name' => 'Team ' . $i,
                'image' => null,
                'total_score' => 0,
                'average_rating' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        DB::table('teams')->insert($teams);
    }
}
