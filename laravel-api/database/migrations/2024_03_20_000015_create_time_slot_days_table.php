<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('time_slot_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('time_slot_id')->constrained()->onDelete('cascade');
            $table->foreignId('day_id')->constrained()->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('time_slot_days');
    }
}; 