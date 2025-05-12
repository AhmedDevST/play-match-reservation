<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sport_facilities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('address');
            $table->text('description')->nullable();
            $table->decimal('price_per_hour', 10, 2);
            $table->decimal('rating', 3, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sport_facilities');
    }
}; 