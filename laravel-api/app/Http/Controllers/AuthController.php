<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    //
     public function login(Request $request)
    {
        
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Identifiants invalides'
            ], 401);
        }

        $user = User::where('email', $request->email)->first();

        $token = $user->createToken('mobile_token')->plainTextToken;

        try {
            
            return response()->json([
            'message' => 'Connexion réussie',
            'token' => $token,
            'user' => $user
            ]);
        } catch (\Exception $e) {
            return response()->json([
            'message' => 'Erreur lors de l\'authentification',
            'error' => $e->getMessage()
            ], 500);
        }
    }

    public function register(Request $request)
{
    // Valider les données d'entrée
    $validator = Validator::make($request->all(), [
        'username' => 'required|string|max:255',
        'email' => 'required|string|email|max:255|unique:users',
        'password' => 'required|string|min:6|confirmed',
        
    ]);

    if ($validator->fails()) {

    logger()->info('Validation failed for name: ' . $request->username, $validator->errors()->toArray());
        return response()->json([
            'errors' => $validator->errors()
        ], 422);
    }

    //  Créer l'utilisateur
    $user = \App\Models\User::create([
        'email' => $request->email,
        'username' => $request->username,
        'password' => Hash::make($request->password),
    ]);

    //  Créer un token
    $token = $user->createToken('mobile_token')->plainTextToken;

    return response()->json([
        'message' => 'Utilisateur enregistré avec succès',
        'token' => $token,
        'user' => $user
    ]);
}

}
