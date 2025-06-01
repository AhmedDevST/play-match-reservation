import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final teamsProvider =
    StateNotifierProvider<TeamsNotifier, List<UserTeamLink>>((ref) {
  return TeamsNotifier();
});

class TeamsNotifier extends StateNotifier<List<UserTeamLink>> {
  TeamsNotifier() : super([]);

  // Méthode normale avec authentification
  Future<void> loadTeams(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/teams/my-teams'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Received data: $data'); // Pour déboguer

        // Vérifier si data['data'] existe et n'est pas null
        if (data['data'] != null && data['data'] is List) {
          final userTeamLinks = (data['data'] as List)
              .map((link) => UserTeamLink.fromJson(link))
              .toList();
          state = userTeamLinks;
        } else {
          print(
              'Warning: data[\'data\'] is null or not a List'); // Pour déboguer
          state = []; // Retourner une liste vide
        }
      } else if (response.statusCode == 401) {
        state = [];
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load teams: $e');
    }
  }



  Future<void> onTeamCreated(Team newTeam, String token) async {
    // Après la création d'une nouvelle équipe, recharger toutes les équipes
    await loadTeams(token);
  }
}
