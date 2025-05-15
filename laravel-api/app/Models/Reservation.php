<?php

namespace App\Models;

use App\Enums\ReservationStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Reservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'facility_time_slot_id',
        'match_id', // Corresponds to game_id conceptually
        'date',
        'total_price',
        'status',
    ];

    protected $casts = [
        'date' => 'datetime',
        'total_price' => 'decimal:2',
        'status' => ReservationStatus::class,
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function facilityTimeSlot(): BelongsTo
    {
        return $this->belongsTo(FacilityTimeSlot::class);
    }

    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class, 'match_id'); // FK in db is match_id
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }
} 