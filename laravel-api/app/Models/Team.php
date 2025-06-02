<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphMany;

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

    protected $appends = ['full_image_path'];

    public function getFullImagePathAttribute()
    {
        if (!$this->image) {
            return null;
        }
        if (str_starts_with($this->image, 'http')) {
            return $this->image;
        }
        return env('APP_URL') . '/storage/' . ltrim($this->image, '/');
    }

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
    public function invitations(): MorphMany
    {
        return $this->morphMany(Invitation::class, 'invitable');
    }
      public function players()
    {
        return $this->belongsToMany(User::class, 'user_team_links')
            ->withPivot('is_captain', 'has_left_team');
    }

    public function captain()
    {
        return $this->hasOne(UserTeamLink::class)
            ->where('is_captain', true)
            ->where('has_left_team', false);
    }
}
