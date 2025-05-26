import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:http/http.dart' as http;

const USER_TEAM_URL = "$API_URL/api/user-team";

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
  Future<Team> createTeam(CreateTeamRequest request) async {
    final response = await http.post(
      Uri.parse(USER_TEAM_URL),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      print('Server response: ${response.body}'); // Debug log
      final data = jsonDecode(response.body);

      if (data['team'] == null) {
        throw Exception('Team data is null in server response');
      }

      final team = data['team'];

      if (team['sport'] == null) {
        throw Exception('Sport data is missing in server response');
      }

      return Team.fromJson(team);
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      throw Exception(data['errors'].toString());
    }

    print('Error response: ${response.body}'); // Debug log
    throw Exception('Failed to create team: ${response.statusCode}');
  }

  Future<Team> createTeamTest(CreateTeamRequest request) async {
    final response = await http.post(
      Uri.parse('$API_URL/api/teams/test-create-team'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        ...request.toJson(),
        'user_id': 1, // Toujours utiliser l'utilisateur 1 pour les tests
      }),
    );

    if (response.statusCode == 201) {
      print('Server response: ${response.body}'); // Debug log
      final data = jsonDecode(response.body);

      if (data['team'] == null) {
        throw Exception('Team data is null in server response');
      }

      final team = data['team'];

      if (team['sport'] == null) {
        throw Exception('Sport data is missing in server response');
      }

      return Team.fromJson(team);
    } else if (response.statusCode == 422) {
      final data = jsonDecode(response.body);
      throw Exception(data['errors'].toString());
    }

    print('Error response: ${response.body}'); // Debug log
    throw Exception('Failed to create team: ${response.statusCode}');
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
