import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:http/http.dart' as http;

class TeamMembersService {
  /// Récupérer tous les membres d'une équipe
  Future<List<UserTeamLink>> getTeamMembers(int teamId, String token) async {
    try {
      print('=== getTeamMembers called ===');
      print('teamId: $teamId');
      print('token: ${token.length > 20 ? token.substring(0, 20) + '...' : token}');

      final url = '$API_URL/api/teams/$teamId/members';
      print('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('getTeamMembers response status: ${response.statusCode}');
      print('getTeamMembers response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérification que data est bien un Map
        if (data is! Map<String, dynamic>) {
          throw Exception('Format de réponse invalide: attendu Map<String, dynamic>');
        }
        
        List<dynamic> teamMembers = data['team_members'] ?? [];
        print('Number of team members: ${teamMembers.length}');

        // Utilisation de whereType() et expand() pour une approche plus propre
        return teamMembers
            .map<UserTeamLink?>((member) {
              try {
                print('Parsing member: $member');

                // Vérifier si member est bien un Map
                if (member == null || member is! Map<String, dynamic>) {
                  print('Warning: member is null or not a Map<String, dynamic>: $member');
                  return null;
                }

                // Vérifier la présence des champs requis
                if (member['user'] == null) {
                  print('Warning: user field is null in member: $member');
                  return null;
                }

                if (member['team'] == null) {
                  print('Warning: team field is null in member: $member');
                  return null;
                }

                return UserTeamLink.fromJson(member);
              } catch (e, stackTrace) {
                print('Error parsing team member: $e');
                print('Stack trace: $stackTrace');
                print('Member data: $member');
                return null;
              }
            })
            .whereType<UserTeamLink>() // Plus propre que where + cast
            .toList();
      } else {
        print('Error response: ${response.body}');
        
        // Gestion d'erreur plus spécifique selon le code de statut
        String errorMessage;
        switch (response.statusCode) {
          case 401:
            errorMessage = 'Token d\'authentification invalide ou expiré';
            break;
          case 403:
            errorMessage = 'Accès refusé à cette équipe';
            break;
          case 404:
            errorMessage = 'Équipe non trouvée';
            break;
          case 500:
            errorMessage = 'Erreur serveur';
            break;
          default:
            errorMessage = 'Erreur lors de la récupération des membres: ${response.statusCode}';
        }
        
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      print('Network error in getTeamMembers: $e');
      throw Exception('Erreur de connexion réseau');
    } on FormatException catch (e) {
      print('JSON parsing error in getTeamMembers: $e');
      throw Exception('Erreur de format de données');
    } catch (e, stackTrace) {
      print('Unexpected error in getTeamMembers: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}