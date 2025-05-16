<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FacilityImage extends Model
{
    use HasFactory;

    protected $table = 'images_facilities';

    protected $fillable = [
        'sport_facility_id',
        'path',
        'is_primary',
    ];

    protected $casts = [
        'is_primary' => 'boolean',
    ];

    public function sportFacility(): BelongsTo
    {
        return $this->belongsTo(SportFacility::class);
    }
} 