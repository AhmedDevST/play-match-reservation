<?php

namespace App\Http\Requests;

use App\Enums\TypeInvitation;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Enum;
use Illuminate\Support\Facades\Auth;

class StoreInvitationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return Auth::user() !== null;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'type' => ['required', new Enum(TypeInvitation::class)],
            'invitable_id' => ['nullable', 'integer'],
            'receiver_id' => [
                'required',
                'integer',
                'exists:users,id',
                function ($attribute, $value, $fail) {
                    if ($value === $this->user()->id) {
                        $fail('You cannot send an invitation to yourself.');
                    }
                }
            ],
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages(): array
    {
        return [
            'type.required' => 'The invitation type is required.',
            'receiver_id.required' => 'The receiver is required.',
            'receiver_id.exists' => 'The selected receiver does not exist.',
            'invitable_id.integer' => 'The invitable ID must be a number.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     *
     * @return array
     */
    public function attributes(): array
    {
        return [
            'type' => 'invitation type',
            'receiver_id' => 'receiver',
            'invitable_id' => 'invitable ID',
        ];
    }
}
