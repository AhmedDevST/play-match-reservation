<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('sport_facilities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->json('address'); 
            $table->text('description')->nullable();
            $table->decimal('price_per_hour', 8, 2);
            $table->double('rating')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sport_facilities');
    }
}; 