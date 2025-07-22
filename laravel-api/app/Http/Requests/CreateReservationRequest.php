<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Enum;
use App\Enums\MatchType;
use Illuminate\Support\Facades\Auth;

class CreateReservationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Auth::user() !== null;
    }

    public function rules(): array
    {
        $rules = [
            'time_slot_id' => [
                'required',
                Rule::exists('time_slot_instances', 'id')->where('status', 'available'),
            ],
            'is_match' => 'boolean',
        ];

        // Add match-specific validation if is_match is true
        if ($this->isMatchReservation()) {
            $rules['match_type'] = ['required', new Enum(MatchType::class)];
            $rules['team1_id'] = 'required|exists:teams,id';
            $rules['team2_id'] = 'nullable|exists:teams,id';
            $rules['auto_confirm'] = 'boolean';
        }

        return $rules;
    }

    public function messages(): array
    {
        return [
            'time_slot_id.exists' => 'The selected time slot is not available.',
            'match_type.required' => 'Match type is required for match reservations.',
            'match_type.in' => 'Match type must be either private or public.',
            'team1_id.required' => 'Team 1 is required for match reservations.',
        ];
    }

    // Helper method to determine if this is a match reservation
    public function isMatchReservation(): bool
    {
        return $this->input('is_match', false) || $this->has('match_type');
    }
}
