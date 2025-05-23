<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Enums\ReservationStatus;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reservations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('time_slot_instance_id')->constrained()->cascadeOnDelete();
            $table->foreignId('match_id')->nullable()->constrained()->nullOnDelete();
            $table->dateTime('date');
            $table->decimal('total_price', 8, 2);
            $table->enum('status', array_column(ReservationStatus::cases(), 'value'))->default(ReservationStatus::PENDING->value);
            $table->timestamps(); // for created_at and updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
}; 