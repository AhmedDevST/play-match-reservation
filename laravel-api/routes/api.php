<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\SportFacilityController;
use App\Http\Controllers\TimeSlotInstanceController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\TeamController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


// Reservation
Route::get('/reservation/init', [ReservationController::class, 'init']);

// Get facilities
Route::get('/sport-facilities', [SportFacilityController::class, 'index']);

Route::get('/test-route', function () {
    return response()->json(['message' => 'Route works!']);
});


// Login user
Route::post('/login', [AuthController::class, 'login']);

// Register user
Route::post('/register', [AuthController::class, 'register']);