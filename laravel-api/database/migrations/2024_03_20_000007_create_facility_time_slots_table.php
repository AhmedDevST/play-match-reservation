<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('facility_time_slots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sport_facility_id')->constrained()->onDelete('cascade');
            $table->foreignId('time_slot_id')->constrained()->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('facility_time_slots');
    }
}; 