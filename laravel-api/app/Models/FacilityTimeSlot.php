<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class FacilityTimeSlot extends Model
{
    use HasFactory;

    protected $table = 'facility_time_slots';

    protected $fillable = [
        'sport_facility_id',
        'time_slot_id',
    ];

    public function sportFacility(): BelongsTo
    {
        return $this->belongsTo(SportFacility::class);
    }

    public function timeSlot(): BelongsTo
    {
        return $this->belongsTo(TimeSlot::class);
    }

    public function reservations(): HasMany
    {
        return $this->hasMany(Reservation::class);
    }
} 