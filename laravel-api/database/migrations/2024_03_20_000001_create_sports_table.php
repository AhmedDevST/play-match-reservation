<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sports', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('icon');
            $table->integer('min_players');
            $table->integer('max_players');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sports');
    }
}; 