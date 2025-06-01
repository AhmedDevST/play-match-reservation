import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/User.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:flutter_app/core/services/team/UserTeamDetailsService.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class UserTeamDetails extends ConsumerStatefulWidget {
  final int userId;
  final int teamId;

  const UserTeamDetails({
    Key? key,
    required this.userId,
    required this.teamId,
  }) : super(key: key);

  @override
  ConsumerState<UserTeamDetails> createState() => _UserTeamDetailsState();
}

class _UserTeamDetailsState extends ConsumerState<UserTeamDetails> {
  final UserTeamDetailsService _userDetailsService = UserTeamDetailsService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final token = authState.accessToken;

    if (token == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Détails du membre'),
        ),
        body: const Center(
          child: Text('Token d\'authentification requis'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du membre'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDetailsService.getUserTeamDetails(
          widget.userId,
          widget.teamId,
          token,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {}); // Force rebuild pour retry
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final user = User.fromJson(data['user']);
          final teamLink = UserTeamLink.fromJson(data['team_link']);

          return SingleChildScrollView(
            child: Column(
              children: [
                // En-tête avec photo de profil
                _buildHeader(user, teamLink),

                // Informations générales
                _buildGeneralInfo(user, teamLink),

                // Statistiques de l'équipe
                _buildTeamStats(data['team_stats']),

                // Historique dans l'équipe (si disponible)
                if (data['team_history'] != null)
                  _buildTeamHistory(data['team_history']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(User user, UserTeamLink teamLink) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'user_${user.id}',
            child: CircleAvatar(
              radius: 50,
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (teamLink.isCaptain) ...[
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                teamLink.isCaptain ? 'Capitaine' : 'Membre',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight:
                      teamLink.isCaptain ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo(User user, UserTeamLink teamLink) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations générales',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person,
              'Nom d\'utilisateur',
              user.name,
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Membre depuis',
              _formatDate(teamLink.startDate),
            ),
            if (teamLink.endDate != null)
              _buildInfoRow(
                Icons.calendar_today_outlined,
                'A quitté le',
                _formatDate(teamLink.endDate!),
              ),
            _buildInfoRow(
              Icons.info,
              'Statut',
              teamLink.hasLeftTeam ? 'Ancien membre' : 'Membre actif',
              statusColor: teamLink.hasLeftTeam ? Colors.red : Colors.green,
            ),
            if (teamLink.leaveReason != null)
              _buildInfoRow(
                Icons.info_outline,
                'Raison de départ',
                teamLink.leaveReason!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: statusColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStats(Map<String, dynamic>? stats) {
    if (stats == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Jours',
                  '${stats['days_in_team'] ?? 0}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Matchs',
                  '${stats['matches_played'] ?? 0}',
                  Icons.sports_soccer,
                  Colors.green,
                ),
                _buildStatItem(
                  'Victoires',
                  '${stats['matches_won'] ?? 0}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamHistory(List<dynamic> history) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...history.map((event) => _buildHistoryItem(event)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (event['date'] != null)
                  Text(
                    _formatDate(DateTime.parse(event['date'])),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
