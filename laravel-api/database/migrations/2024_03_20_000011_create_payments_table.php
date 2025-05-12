<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('reservation_id')->constrained()->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->enum('status', ['PENDING', 'COMPLETED', 'FAILED', 'REFUNDED', 'PARTIAL'])->default('PENDING');
            $table->enum('method', ['CREDIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'IN_APP_WALLET', 'CASH'])->default('CREDIT_CARD');
            $table->dateTime('timestamp');
            $table->json('receipt_data')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('payments');
    }
}; 