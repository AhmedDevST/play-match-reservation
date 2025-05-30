<?php

namespace App\Console\Commands;

use App\Enums\InvitationStatus;
use App\Enums\MatchStatus;
use App\Enums\ReservationStatus;
use App\Enums\TimeSlotsStatus;
use App\Enums\TypeInvitation;
use App\Models\Game;
use App\Models\Invitation;
use Illuminate\Console\Command;

class CancelExpiredInvitations extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:cancel-expired-invitations';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Command description';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // 1. Cancel pending MATCH invitations after 60 minutes
        $expiredInvitations = Invitation::where('type', TypeInvitation::MATCH->value)
            ->whereIn('status', [
                InvitationStatus::PENDING->value,
                InvitationStatus::REJECTED->value
            ])
            ->where('created_at', '<=', now()->subMinutes(5))
            ->get();


        foreach ($expiredInvitations as $invitation) {
            $invitation->status = InvitationStatus::CANCELED->value;
            $invitation->save();
            $match = $invitation->invitabl;
            if ($match instanceof Game  && $match->status === MatchStatus::PENDING) {
                $match->status = MatchStatus::CANCELLED;
                $match->save();
                $reservation = $match->reservation;
                if ($reservation) {
                    if ($reservation->auto_confirm === true) {
                        $reservation->status = ReservationStatus::CONFIRMED;
                    } else {
                        $reservation->status = ReservationStatus::CANCELLED;
                        // Set time slot back to available
                        $timeSlot = $reservation->timeSlotInstance;
                        if ($timeSlot) {
                            $timeSlot->status = TimeSlotsStatus::AVAILABLE;
                            $timeSlot->save();
                        }
                    }
                    $reservation->save();
                }
            }
        }

        // 2. Confirm accepted MATCH invitations
        $acceptedInvitations = Invitation::where('type', TypeInvitation::MATCH->value)
            ->where('status', InvitationStatus::ACCEPTED->value)
             ->where('created_at', '>', now()->subMinutes(5))
            ->get();

        foreach ($acceptedInvitations as $invitation) {
            $match = $invitation->invitabl;
            if ($match instanceof Game && $match->status === MatchStatus::PENDING) {
                $match->status = MatchStatus::CONFIRMED;
                $match->save();

                $reservation = $match->reservation;
                if ($reservation && $reservation->status === ReservationStatus::PENDING) {
                    $reservation->status = ReservationStatus::CONFIRMED;
                    $reservation->save();
                }
            }
        }

        $this->info('Expired invitations canceled and accepted invitations confirmed.');
    }
}
