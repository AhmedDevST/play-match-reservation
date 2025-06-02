<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

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

        // Store the remember token if 'remember' is true
        if ($request->has('remember') && $request->remember) {
            $user->remember_token = $token;
            $user->save();
        }

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
            'profile_picture' => 'nullable|string|regex:/^data:image\/[^;]+;base64,/'
        ]);

        if ($validator->fails()) {
            logger()->info('Validation failed for name: ' . $request->username, $validator->errors()->toArray());
            return response()->json([
                'errors' => $validator->errors()
            ], 422);
        }

        // Gérer l'upload de l'image si elle existe
       $imageurl= null;
       if($request->profile_picture) {
           $imageurl = $this->saveImage($request->profile_picture);
       }

        // Créer l'utilisateur
        $user = User::create([
            'email' => $request->email,
            'username' => $request->username,
            'password' => Hash::make($request->password),
            'profile_picture' => $imageurl,
        ]);

        // Créer un token
        $token = $user->createToken('mobile_token')->plainTextToken;

        return response()->json([
            'message' => 'Utilisateur enregistré avec succès',
            'token' => $token,
            'user' => $user
        ]);
    }

    private function saveImage($base64Image)
    {
        try {
            // Extraire le type MIME et les données de l'image
            list($type, $data) = explode(';', $base64Image);
            list(, $data) = explode(',', $data);
            list(, $type) = explode(':', $type);
            list(, $extension) = explode('/', $type);

            // Générer un nom de fichier unique
            $filename = 'user_' . time() . '_' . uniqid() . '.' . $extension;
            
            // Décoder et sauvegarder l'image
            $decodedImage = base64_decode($data);

            // Sauvegarder dans storage/app/public/user_images
            Storage::disk('public')->put('user_images/' . $filename, $decodedImage);

            // Retourner le chemin relatif de l'image (sans APP_URL)
            return '/storage/user_images/' . $filename;
        } catch (\Exception $e) {
            \Log::error('Error saving image: ' . $e->getMessage());
            return null;
        }
    }
}
