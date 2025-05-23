<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Sport extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'image',
        'min_players',
        'max_players',
    ];

    protected $casts = [
        'min_players' => 'integer',
        'max_players' => 'integer',
    ];

    public function teams(): HasMany
    {
        return $this->hasMany(Team::class);
    }

    public function sportFacilities(): BelongsToMany
    {
        return $this->belongsToMany(SportFacility::class, 'facility_sport');
    }

    public function matches(): HasMany
    {
        return $this->hasMany(Game::class);
    }
}
