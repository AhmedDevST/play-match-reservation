<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserTeamSportLink extends Model
{
    use HasFactory;

    protected $table = 'user_team_sport_links';

    protected $fillable = [
        'user_id',
        'team_id',
        'sport_id',
        'start_date',
        'end_date',
        'has_left_team',
        'leave_reason',
        'is_captain',
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'has_left_team' => 'boolean',
        'is_captain' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    public function sport(): BelongsTo
    {
        return $this->belongsTo(Sport::class);
    }
} 