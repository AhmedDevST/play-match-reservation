<?php

use App\Enums\MatchStatus;
use App\Enums\MatchType;
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
        Schema::table('matches', function (Blueprint $table) {
              $table->enum('type', array_column(MatchType::cases(), 'value'))->after('id');
              $table->enum('status', array_column(MatchStatus::cases(), 'value'))->after('type')->default(MatchStatus::PENDING->value);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('matches', function (Blueprint $table) {
            $table->dropColumn(['type', 'status']);
        });
    }
};
