<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ImageFacilitySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Stade Municipal (ID: 1) - Football images
        $this->addImagesForFacility(1, [
            ['path' => 'SportFacilityImages/foot1.jpg', 'is_primary' => true],
            ['path' => 'SportFacilityImages/foot2.jpg', 'is_primary' => false],
            ['path' => 'SportFacilityImages/foot3.jpg', 'is_primary' => false],
        ]);

        // Complexe Sportif Central (ID: 2) - Basketball images
        $this->addImagesForFacility(2, [
            ['path' => 'SportFacilityImages/bask1.jpg', 'is_primary' => true],
            ['path' => 'SportFacilityImages/bask2.jpg', 'is_primary' => false],
            ['path' => 'SportFacilityImages/bask3.jpg', 'is_primary' => false],
            ['path' => 'SportFacilityImages/bask4.jpg', 'is_primary' => false],
        ]);

        // Centre Sportif Olympique (ID: 3) - Tennis images
        $this->addImagesForFacility(3, [
            ['path' => 'SportFacilityImages/tennis1.jpg', 'is_primary' => true],
            ['path' => 'SportFacilityImages/tennis2.jpg', 'is_primary' => false],
        ]);

        // Espace Sportif Moderne (ID: 4) - Mixed sports images
        $this->addImagesForFacility(4, [
            ['path' => 'SportFacilityImages/foot4.jpg', 'is_primary' => true],
            ['path' => 'SportFacilityImages/foot5.jpg', 'is_primary' => false],
            ['path' => 'SportFacilityImages/foot6.jpg', 'is_primary' => false],
            ['path' => 'SportFacilityImages/foot7.jpg', 'is_primary' => false],
        ]);
    }

    /**
     * Add multiple images for a facility
     */
    private function addImagesForFacility(int $facilityId, array $images): void
    {
        foreach ($images as $image) {
            DB::table('images_facilities')->insert([
                'sport_facility_id' => $facilityId,
                'path' => $image['path'],
                'is_primary' => $image['is_primary'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
} 