import 'package:flutter/material.dart';

class GameHistoryScreen extends StatelessWidget {
  const GameHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.black),
        title: const Text(
          'Game History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: const GameHistoryList(),
    );
  }
}

class GameHistoryList extends StatelessWidget {
  const GameHistoryList({Key? key}) : super(key: key);

  final List<GameMatch> matches = const [
    GameMatch(
      sport: SportType.football,
      opponent: 'Real Madrid',
      status: MatchStatus.completed,
      result: MatchResult.win,
      date: '2 days ago',
      score: '2-1',
    ),
    GameMatch(
      sport: SportType.basketball,
      opponent: 'Lakers',
      status: MatchStatus.completed,
      result: MatchResult.lose,
      date: '1 week ago',
      score: '98-105',
    ),
    GameMatch(
      sport: SportType.tennis,
      opponent: 'Novak Djokovic',
      status: MatchStatus.completed,
      result: MatchResult.draw,
      date: '2 weeks ago',
      score: '6-4, 4-6',
    ),
    GameMatch(
      sport: SportType.football,
      opponent: 'Barcelona',
      status: MatchStatus.live,
      result: MatchResult.win,
      date: 'Live now',
      score: '1-0',
    ),
    GameMatch(
      sport: SportType.volleyball,
      opponent: 'Brazil National Team',
      status: MatchStatus.completed,
      result: MatchResult.win,
      date: '3 weeks ago',
      score: '3-1',
    ),
    GameMatch(
      sport: SportType.basketball,
      opponent: 'Golden State Warriors',
      status: MatchStatus.upcoming,
      result: MatchResult.draw,
      date: 'Tomorrow 8:00 PM',
      score: 'vs',
    ),
    GameMatch(
      sport: SportType.tennis,
      opponent: 'Rafael Nadal',
      status: MatchStatus.completed,
      result: MatchResult.lose,
      date: '1 month ago',
      score: '4-6, 3-6',
    ),
    GameMatch(
      sport: SportType.football,
      opponent: 'Manchester United',
      status: MatchStatus.completed,
      result: MatchResult.draw,
      date: '1 month ago',
      score: '2-2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GameHistoryItem(match: matches[index]);
      },
    );
  }
}

class GameHistoryItem extends StatelessWidget {
  final GameMatch match;

  const GameHistoryItem({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sport Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getSportColor(match.sport).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSportIcon(match.sport),
              color: _getSportColor(match.sport),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Match Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'vs ${match.opponent}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (match.status == MatchStatus.live)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      match.date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.score,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Result Badge
          if (match.status != MatchStatus.upcoming)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getResultColor(match.result).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getResultColor(match.result).withOpacity(0.3),
                ),
              ),
              child: Text(
                _getResultText(match.result),
                style: TextStyle(
                  color: _getResultColor(match.result),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getSportIcon(SportType sport) {
    switch (sport) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.tennis:
        return Icons.sports_tennis;
      case SportType.volleyball:
        return Icons.sports_volleyball;
    }
  }

  Color _getSportColor(SportType sport) {
    switch (sport) {
      case SportType.football:
        return Colors.green;
      case SportType.basketball:
        return Colors.orange;
      case SportType.tennis:
        return Colors.blue;
      case SportType.volleyball:
        return Colors.purple;
    }
  }

  Color _getResultColor(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return Colors.green;
      case MatchResult.lose:
        return Colors.red;
      case MatchResult.draw:
        return Colors.orange;
    }
  }

  String _getResultText(MatchResult result) {
    switch (result) {
      case MatchResult.win:
        return 'WIN';
      case MatchResult.lose:
        return 'LOSE';
      case MatchResult.draw:
        return 'DRAW';
    }
  }
}

// Data Models
class GameMatch {
  final SportType sport;
  final String opponent;
  final MatchStatus status;
  final MatchResult result;
  final String date;
  final String score;

  const GameMatch({
    required this.sport,
    required this.opponent,
    required this.status,
    required this.result,
    required this.date,
    required this.score,
  });
}

enum SportType {
  football,
  basketball,
  tennis,
  volleyball,
}

enum MatchStatus {
  completed,
  live,
  upcoming,
}

enum MatchResult {
  win,
  lose,
  draw,
}