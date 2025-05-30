<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Team extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'total_score',
        'image',
        'average_rating',
        'sport_id',
    ];

    protected $casts = [
        'average_rating' => 'double',
        'total_score' => 'integer',
    ];

    public function userTeamLinks(): HasMany
    {
        return $this->hasMany(UserTeamLink::class);
    }
    public function sport(): BelongsTo
    {
        return $this->belongsTo(Sport::class);
    }
    public function teamMatches(): HasMany
    {
        return $this->hasMany(TeamMatch::class);
    }
    public function players()
    {
        return $this->belongsToMany(User::class, 'user_team_links');
    }

    public function captain()
    {
        return $this->hasOne(UserTeamLink::class)
            ->where('is_captain', true)
            ->where('has_left_team', false);
    }
}
