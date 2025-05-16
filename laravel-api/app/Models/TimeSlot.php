<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TimeSlot extends Model
{
    use HasFactory;

    protected $fillable = [
        'start_time',
        'end_time',
        'is_available',
    ];

    protected $casts = [
        'is_available' => 'boolean',
        // 'start_time' => 'datetime:H:i:s', // Optional: Cast to Carbon for time objects
        // 'end_time' => 'datetime:H:i:s',   // Optional: Cast to Carbon for time objects
    ];

    public function facilityTimeSlots(): HasMany
    {
        return $this->hasMany(FacilityTimeSlot::class);
    }

    public function timeSlotDays(): HasMany
    {
        return $this->hasMany(TimeSlotDay::class);
    }
} 