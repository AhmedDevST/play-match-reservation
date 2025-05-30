<?php

namespace App\Models;

use App\Enums\InvitationStatus;
use App\Enums\TypeInvitation;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Invitation extends Model
{
    use HasFactory;

    protected $fillable = [
        'sender_id',
        'receiver_id',
        'type',
        'status'
    ];

    protected $casts = [
        'type' => TypeInvitation::class,
        'status' => InvitationStatus::class,
    ];

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'receiver_id');
    }
    public function invitabl()
    {
        return $this->morphTo();
    }
}
