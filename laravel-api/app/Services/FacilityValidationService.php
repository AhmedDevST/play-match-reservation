<?php
namespace App\Services;

use App\Models\TimeSlotInstance;

class FacilityValidationService
{
    public function validateFacilityCompatibility(array $teams, TimeSlotInstance $timeSlot): array
    {
        $errors = [];
        $facilitySportIds = $timeSlot->recurringTimeSlot
            ->sportFacility
            ->sports
            ->pluck('id')
            ->toArray();

        if (!in_array($teams['team1']->sport_id, $facilitySportIds)) {
            $errors['team1.sport'] = 'Team 1 sport does not match the facility sports.';
        }

        if ($teams['team2'] && !in_array($teams['team2']->sport_id, $facilitySportIds)) {
            $errors['team2.sport'] = 'Team 2 sport does not match the facility sports.';
        }

        return $errors;
    }
}
