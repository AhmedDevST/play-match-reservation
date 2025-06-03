<?php

namespace App\Models;

use App\Enums\MatchStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

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
}
