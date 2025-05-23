<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Enums\DayOfWeek;
use App\Enums\TimeSlotsStatus;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {

        Schema::create('time_slot_instances', function (Blueprint $table) {
            $table->id();
            $table->date('date');
            $table->time('start_time');
            $table->time('end_time');
            $table->foreignId('recurring_time_slot_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('time_zone_id')->nullable()->constrained()->nullOnDelete();
            $table->enum('status', array_column(TimeSlotsStatus::cases(), 'value'))->default(TimeSlotsStatus::AVAILABLE->value);
            $table->boolean('is_exception')->default(false);
            $table->string('exception_reason')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('time_slot_instances');
    }
};
