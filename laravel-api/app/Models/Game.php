<?php

namespace App\Models;

use App\Enums\MatchStatus;
use App\Enums\MatchType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Game  extends Model
{
    use HasFactory;

    protected $table = 'matches';
    protected $casts = [
        'status' => MatchStatus::class,
    ];
    protected $fillable = [
        'id',
        'status',
        'type',
    ];


    public function reservation()
    {
        return $this->hasOne(Reservation::class, 'match_id');
    }


    public function teamMatches(): HasMany
    {
        return $this->hasMany(TeamMatch::class, 'match_id');
    }
    public function invitations()
    {
        return $this->morphMany(Invitation::class, 'invitable');
    }

    public function scopePublicPendingMatches($query)
    {
        return $query->where([
            ['type', '=', MatchType::PUBLIC->value],
            ['status', '=', MatchStatus::PENDING]
        ]);
    }
}
