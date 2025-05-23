<?php

use App\Enums\DayOfWeek;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up() {
        Schema::create('recurring_time_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sport_facility_id')->constrained('sport_facilities')->onDelete('cascade');
            $table->enum('day', array_column(DayOfWeek::cases(), 'value'));
            $table->time('start_time');
            $table->time('end_time');
            $table->integer('duration_minutes');
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('recurring_time_slots');
    }
}; 