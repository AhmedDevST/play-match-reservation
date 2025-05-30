<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\SportFacilityController;
use App\Http\Controllers\TimeSlotInstanceController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/test', function (Request $request) {
    return [
        'message' => 'hello world',
    ];
});


// Reservation
Route::get('/reservation/init', [ReservationController::class, 'init']);
Route::post('/reservation', [ReservationController::class, 'store']);

// Get facilities
Route::get('/sport-facilities', [SportFacilityController::class, 'index']);

// Time slots
Route::get('/sport-facilities/{facilityId}/available-time-slots', [TimeSlotInstanceController::class, 'getAvailableTimeSlots']);
Route::get('/sport-facilities/{facilityId}/init-time-slots', [TimeSlotInstanceController::class, 'initTimeSlotInstances']);

//init match
Route::get('/sport-facilities/{facilityId}/init-game', [GameController::class, 'initGame']);

// team
Route::get('/teams/search', [TeamController::class, 'search']);
