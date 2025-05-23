<?php

namespace App\Models;

use App\Enums\TimeSlotsStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimeSlotInstance extends Model
{
    protected $fillable = [
        'date',
        'start_time',
        'end_time',
        'recurring_time_slot_id',
        'time_zone_id',
        'status',
        'is_exception',
        'exception_reason',
    ];

    protected $casts = [
        'date' => 'date',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'status' => TimeSlotsStatus::class,
        'is_exception' => 'boolean',
    ];

    /**
     * Get the recurring time slot that owns the time slot instance.
     */
    public function recurringTimeSlot(): BelongsTo
    {
        return $this->belongsTo(RecurringTimeSlot::class);
    }

    /**
     * Get the time zone that owns the time slot instance.
     */
    public function timeZone(): BelongsTo
    {
        return $this->belongsTo(TimeZone::class);
    }
} 