import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/match/match_service.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/TeamPlayer.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/presentation/pages/SportFacility/FacilityDetailsPage.dart';
import 'package:flutter_app/presentation/widgets/rating/star_rating.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';

class MatchDetails extends StatefulWidget {
  final int idGame;
  const MatchDetails({Key? key, required this.idGame}) : super(key: key);

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails>
    with TickerProviderStateMixin {
  late GameResponse? _gameResponse;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadGame();
  }

  Future<void> loadGame() async {
    isLoading = true;
    GameResponse loadedGameData = await fetchGame(widget.idGame);
    setState(() {
      isLoading = false;
      _gameResponse = loadedGameData;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (isLoading || _gameResponse == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final game = _gameResponse!.game;
    final type = game.matchTypeAsString;
    final status = game.status;
    final Team team1 = game.team1;
    final Team? team2 = game.opponentTeam;
    final team1Score = game.team1Score;
    final team2Score = game.opponentScore;
    final winner = game.winner;
    final Sport sport = team1.sport;
    final facility = _gameResponse!.facility;
    final timeSlot = _gameResponse!.timeSlot;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Match Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLiveScoreCard(type, status, sport, team1Score, team2Score,
                  winner, team1, team2),
              const SizedBox(height: 20),
              _buildVenueCard(facility),
              const SizedBox(height: 20),
              _buildMatchTimeCard(timeSlot),
              const SizedBox(height: 20),
              _buildTeamsPleyersCard(team1, team2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTimeCard(TimeSlot timeSlot) {
    final startTime = timeSlot.startTime;
    final endTime = timeSlot.endTime;
    final dateSlot = timeSlot.date;
    return Card(
      elevation: 6,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue[600], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Match Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfoTile(
                    icon: Icons.calendar_today,
                    title: 'Date',
                    subtitle: DateFormat('E d yyyy').format(dateSlot),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeInfoTile(
                    icon: Icons.access_time,
                    title: 'Time',
                    subtitle: '$startTime - $endTime',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: color[600], size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(SportFacility facility) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FacilityDetailsPage(
              sportFacility: facility,
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red[600], size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Venue Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 120,
                  child: ImageNetwork(
                    image: facility.fullImagePath,
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                    fitWeb: BoxFitWeb.cover,
                    fitAndroidIos: BoxFit.cover,
                    onLoading: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    onError: const Icon(Icons.sports),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                facility.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                facility.address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveScoreCard(
    String type,
    String status,
    Sport sport,
    int team1Score,
    int team2Score,
    Team? winner,
    Team team1,
    Team? team2,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header with match type and sport (unchanged)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Teams and Score
            Row(
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: winner == team1
                                ? [Colors.amber[400]!, Colors.amber[600]!]
                                : [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (winner == team1 ? Colors.amber : Colors.blue)
                                      .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            team1.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        team1.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Add star rating here for team 1
                      const SizedBox(height: 4),
                      StarRating(
                        rating: team1.averageRating,
                        starCount: 5,
                        size: 20,
                        color: Colors.amber,
                      ),

                      if (winner == team1) ...[
                        const SizedBox(height: 4),
                        Icon(Icons.emoji_events,
                            color: Colors.amber[600], size: 20),
                      ],
                    ],
                  ),
                ),

                // Score (unchanged)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$team1Score - $team2Score',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team1.sport.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Team 2
                Expanded(
                  child: team2 != null
                      ? Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: winner == team2
                                      ? [Colors.amber[400]!, Colors.amber[600]!]
                                      : [Colors.red[400]!, Colors.red[600]!],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (winner == team2
                                            ? Colors.amber
                                            : Colors.red)
                                        .withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  team2.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              team2.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            // Add star rating here for team 2
                            const SizedBox(height: 4),
                            StarRating(
                              rating: team2.averageRating,
                              starCount: 5,
                              size: 20,
                              color: Colors.amber,
                            ),

                            if (winner == team2) ...[
                              const SizedBox(height: 4),
                              Icon(Icons.emoji_events,
                                  color: Colors.amber[600], size: 20),
                            ],
                          ],
                        )
                      : Column(
                          children: const [
                            Icon(Icons.hourglass_empty,
                                size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Waiting for Opponent',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),

            // Winner banner (unchanged)
            if (status != 'pending' &&
                status != 'canceled' &&
                winner != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber[400]!, Colors.amber[600]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      '🎉 ${winner.name} Wins!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsPleyersCard(Team team1, Team? team2) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          // <-- Wrap whole content in scrollable
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.group_add,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Team players',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Players Lists
              Row(
                children: [
                  Expanded(
                    child: _buildTeamPlayersList(team1),
                  ),
                  const SizedBox(width: 16),
                  if (team2 != null)
                    Expanded(
                      child: _buildTeamPlayersList(team2),
                    )
                  else
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'No opponent team available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamPlayersList(Team? team) {
    final List<TeamPlayer> players = team?.players ?? [];
    final String displayName = team?.name ?? '';
    final int playerCount = players.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$displayName ($playerCount players)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true, // Expand to fit all children
          physics:
              const NeverScrollableScrollPhysics(), // Disable internal scroll
          itemCount: playerCount,
          itemBuilder: (context, index) {
            return _buildModernPlayerTile(
                players[index]); // Show score inside this widget
          },
        ),
      ],
    );
  }

  Widget _buildModernPlayerTile(TeamPlayer player) {
    final profile_picture = player.user.profileImage;
    final username = player.user.name;
    final isCaptain = player.isCaptain;
    const score = 4.5;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image or Initial
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: profile_picture != null
                  ? DecorationImage(
                      image: NetworkImage(profile_picture),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.blue,
            ),
            child: profile_picture == null
                ? Center(
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isCaptain)
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      case 'live':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
