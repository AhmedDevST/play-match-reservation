import 'dart:convert';
import 'package:flutter_app/models/UserTeamLink.dart';

void main() {
  // Données exactes de votre API
  final String apiResponse = '''
{
  "team_members": [
    {
      "id": 23,
      "user_id": 4,
      "team_id": 18,
      "start_date": "2025-05-31T16:16:30.000000Z",
      "end_date": null,
      "has_left_team": false,
      "leave_reason": null,
      "is_captain": true,
      "created_at": "2025-05-31T16:16:30.000000Z",
      "updated_at": "2025-05-31T16:16:30.000000Z",
      "user": {
        "id": 4,
        "username": "mohqmed",
        "email": "mohamed@gmail.com",
        "profile_picture": null
      },
      "team": {
        "id": 18,
        "name": "psg",
        "image": "/storage/team_images/team_1748708190_683b2b5e60f0d.jpeg",
        "total_score": 0,
        "average_rating": 0,
        "sport_id": 1,
        "full_image_path": "http://localhost:8000/storage/storage/team_images/team_1748708190_683b2b5e60f0d.jpeg",
        "sport": {
          "id": 1,
          "name": "Football",
          "max_players": 2
        }
      }
    }
  ]
}
  ''';

  try {
    print('=== TEST PARSING ===');
    final data = jsonDecode(apiResponse);
    final List<dynamic> teamMembers = data['team_members'] ?? [];
    print('Number of members: ${teamMembers.length}');

    if (teamMembers.isNotEmpty) {
      final member = teamMembers[0];
      print('Raw member: $member');

      // Nettoyer comme dans le service
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
          if (sport['min_players'] == null) {
            sport['min_players'] = 1;
          }
          if (sport['image'] == null) {
            sport['image'] = null;
          }
          team['sport'] = sport;
        }

        cleanedMember['team'] = team;
      }

      print('Cleaned member: $cleanedMember');
      print('Attempting to parse UserTeamLink...');

      final userTeamLink = UserTeamLink.fromJson(cleanedMember);
      print('SUCCESS! Parsed: ${userTeamLink.userId.name}');
    }
  } catch (e, stackTrace) {
    print('ERROR: $e');
    print('Stack trace: $stackTrace');
  }
}
