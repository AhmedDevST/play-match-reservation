<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('team_matches', function (Blueprint $table) {
            $table->id();
            $table->foreignId('team_id')->constrained()->onDelete('cascade');
            $table->foreignId('match_id')->constrained()->onDelete('cascade');
            $table->integer('score')->default(0);
            $table->boolean('is_winner')->default(false);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('team_matches');
    }
}; 