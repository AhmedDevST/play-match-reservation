<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\SportController;
use App\Http\Controllers\SportFacilityController;
use App\Http\Controllers\TimeSlotInstanceController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\UserTeamController;
use App\Http\Controllers\Invitations\TeamInvitationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// CreateTeam
Route::post('/UserTeam', [UserTeamController::class, 'createTeam']);

// Get Sports
Route::get('/sports', [SportController::class, 'index']);

// Reservation
Route::get('/reservation/init', [ReservationController::class, 'init']);

// Get facilities
Route::get('/sport-facilities', [SportFacilityController::class, 'index']);

Route::get('/test-route', function () {
    return response()->json(['message' => 'Route works!']);
});

// Team routes
Route::get('/teams', [TeamController::class, 'index']);

// Test mode team operations
Route::post('/teams/test-create-team', [UserTeamController::class, 'createTeamTest']);


Route::get('/teams/my-teams', [TeamController::class, 'myTeams'])->middleware('auth:sanctum');


// Route de test pour l'utilisateur 1
Route::get('/teams/test-my-teams', [TeamController::class, 'testMyTeams']);
// Login user
Route::post('/login', [AuthController::class, 'login']);

// Register user
Route::post('/register', [AuthController::class, 'register']);

// Routes de test (sans authentification)
Route::post('/teams/test-create-team', [UserTeamController::class, 'createTeamTest']);

Route::get('/users/search', [UserController::class, 'search']);

// Get all users
Route::get('/users', [UserController::class, 'index']);

// Routes pour les invitations d'équipe
Route::prefix('teams/invitations')->group(function () {
    Route::post('/send', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'send']);
    Route::get('/pending', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'getPendingInvitations']);
    Route::post('/{invitation}/respond', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'respond']);
    //get invited users for a specific team

});
    // Get invited users for a specific team
    Route::get('/team/{team}/invited-users', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'getInvitedUsers']);


