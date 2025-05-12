<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->json('statistics')->nullable();
            $table->enum('status', ['SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'])->default('SCHEDULED');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('matches');
    }
}; 