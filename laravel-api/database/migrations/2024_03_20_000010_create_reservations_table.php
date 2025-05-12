<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('reservations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('facility_time_slot_id')->constrained()->onDelete('cascade');
            $table->foreignId('match_id')->nullable()->constrained()->onDelete('set null');
            $table->dateTime('date');
            $table->decimal('total_price', 10, 2);
            $table->enum('status', ['PENDING', 'CONFIRMED', 'PAID', 'CANCELLED', 'COMPLETED', 'NO_SHOW'])->default('PENDING');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('reservations');
    }
}; 