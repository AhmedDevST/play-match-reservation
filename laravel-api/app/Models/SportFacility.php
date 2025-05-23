<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class SportFacility extends Model
{
    use HasFactory;

    protected $table = 'sport_facilities';

    protected $fillable = [
        'name',
        'address',
        'description',
        'price_per_hour',
        'rating',
    ];

    protected $casts = [
        'price_per_hour' => 'decimal:2',
        'rating' => 'double',
    ];

    public function images(): HasMany
    {
        return $this->hasMany(FacilityImage::class);
    }

    public function recurringTimeSlots(): HasMany
    {
        return $this->hasMany(RecurringTimeSlot::class);
    }

    public function sports(): BelongsToMany
    {
        return $this->belongsToMany(Sport::class, 'facility_sport');
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }
}
