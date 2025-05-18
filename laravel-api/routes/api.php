<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\SportFacilityController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


// Reservation
Route::get('/reservation/init', [ReservationController::class, 'init']);

// Get facilities
Route::get('/sport-facilities', [SportFacilityController::class, 'index']);

