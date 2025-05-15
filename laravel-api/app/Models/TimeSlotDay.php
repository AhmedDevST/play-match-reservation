<?php

namespace App\Models;

use App\Enums\DayOfWeek;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TimeSlotDay extends Model
{
    use HasFactory;

    protected $table = 'time_slot_days';

    protected $fillable = [
        'time_slot_id',
        'day',
    ];

    protected $casts = [
        'day' => DayOfWeek::class,
    ];

    public function timeSlot(): BelongsTo
    {
        return $this->belongsTo(TimeSlot::class);
    }
} 