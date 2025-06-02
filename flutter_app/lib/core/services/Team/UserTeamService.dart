import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:http/http.dart' as http;

const USER_TEAM_URL = "$API_URL/api/teams/createTeam";

class CreateTeamRequest {
  final String name;
  final int sportId;
  final String? image;

  CreateTeamRequest({
    required this.name,
    required this.sportId,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sport_id': sportId,
      'image': image,
    };
  }
}

class UserTeamService {
  Future<Team> createTeam(CreateTeamRequest request, String token) async {
    final response = await http.post(
      Uri.parse(USER_TEAM_URL),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      print('Server response: ${response.body}');
      // Debug log
      final data = jsonDecode(response.body);

      if (data['team'] == null) {
        throw Exception('Team data is null in server response');
      }

      final team = data['team'];

      if (team['sport'] == null) {
        throw Exception('Sport data is missing in server response');
      }
      // Debug log
      return Team.fromJson(team);
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      throw Exception(data['errors'].toString());
    }

    print('Error response: ${response.body}'); // Debug log
    throw Exception('Failed to create team: ${response.statusCode}');
  }

  // Disbander une équipe
  Future<void> disbandTeam(int teamId, String token) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/teams/$teamId/disband'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Team disbanded successfully'); // Debug log
    } else {
      print('Error response: ${response.body}'); // Debug log
      throw Exception('Failed to disband team: ${response.statusCode}');
    }
  }

  // Récupérer l'historique des équipes d'un utilisateur
  Future<Map<String, dynamic>> getUserTeamHistory(String token) async {
    final response = await http.get(
      Uri.parse('$API_URL/api/teams/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("hello from the debugger"); // Debug log
      throw Exception('Failed to load team history: ${response.statusCode}');
    }
  }

  // Nettoyer les invitations orphelines
  Future<void> cleanupOrphanedInvitations(String token) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/teams/cleanup-invitations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Orphaned invitations cleaned up successfully'); // Debug log
    } else {
      print('Error response: ${response.body}'); // Debug log
      throw Exception(
          'Failed to cleanup orphaned invitations: ${response.statusCode}');
    }
  }

  // Récupérer tous les membres d'une équipe (y compris équipes dissoutes)
  Future<Map<String, dynamic>> getAllTeamMembers(
      int teamId, String token) async {
    final response = await http.get(
      Uri.parse('$API_URL/api/teams/$teamId/all-members'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Team members fetched successfully'); // Debug log
      return jsonDecode(response.body);
    } else {
      print('Error response: ${response.body}'); // Debug log
      throw Exception('Failed to fetch team members: ${response.statusCode}');
    }
  }

  Future<List<Sport>> getSports() async {
    try {
      print('Fetching sports from: $API_URL/api/sports'); // Debug log
      final response = await http.get(
        Uri.parse('$API_URL/api/sports'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response headers: ${response.headers}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode != 200) {
        print('Error: Non-200 status code received'); // Debug log
        throw Exception('Failed to load sports: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null) {
          throw Exception('Response data is null');
        }

        final sportsData = data['sports'] as List?;
        if (sportsData == null) {
          throw Exception('Sports data is null');
        }

        final sports =
            sportsData.map((sport) => Sport.fromJson(sport)).toList();
        print('Parsed ${sports.length} sports successfully'); // Debug log
        return sports;
      } else {
        throw Exception('Failed to load sports: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getSports: $e'); // Debug log
      rethrow;
    }
  }
}
