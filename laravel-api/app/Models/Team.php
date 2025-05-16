<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Team extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'total_score',
        'image',
        'average_rating',
    ];

    protected $casts = [
        'average_rating' => 'double',
        'total_score' => 'integer',
    ];

    public function userTeamSportLinks(): HasMany
    {
        return $this->hasMany(UserTeamSportLink::class);
    }

    public function teamMatches(): HasMany
    {
        return $this->hasMany(TeamMatch::class);
    }

}
