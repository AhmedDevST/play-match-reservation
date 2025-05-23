<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class UserTeamLinksTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $links = [];
        // Link each user to a team (user 1 to team 1, etc.)
        for ($i = 1; $i <= 10; $i++) {
            $links[] = [
                'user_id' => $i,
                'team_id' => $i,
                'start_date' => now(),
                'end_date' => null,
                'has_left_team' => false,
                'leave_reason' => null,
                'is_captain' => $i === 1, // Make user 1 captain as example
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }
        DB::table('user_team_links')->insert($links);
    }
}
