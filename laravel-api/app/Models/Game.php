<?php

namespace App\Models;

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



    public function reservation(): HasOne
    {
        return $this->hasOne(Reservation::class);
    }

    public function teamMatches(): HasMany
    {
        return $this->hasMany(TeamMatch::class);
    }

}
