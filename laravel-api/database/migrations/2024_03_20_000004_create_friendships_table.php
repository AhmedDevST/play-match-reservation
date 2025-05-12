<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('friendships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('requester_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('addressee_id')->constrained('users')->onDelete('cascade');
            $table->enum('status', ['PENDING', 'ACCEPTED', 'REJECTED', 'BLOCKED'])->default('PENDING');
            $table->dateTime('requested_at');
            $table->dateTime('accepted_at')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('friendships');
    }
}; 