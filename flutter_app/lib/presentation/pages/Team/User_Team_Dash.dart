import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/pages/Team/Create_Team.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:flutter_app/presentation/pages/Team/Team_details.dart';
import 'package:flutter_app/providers/team_provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/core/config/routes.dart';

class UserTeamDash extends ConsumerStatefulWidget {
  const UserTeamDash({super.key});

  @override
  ConsumerState<UserTeamDash> createState() => _UserTeamDashState();
}

class _UserTeamDashState extends ConsumerState<UserTeamDash>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      // En mode test : toujours utiliser l'utilisateur 1
      await ref.read(teamsProvider.notifier).loadTeamsForTest();

      if (mounted) {
        setState(() {
          _error = null;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e, stackTrace) {
      print('Error in _loadTeams: $e'); // Pour déboguer
      print('Stack trace: $stackTrace'); // Pour déboguer
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getSportIcon(Sport sport) {
    switch (sport.id) {
      case 1:
        return Icons.sports_soccer;
      case 2:
        return Icons.sports_basketball;
      case 3:
        return Icons.sports_handball;
      default:
        return Icons.sports;
    }
  }

  String _getSportName(Sport sport) {
    return sport.name;
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mes Équipes',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.grey.shade800),
            onPressed: () {
              // En mode test, on utilise toujours l'ID 1
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTeam(
                    userId: "1",
                    isTestMode: true,
                  ),
                ),
              ).then((_) =>
                  _loadTeams()); // Recharger les équipes après la création
            },
          ),
        ],
      ),
      body: _buildBody(teams),
    );
  }

  Widget _buildBody(List<UserTeamLink> userTeamLinks) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFF1E88E5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Veuillez vous connecter pour voir vos équipes',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Séparer les équipes en deux listes et les trier par date de début
    final currentTeams = userTeamLinks
        .where((link) => !link.hasLeftTeam)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    final historicalTeams = userTeamLinks
        .where((link) => link.hasLeftTeam)
        .toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return RefreshIndicator(
      onRefresh: _loadTeams,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Équipes Récentes'),
                if (currentTeams.isEmpty)
                  _buildEmptyState('Vous ne faites partie d\'aucune équipe')
                else
                  ...currentTeams.map((link) => _buildTeamCard(link)),
                const SizedBox(height: 32),
                _buildSectionTitle('Historique'),
                if (historicalTeams.isEmpty)
                  _buildEmptyState('Aucune équipe dans l\'historique')
                else
                  ...historicalTeams.map((link) => _buildTeamCard(link)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildTeamCard(UserTeamLink teamLink) {
    final team = teamLink.team;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetails(teamId: team.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              team.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (teamLink.isCaptain) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2EE59D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Score: ${team.totalScore}',
                        style: const TextStyle(
                          color: Color(0xFF2EE59D),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSportIcon(team.sport),
                          color: const Color(0xFF1E88E5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getSportName(team.sport),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Color(0xFF1E88E5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Note: ${team.averageRating.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (team.image != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      team.fullImagePath,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.error_outline),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
