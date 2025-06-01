// UserTeam.dart

import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/user.dart';

class UserTeamLink {
  final int id;
  final User userId;
  final Team team; // Changed from teamId
  final DateTime startDate;
  final DateTime? endDate;
  final bool hasLeftTeam;
  final String? leaveReason;
  final bool isCaptain;

  UserTeamLink({
    required this.id,
    required this.userId,
    required this.team,
    required this.startDate,
    this.endDate,
    required this.hasLeftTeam,
    this.leaveReason,
    required this.isCaptain,
  });

  factory UserTeamLink.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing UserTeamLink from JSON: $json');

      // Vérifier les champs requis
      if (json['id'] == null) {
        throw Exception('UserTeamLink ID is missing');
      }

      if (json['user'] == null) {
        throw Exception('User data is missing in UserTeamLink');
      }

      if (json['team'] == null) {
        throw Exception('Team data is missing in UserTeamLink');
      }

      if (json['start_date'] == null) {
        throw Exception('Start date is missing in UserTeamLink');
      }

      return UserTeamLink(
        id: json['id'] is String ? int.parse(json['id']) : json['id'],
        userId: json['user'] is Map<String, dynamic>
            ? User.fromJson(json['user'])
            : throw Exception('User data is not a valid Map<String, dynamic>'),
        team: json['team'] is Map<String, dynamic>
            ? Team.fromJson(json['team'])
            : throw Exception('Team data is not a valid Map<String, dynamic>'),
        startDate: DateTime.parse(json['start_date']),
        endDate:
            json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
        hasLeftTeam: json['has_left_team'] ?? false,
        leaveReason: json['leave_reason'],
        isCaptain: json['is_captain'] ?? false,
      );
    } catch (e) {
      print('Error parsing UserTeamLink: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId.toJson(),
      'team': team.toJson(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'has_left_team': hasLeftTeam,
      'leave_reason': leaveReason,
      'is_captain': isCaptain,
    };
  }
}
