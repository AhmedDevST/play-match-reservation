<?php

namespace App\Models;

use App\Enums\DayOfWeek;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RecurringTimeSlot extends Model
{
    protected $fillable = [
        'sport_facility_id',
        'day',
        'start_time',
        'end_time',
        'duration_minutes',
    ];

    protected $casts = [
        'day' => DayOfWeek::class,
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'duration_minutes' => 'integer',
    ];

    /**
     * Get the sport facility that owns the recurring time slot.
     */
    public function sportFacility(): BelongsTo
    {
        return $this->belongsTo(SportFacility::class);
    }

    /**
     * Get the time slot instances for this recurring time slot.
     */
    public function timeSlotInstances(): HasMany
    {
        return $this->hasMany(TimeSlotInstance::class);
    }
} 