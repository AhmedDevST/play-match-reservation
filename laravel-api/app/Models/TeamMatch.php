<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TeamMatch extends Model
{
    use HasFactory;

    protected $table = 'team_matches';

    protected $fillable = [
        'team_id',
        'match_id', 
        'score',
        'is_winner',
    ];

    protected $casts = [
        'score' => 'integer',
        'is_winner' => 'boolean',
    ];

    public function team(): BelongsTo
    {
        return $this->belongsTo(Team::class);
    }

    public function game(): BelongsTo
    {
        return $this->belongsTo(Game::class, 'match_id'); // FK in db is match_id
    }
}
