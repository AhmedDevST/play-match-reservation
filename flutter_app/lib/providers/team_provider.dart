import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final teamsProvider =
    StateNotifierProvider<TeamsNotifier, List<UserTeamLink>>((ref) {
  return TeamsNotifier();
});

class TeamsNotifier extends StateNotifier<List<UserTeamLink>> {
  TeamsNotifier() : super([]);

  // Méthode normale avec authentification
  Future<void> loadTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        state = [];
        return;
      }

      final response = await http.get(
        Uri.parse('$API_URL/api/teams/my-teams'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userTeamLinks = (data['data'] as List)
            .map((link) => UserTeamLink.fromJson(link))
            .toList();
        state = userTeamLinks;
      } else if (response.statusCode == 401) {
        state = [];
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load teams: $e');
    }
  }

  // Méthode de test qui utilise toujours l'utilisateur 1
  Future<void> loadTeamsForTest() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/teams/test-my-teams'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Received data: $data'); // Pour déboguer
        final userTeamLinks = (data['data'] as List)
            .map((link) => UserTeamLink.fromJson(link))
            .toList();
        state = userTeamLinks;
      } else {
        print('Error status code: ${response.statusCode}'); // Pour déboguer
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading teams: $e'); // Pour déboguer
      throw Exception('Failed to load teams: $e');
    }
  }

  Future<void> onTeamCreated(Team newTeam) async {
    // Après la création d'une nouvelle équipe, recharger toutes les équipes
    await loadTeamsForTest();
  }
}
