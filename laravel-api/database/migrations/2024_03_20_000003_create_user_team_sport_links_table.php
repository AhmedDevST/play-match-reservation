<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_team_sport_links', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('sport_id')->constrained()->onDelete('cascade');
            $table->dateTime('start_date');
            $table->dateTime('end_date')->nullable();
            $table->boolean('has_left_team')->default(false);
            $table->string('leave_reason')->nullable();
            $table->boolean('is_captain')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_team_sport_links');
    }
}; 