<?php

namespace App\Http\Controllers;

use App\Models\Sport;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Http\Resources\SportResource;

class SportController extends Controller
{
    /**
     * Récupère la liste de tous les sports
     *
     * @return JsonResponse
     */
    public function index(): JsonResponse
    {
        try {
            $sports = Sport::all();
            
            // Log the sports data for debugging
            \Log::debug('Sports retrieved:', ['count' => $sports->count(), 'sports' => $sports->toArray()]);
            
            $resource = SportResource::collection($sports);
            
            // Log the transformed resource
            \Log::debug('Sports resource:', ['resource' => $resource->response()->getData(true)]);
            
            return response()->json([
                'sports' => $resource
            ]);
        } catch (\Exception $e) {
            // Log the full error
            \Log::error('Error in sports index:', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur lors de la récupération des sports: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupère un sport spécifique par son ID
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        try {
            $sport = Sport::findOrFail($id);
            return response()->json([
                'status' => 'success',
                'data' => new SportResource($sport)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Sport non trouvé'
            ], 404);
        }
    }

    /**
     * Crée un nouveau sport
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255|unique:sports',
                'image' => 'nullable|string',
                'min_players' => 'required|integer|min:1',
                'max_players' => 'required|integer|min:1|gt:min_players'
            ]);

            $sport = Sport::create($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Sport créé avec succès',
                'data' => new SportResource($sport)
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur lors de la création du sport: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Met à jour un sport existant
     *
     * @param Request $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(Request $request, int $id): JsonResponse
    {
        try {
            $sport = Sport::findOrFail($id);

            $validated = $request->validate([
                'name' => 'required|string|max:255|unique:sports,name,' . $id,
                'image' => 'nullable|string',
                'min_players' => 'required|integer|min:1',
                'max_players' => 'required|integer|min:1|gt:min_players'
            ]);

            $sport->update($validated);

            return response()->json([
                'status' => 'success',
                'message' => 'Sport mis à jour avec succès',
                'data' => new SportResource($sport)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur lors de la mise à jour du sport: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprime un sport
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        try {
            $sport = Sport::findOrFail($id);
            $sport->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Sport supprimé avec succès'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Erreur lors de la suppression du sport: ' . $e->getMessage()
            ], 500);
        }
    }
}
