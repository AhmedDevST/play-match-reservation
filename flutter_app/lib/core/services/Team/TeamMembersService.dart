import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:http/http.dart' as http;

class TeamMembersService {
  Future<List<UserTeamLink>> getTeamMembers(int teamId, String token) async {
  final url = '$API_URL/api/teams/$teamId/members';

  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
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

  final data = jsonDecode(response.body);
  if (data is! Map<String, dynamic>) {
    throw Exception('Format de réponse invalide');
  }

  final List<dynamic> teamMembers = data['team_members'] ?? [];
  List<UserTeamLink> validMembers = [];

  for (int i = 0; i < teamMembers.length; i++) {
    final member = teamMembers[i];
    if (member is! Map<String, dynamic>) {
      print('Member $i ignoré car ce n\'est pas un Map');
      continue;
    }

    try {
      final cleanedMember = Map<String, dynamic>.from(member);
      cleanedMember.remove('created_at');
      cleanedMember.remove('updated_at');

      if (cleanedMember['team'] is Map<String, dynamic>) {
        final team = Map<String, dynamic>.from(cleanedMember['team']);
        team.remove('created_at');
        team.remove('updated_at');
        team.remove('full_image_path');

        if (team['sport'] is Map<String, dynamic>) {
          final sport = Map<String, dynamic>.from(team['sport']);
          sport['min_players'] ??= 1;
          sport['image'] ??= null;
          team['sport'] = sport;
        }
        cleanedMember['team'] = team;
      }

      final userTeamLink = UserTeamLink.fromJson(cleanedMember);
      validMembers.add(userTeamLink);
    } catch (e) {
      print('Erreur au parsing du membre $i: $e');
      print('Données du membre $i: $member');
    }
  }

  print('Successfully parsed ${validMembers.length} out of ${teamMembers.length} members');
  return validMembers;
}

}