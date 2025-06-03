<?php
namespace Database\Seeders;

use App\Enums\DayOfWeek;
use App\Models\RecurringTimeSlot;
use App\Models\SportFacility;
use App\Models\TimeZone;
use Illuminate\Database\Seeder;

class RecurringTimeSlotSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // First, create some sample time zones
        $this->createTimeZones();

        // Finally, create recurring time slots
        $this->createRecurringTimeSlots();
    }

    private function createTimeZones(): void
    {
        $timeZones = [
            ['name' => 'Morning', 'start_time' => '06:00:00', 'end_time' => '12:00:00'],
            ['name' => 'Afternoon', 'start_time' => '12:00:00', 'end_time' => '18:00:00'],
            ['name' => 'Evening', 'start_time' => '18:00:00', 'end_time' => '23:00:00'],
        ];

        foreach ($timeZones as $timeZone) {
            TimeZone::firstOrCreate(
                ['name' => $timeZone['name']],
                $timeZone
            );
        }
    }

    private function createRecurringTimeSlots(): void
    {
        $facilities = SportFacility::all();

        if ($facilities->isEmpty()) {
            $this->command->warn('No sport facilities found. Creating sample facilities first.');
            return;
        }

        $timeSlotTemplates = [
            // Weekday templates
            ['start_time' => '08:00:00', 'end_time' => '12:00:00', 'duration' => 60, 'days' => ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']],
            ['start_time' => '14:00:00', 'end_time' => '18:00:00', 'duration' => 90, 'days' => ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']],
            ['start_time' => '19:00:00', 'end_time' => '22:00:00', 'duration' => 60, 'days' => ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']],

            // Weekend templates
            ['start_time' => '09:00:00', 'end_time' => '13:00:00', 'duration' => 120, 'days' => ['saturday', 'sunday']],
            ['start_time' => '15:00:00', 'end_time' => '20:00:00', 'duration' => 90, 'days' => ['saturday', 'sunday']],
        ];

        foreach ($facilities as $facility) {
            foreach ($timeSlotTemplates as $template) {
                foreach ($template['days'] as $day) {
                    RecurringTimeSlot::firstOrCreate([
                        'sport_facility_id' => $facility->id,
                        'day' => $day,
                        'start_time' => $template['start_time'],
                        'end_time' => $template['end_time'],
                        'duration_minutes' => $template['duration'],
                    ]);
                }
            }
        }

        $this->command->info('Recurring time slots created successfully.');
    }
}
