import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:http/http.dart' as http;

class UserTeamDetailsService {
  /// Récupère les détails d'un utilisateur dans une équipe spécifique
  Future<Map<String, dynamic>> getUserTeamDetails(
    int userId,
    int teamId,
    String token,
  ) async {
    final url = '$API_URL/api/teams/$teamId/users/$userId/details';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = 'Token d\'authentification invalide ou expiré';
            break;
          case 403:
            errorMessage =
                'Accès refusé - Vous n\'avez pas l\'autorisation de voir ces détails';
            break;
          case 404:
            errorMessage = 'Utilisateur ou équipe non trouvé';
            break;
          case 500:
            errorMessage = 'Erreur serveur';
            break;
          default:
            errorMessage = 'Erreur inconnue: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erreur de connexion: $e');
    }
  }
}
