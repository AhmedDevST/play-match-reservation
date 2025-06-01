import 'Team.dart';

enum GameType { private, public }

class Game {
  final int id;
  final GameType type;
  final Team team1;
  Team? opponentTeam;
  int team1Score = 0;
  int opponentScore = 0;
  String status;

  Game({
    required this.id,
    required this.type,
    required this.team1,
    this.opponentTeam,
    required this.team1Score,
    required this.opponentScore,
    this.status = 'pending',
  });

  /// Converts enum to string for backend
  String get matchTypeAsString {
    switch (type) {
      case GameType.private:
        return 'private';
      case GameType.public:
        return 'public';
    }
  }

  /// Determine winner
  Team? get winner {
    if (team1Score > opponentScore) {
      return team1;
    } else if (opponentScore > team1Score) {
      return opponentTeam;
    } else {
      return null; // It's a draw
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    List teamsJson = json['teams'] ?? [];

    if (teamsJson.length < 2) {
      throw Exception("Two teams are required to create a match");
    }

    final team1Json = teamsJson[0];
    final team2Json = teamsJson[1];

    return Game(
      id: json['id'],
      status: json['status'] ?? 'pending',
      type: json['type'] == 'private' ? GameType.private : GameType.public,
      team1: Team.fromJson(team1Json['team']),
      opponentTeam: Team.fromJson(team2Json['team']),
      team1Score: team1Json['score'] ?? 0,
      opponentScore: team2Json['score'] ?? 0,
    );
  }
}
