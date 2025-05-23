<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TimeZone extends Model
{
    protected $fillable = [
        'name',
        'start_time',
        'end_time',
    ];

    protected $casts = [
        'start_time' => 'datetime',
        'end_time' => 'datetime',
    ];

    /**
     * Get the time slot instances for this time zone.
     */
    public function timeSlotInstances(): HasMany
    {
        return $this->hasMany(TimeSlotInstance::class);
    }
} 