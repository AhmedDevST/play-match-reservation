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
    return UserTeamLink(
      id: json['id'],
      userId: json['user'] != null && json['user'] is Map<String, dynamic>
          ? User.fromJson(json['user'])
          : throw Exception('User data is missing or invalid'),
      team: json['team'] != null && json['team'] is Map<String, dynamic>
          ? Team.fromJson(json['team'])
          : throw Exception('Team data is missing or invalid'),
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      hasLeftTeam: json['has_left_team'] ?? false,
      leaveReason: json['leave_reason'],
      isCaptain: json['is_captain'] ?? false,
    );
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
