import 'package:flutter_app/models/Team.dart';

enum GameType { private, public }

class Game {
  final int id;
  final Team team1;
  final Team ?opponentTeam;
  final GameType type;

  Game({
    required this.id,
    required this.team1,
    this.opponentTeam,
    required this.type,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      team1: Team.fromJson(json['team1']),
      opponentTeam: Team.fromJson(json['opponent_team']),
      id: json['id'],
      type: json['type'] == 'private' ? GameType.private : GameType.public,
    );
  }
}
