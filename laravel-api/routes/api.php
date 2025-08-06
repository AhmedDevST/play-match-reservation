<?php

use App\Http\Controllers\ReservationController;
use App\Http\Controllers\SportController;
use App\Http\Controllers\SportFacilityController;
use App\Http\Controllers\TimeSlotInstanceController;
use App\Http\Controllers\GameController;
use App\Http\Controllers\TeamController;
use App\Http\Controllers\UserTeamController;
use App\Http\Controllers\UserTeamDetailsController;
use App\Http\Controllers\Invitations\TeamInvitationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\InvitationController;
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


// facilities
Route::get('/sport-facilities', [SportFacilityController::class, 'index']);

// Time slots
Route::get('/sport-facilities/{facilityId}/available-time-slots', [TimeSlotInstanceController::class, 'getAvailableTimeSlots']);
Route::get('/sport-facilities/{facilityId}/init-time-slots', [TimeSlotInstanceController::class, 'initTimeSlotInstances']);






// team
Route::get('/teams/search', [TeamController::class, 'search']);


Route::get('/test-route', function () {
    return response()->json(['message' => 'Route works!']);
});

// Team routes
Route::get('/teams', [TeamController::class, 'index']);

//route create team
Route::post('/teams/createTeam', [UserTeamController::class, 'createTeam'])->middleware('auth:sanctum');


Route::get('/teams/my-teams', [TeamController::class, 'myTeams'])->middleware('auth:sanctum');

// Route pour récupérer les membres d'une équipe
Route::get('/teams/{teamId}/members', [UserTeamController::class, 'getTeamMembers'])->middleware('auth:sanctum');

//Route pour disband une équipe
Route::post('/teams/{teamId}/disband', [UserTeamController::class, 'disbandTeam'])->middleware('auth:sanctum');

//Route pour récupérer l'historique des équipes
Route::get('/teams/history', [UserTeamController::class, 'getUserTeamHistory'])->middleware('auth:sanctum');

//Route pour récupérer tous les membres d'une équipe (y compris équipes dissoutes)
Route::get('/teams/{teamId}/all-members', [UserTeamController::class, 'getAllTeamMembers'])->middleware('auth:sanctum');

//Route pour nettoyer les invitations orphelines
Route::post('/teams/cleanup-invitations', [UserTeamController::class, 'cleanupOrphanedInvitations'])->middleware('auth:sanctum');

// Login user
Route::post('/login', [AuthController::class, 'login']);

// Register user
Route::post('/register', [AuthController::class, 'register']);

// Routes de test (sans authentification)
Route::post('/teams/test-create-team', [UserTeamController::class, 'createTeamTest']);

Route::get('/users/search', [UserController::class, 'search']);

// Get all users
Route::get('/users', [UserController::class, 'index']);

Route::middleware('auth:sanctum')->group(function () {
    // Routes pour les invitations d'équipe
    Route::prefix('teams/invitations')->group(function () {
        Route::post('/send', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'send']);
        Route::get('/pending', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'getPendingInvitations']);
        Route::post('/{invitation}/respond', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'respond']);
    });

    // Get invited users for a specific team
    Route::get('/team/{team}/invited-users', [App\Http\Controllers\Invitations\TeamInvitationController::class, 'getInvitedUsers']);

    // Team Invitations
    Route::get('/teams/{team}/available-users', [TeamInvitationController::class, 'getUsersNotInTeamOrInvited']);

    // User Team Details - Détails d'un utilisateur dans une équipe
    Route::get('/teams/{team}/users/{user}/details', [UserTeamDetailsController::class, 'getUserTeamDetails']);

    // Route pour récupérer les informations de l'utilisateur connecté
    Route::get('/user/profile', [UserController::class, 'getProfile'])->middleware('auth:sanctum');

    //reservations
    Route::get('/user/reservations', [ReservationController::class, 'getUserReservations']);
    Route::post('/reservation', [ReservationController::class, 'store']);

    //games
    Route::get('/sport-facilities/{facilityId}/init-game', [GameController::class, 'initGame']);
    // Get public pending matches
    Route::get('/games/public-pending', [GameController::class, 'getPublicPendingMatches']);



    //update staus invitation
    Route::patch('/invitations/{id}/status', [InvitationController::class, 'updateStatus']);

    // Routes pour les notifications
    Route::prefix('notifications')->group(function () {
        Route::post('/create', [App\Http\Controllers\NotificationController::class, 'createFromRequest']);
        Route::get('/user', [App\Http\Controllers\NotificationController::class, 'getUserNotifications']);
        Route::get('/{notificationId}', [App\Http\Controllers\NotificationController::class, 'getNotification']);
        Route::patch('/{notificationId}/read', [App\Http\Controllers\NotificationController::class, 'markAsRead']);
        Route::patch('/mark-all-read', [App\Http\Controllers\NotificationController::class, 'markAllAsRead']);
        Route::delete('/{notificationId}', [App\Http\Controllers\NotificationController::class, 'delete']);
    });
});

//init match
Route::get('/games/{game}', [GameController::class, 'show']);
//invitations

Route::post('/invitations', [InvitationController::class, 'store']);


Route::get('/users/available', [UserController::class, 'getAvailableUsers'])->middleware('auth:sanctum');


Route::post('/invitations/send', [InvitationController::class, 'sendFriendInvitation'])->middleware('auth:sanctum');

// get user fri
Route::get('/users/friends', [UserController::class, 'getFriends'])->middleware('auth:sanctum');
