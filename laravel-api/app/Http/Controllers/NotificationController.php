<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Enums\NotificationType;
use App\Http\Resources\NotificationResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Créer une nouvelle notification
     */
    public function create($userId, $type, $title, $message, $notifiableId = null, $notifiableType = null)
    {
        try {
            // Créer la notification
            $notification = Notification::create([
                'user_id' => $userId,
                'type' => $type instanceof NotificationType ? $type : NotificationType::from($type),
                'title' => $title,
                'message' => $message,
                'is_read' => false,
                'notifiable_id' => $notifiableId,
                'notifiable_type' => $notifiableType,
            ]);

            return $notification;

        } catch (\Exception $e) {
            throw new \Exception('Erreur lors de la création de la notification: ' . $e->getMessage());
        }
    }

    /**
     * Créer une nouvelle notification via API
     */
    public function createFromRequest(Request $request)
    {
        // Validation des données
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'type' => 'required|in:friend_notification,team_notification,match_notification',
            'title' => 'required|string|max:255',
            'message' => 'required|string|max:1000',
            'notifiable_id' => 'nullable|integer',
            'notifiable_type' => 'nullable|string|max:255',
        ]);

        try {
            $notification = $this->create(
                $request->user_id,
                $request->type,
                $request->title,
                $request->message,
                $request->notifiable_id,
                $request->notifiable_type
            );

            return response()->json([
                'success' => true,
                'message' => 'Notification créée avec succès',
                'notification' => new NotificationResource($notification)
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer toutes les notifications d'un utilisateur
     */
    public function getUserNotifications()
    {
        try {
            $notifications = Notification::where('user_id', Auth::id())
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'notifications' => NotificationResource::collection($notifications)
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des notifications: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer une notification spécifique
     */
    public function getNotification($notificationId)
    {
        try {
            $notification = Notification::where('id', $notificationId)
                ->where('user_id', Auth::id())
                ->first();

            if (!$notification) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification non trouvée'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'notification' => new NotificationResource($notification)
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération de la notification: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Marquer une notification comme lue
     */
    public function markAsRead(Request $request, $notificationId)
    {
        try {
            $notification = Notification::where('id', $notificationId)
                ->where('user_id', Auth::id())
                ->first();

            if (!$notification) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification non trouvée'
                ], 404);
            }

            $notification->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => 'Notification marquée comme lue',
                'notification' => new NotificationResource($notification)
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de la notification: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Marquer toutes les notifications comme lues
     */
    public function markAllAsRead()
    {
        try {
            $updated = Notification::where('user_id', Auth::id())
                ->where('is_read', false)
                ->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => "Toutes les notifications ont été marquées comme lues",
                'updated_count' => $updated
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour des notifications: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer une notification
     */
    public function delete($notificationId)
    {
        try {
            $notification = Notification::where('id', $notificationId)
                ->where('user_id', Auth::id())
                ->first();

            if (!$notification) {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification non trouvée'
                ], 404);
            }

            $notification->delete();

            return response()->json([
                'success' => true,
                'message' => 'Notification supprimée avec succès'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression de la notification: ' . $e->getMessage()
            ], 500);
        }
    }
}