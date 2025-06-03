<?php

namespace App\Http\Controllers;

use App\Models\Team;
use App\Models\User;
use App\Models\UserTeamLink;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Carbon;

class UserTeamDetailsController extends Controller
{
    /**
     * Récupérer les détails d'un utilisateur dans une équipe spécifique
     */
    public function getUserTeamDetails(Team $team, User $user)
    {
        // Vérifier si l'utilisateur connecté est membre de cette équipe
        $currentUserTeamLink = $team->userTeamLinks()
            ->where('user_id', Auth::id())
            ->where('has_left_team', false)
            ->first();

        if (!$currentUserTeamLink) {
            return response()->json([
                'message' => 'Vous devez être membre de cette équipe pour voir les détails des autres membres'
            ], 403);
        }

        // Récupérer le lien utilisateur-équipe pour l'utilisateur demandé
        $userTeamLink = $team->userTeamLinks()
            ->where('user_id', $user->id)
            ->with(['user', 'team.sport'])
            ->first();

        if (!$userTeamLink) {
            return response()->json([
                'message' => 'Cet utilisateur n\'est pas membre de cette équipe'
            ], 404);
        }

        // Préparer les données utilisateur (sans informations sensibles)
        $safeUserData = [
            'id' => $user->id,
            'username' => $user->username,
            'profile_picture' => $user->profile_picture,
            // Ne pas inclure l'email, le mot de passe, etc.
        ];

        // Calculer les statistiques de l'équipe pour cet utilisateur
        $teamStats = $this->calculateTeamStats($userTeamLink);

        // Préparer l'historique (événements importants)
        $teamHistory = $this->getTeamHistory($userTeamLink);

        return response()->json([
            'data' => [
                'user' => $safeUserData,
                'team_link' => [
                    'id' => $userTeamLink->id,
                    'user' => $safeUserData,
                    'team' => [
                        'id' => $userTeamLink->team->id,
                        'name' => $userTeamLink->team->name,
                        'image' => $userTeamLink->team->image,
                        'total_score' => $userTeamLink->team->total_score,
                        'average_rating' => $userTeamLink->team->average_rating,
                        'sport' => [
                            'id' => $userTeamLink->team->sport->id,
                            'name' => $userTeamLink->team->sport->name,
                            'max_players' => $userTeamLink->team->sport->max_players,
                            'min_players' => $userTeamLink->team->sport->min_players ?? 1,
                            'image' => $userTeamLink->team->sport->image,
                        ],
                    ],
                    'start_date' => $userTeamLink->start_date->toISOString(),
                    'end_date' => $userTeamLink->end_date?->toISOString(),
                    'has_left_team' => $userTeamLink->has_left_team,
                    'leave_reason' => $userTeamLink->leave_reason,
                    'is_captain' => $userTeamLink->is_captain,
                ],
                'team_stats' => $teamStats,
                'team_history' => $teamHistory,
            ]
        ]);
    }

    /**
     * Calculer les statistiques de l'utilisateur dans l'équipe
     */
    private function calculateTeamStats(UserTeamLink $userTeamLink): array
    {
        $now = Carbon::now();
        $startDate = Carbon::parse($userTeamLink->start_date);
        $endDate = $userTeamLink->end_date ? Carbon::parse($userTeamLink->end_date) : $now;

        // Calculer le nombre de jours dans l'équipe (arrondi à l'entier supérieur)
        $daysInTeam = (int) ceil($startDate->diffInDays($endDate));
        
        // Si c'est 0, au moins compter 1 jour (aujourd'hui)
        if ($daysInTeam === 0) {
            $daysInTeam = 1;
        }

        // TODO: Ajouter d'autres statistiques quand les modèles de match seront disponibles
        // Pour l'instant, on retourne des données basiques
        $stats = [
            'days_in_team' => $daysInTeam,
            'matches_played' => 0, // À implémenter avec le modèle Match
            'matches_won' => 0,    // À implémenter avec le modèle Match
            'goals_scored' => 0,   // À implémenter avec le modèle Match
        ];

        return $stats;
    }

    /**
     * Récupérer l'historique des événements importants de l'utilisateur dans l'équipe
     */
    private function getTeamHistory(UserTeamLink $userTeamLink): array
    {
        $history = [];

        // Événement de rejointe de l'équipe
        $history[] = [
            'event' => $userTeamLink->is_captain ? 'Création de l\'équipe' : 'A rejoint l\'équipe',
            'date' => $userTeamLink->start_date->toISOString(),
            'type' => 'join'
        ];

        // Événement de départ si applicable
        if ($userTeamLink->has_left_team && $userTeamLink->end_date) {
            $history[] = [
                'event' => 'A quitté l\'équipe',
                'date' => $userTeamLink->end_date->toISOString(),
                'type' => 'leave',
                'reason' => $userTeamLink->leave_reason
            ];
        }

        // TODO: Ajouter d'autres événements (promotion capitaine, matchs importants, etc.)

        // Trier par date décroissante (plus récent en premier)
        usort($history, function ($a, $b) {
            return strtotime($b['date']) - strtotime($a['date']);
        });

        return $history;
    }
}
