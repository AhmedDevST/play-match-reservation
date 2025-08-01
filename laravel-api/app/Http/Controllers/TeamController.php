<?php

namespace App\Http\Controllers;

use App\Http\Resources\TeamResource;
use App\Models\Team;
use App\Models\UserTeamLink;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class TeamController extends Controller
{
    /**
     * Afficher la liste des équipes
     */
    public function index()
    {
        $teams = Team::with(['captain', 'members', 'sport'])->paginate(10);
        return TeamResource::collection($teams);
    }

    /**
     * Créer une nouvelle équipe
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:teams',
            'description' => 'nullable|string',
            'sport_id' => 'required|exists:sports,id',
            'max_members' => 'required|integer|min:1'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $team = Team::create([
            'name' => $request->name,
            'description' => $request->description,
            'sport_id' => $request->sport_id,
            'max_members' => $request->max_members,
            'captain_id' => Auth::id()
        ]);

        return new TeamResource($team);
    }

    /**
     * Afficher les détails d'une équipe spécifique
     */
    public function show(Team $team)
    {
        return new TeamResource($team->load(['captain', 'members', 'sport']));
    }

    /**
     * Mettre à jour une équipe
     */
    public function update(Request $request, Team $team)
    {
        // Vérifier si l'utilisateur est le capitaine
        if ($team->captain_id !== Auth::id()) {
            return response()->json([
                'message' => 'Unauthorized. Only team captain can update the team.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255|unique:teams,name,' . $team->id,
            'description' => 'nullable|string',
            'sport_id' => 'exists:sports,id',
            'max_members' => 'integer|min:1'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $team->update($request->all());

        return new TeamResource($team);
    }

    /**
     * Supprimer une équipe
     */
    public function destroy(Team $team)
    {
        // Vérifier si l'utilisateur est le capitaine
        if ($team->captain_id !== Auth::id()) {
            return response()->json([
                'message' => 'Unauthorized. Only team captain can delete the team.'
            ], 403);
        }

        $team->delete();

        return response()->json([
            'message' => 'Team successfully deleted'
        ]);
    }

    public function search(Request $request)
    {
        $name = $request->input('name');
        $sportId = $request->input('sport');
        $limit = $request->input('limit', 10);
        $selectedTeamId = $request->input('exclude');

        $teams = Team::with('sport')
            ->when($name, fn($query) => $query->where('name', 'like', '%' . $name . '%'))
            ->when($sportId, fn($query) => $query->where('sport_id', $sportId))
            ->when($selectedTeamId, fn($query) => $query->where('id', '!=', $selectedTeamId))
            ->limit($limit)
            ->get();

        return response()->json(
            [
                'teams' => TeamResource::collection($teams),
            ]
        );
    }

    /**
     * Ajouter un membre à l'équipe
     */
    public function addMember(Request $request, Team $team)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Vérifier si l'équipe est pleine
        if ($team->members()->count() >= $team->max_members) {
            return response()->json([
                'message' => 'Team is full'
            ], 400);
        }

        // Vérifier si l'utilisateur est déjà membre
        if ($team->members()->where('user_id', $request->user_id)->exists()) {
            return response()->json([
                'message' => 'User is already a team member'
            ], 400);
        }

        $team->members()->attach($request->user_id);

        return new TeamResource($team->load(['captain', 'members', 'sport']));
    }

    /**
     * Retirer un membre de l'équipe
     */
    public function removeMember(Request $request, Team $team)
    {
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // Vérifier si l'utilisateur est le capitaine ou se retire lui-même
        if ($team->captain_id !== Auth::id() && $request->user_id !== Auth::id()) {
            return response()->json([
                'message' => 'Unauthorized. Only team captain can remove members.'
            ], 403);
        }

        // Empêcher le retrait du capitaine
        if ($request->user_id === $team->captain_id) {
            return response()->json([
                'message' => 'Cannot remove team captain'
            ], 400);
        }

        $team->members()->detach($request->user_id);

        return new TeamResource($team->load(['captain', 'members', 'sport']));
    }

    /**
     * Liste des membres d'une équipe
     */
    public function members(Team $team)
    {
        return response()->json([
            'members' => $team->members,
            'captain' => $team->captain
        ]);
    }

    /**
     * Get teams where the authenticated user is captain
     */
    public function myTeams()
    {
        $user = Auth::user();

        // Get all teams where the user is a member (not just captain)
        $userTeams = UserTeamLink::where('user_id', $user->id)
            ->pluck('team_id');

        // Get all UserTeamLink objects for these teams with team and user data
        $userTeamLinks = UserTeamLink::with(['team' => function($query) {
                $query->with('sport');
            }, 'user'])
            ->whereIn('team_id', $userTeams)
            ->where('has_left_team', false)
            ->get();

        return response()->json([
            'data' => $userTeamLinks
        ]);
    }


    // La fonction getTeamUsers a été déplacée vers TeamUserController
}
