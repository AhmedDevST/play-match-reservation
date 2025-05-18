<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class SportFacilitySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('sport_facilities')->insert([
            [
                'name' => 'Stade Municipal',
                'address' => '123 Rue du Sport',
                'description' => 'Grand stade municipal avec terrain de football et piste d\'athlétisme',
                'price_per_hour' => 150.00,
                'rating' => 4.5,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Complexe Sportif Central',
                'address' =>  '45 Avenue des Sports',
                'description' => 'Complexe moderne avec terrains de tennis et basket',
                'price_per_hour' => 80.00,
                'rating' => 4.2,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Centre Sportif Olympique',
                'address' => '78 Boulevard des Athlètes',
                'description' => 'Centre sportif complet avec piscine et terrains multisports',
                'price_per_hour' => 120.00,
                'rating' => 4.8,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Espace Sportif Moderne',
                'address' =>  '15 Rue de l\'Arena',
                'description' => 'Installations modernes pour tous types de sports',
                'price_per_hour' => 95.00,
                'rating' => 4.3,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
} 