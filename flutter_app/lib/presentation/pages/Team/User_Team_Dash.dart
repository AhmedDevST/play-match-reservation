import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/pages/Team/Create_Team.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:flutter_app/presentation/pages/Team/Team_details.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/core/config/routes.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:flutter_app/core/services/Team/UserTeamService.dart';

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
  final UserTeamService _userTeamService = UserTeamService();
  List<UserTeamLink> _userTeamLinks = [];

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
      final authState = ref.read(authProvider);
      final token = authState.accessToken;

      if (token == null) {
        throw Exception('Token d\'authentification requis');
      }

      // Charger l'historique complet des équipes depuis l'API
      print('Calling getUserTeamHistory...');
      final historyResponse = await _userTeamService.getUserTeamHistory(token);
      print('Response received: $historyResponse');

      final teamHistoryList = historyResponse['team_history'] as List;
      print('Team history list length: ${teamHistoryList.length}');

      // Convertir la réponse en UserTeamLink
      print('Converting history to UserTeamLinks...');
      _userTeamLinks = _convertHistoryToUserTeamLinks(teamHistoryList);
      print('Converted ${_userTeamLinks.length} UserTeamLinks');

      if (mounted) {
        setState(() {
          _error = null;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e, stackTrace) {
      print('Error in _loadTeams: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<UserTeamLink> _convertHistoryToUserTeamLinks(List teamHistoryList) {
    List<UserTeamLink> result = [];

    for (int i = 0; i < teamHistoryList.length; i++) {
      try {
        print('Converting item $i: ${teamHistoryList[i]}');
        final userTeamLink = UserTeamLink.fromJson(teamHistoryList[i]);
        result.add(userTeamLink);
        print('Successfully converted item $i');
      } catch (e) {
        print('Error converting item $i: $e');
        print('Item data: ${teamHistoryList[i]}');
        // Continue avec les autres éléments au lieu de planter complètement
      }
    }

    return result;
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                Icon(Icons.arrow_back, color: Colors.grey.shade800, size: 20),
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
        title: Text(
          'Mes Équipes',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: FloatingActionButton.small(
              backgroundColor: const Color(0xFF1E88E5),
              elevation: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateTeam(
                      userId: "1",
                      isTestMode: true,
                    ),
                  ),
                ).then((_) => _loadTeams());
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildBody(_userTeamLinks),
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

    // Utiliser les données chargées depuis l'API
    // Séparer les équipes en deux listes et les trier par date de début
    final seenTeamIds = <int>{};

    final currentTeams =
        _userTeamLinks.where((link) => !link.hasLeftTeam).where((link) {
      // Ne garder que la première occurrence de chaque équipe
      if (seenTeamIds.contains(link.team.id)) return false;
      seenTeamIds.add(link.team.id);
      return true;
    }).toList()
          ..sort((a, b) => b.startDate.compareTo(a.startDate));

    seenTeamIds.clear(); // Réinitialiser pour l'historique

    final historicalTeams = _userTeamLinks
        .where((link) => link.hasLeftTeam)
        .where((link) {
      if (seenTeamIds.contains(link.team.id)) return false;
      seenTeamIds.add(link.team.id);
      return true;
    }).toList()
      ..sort((a, b) =>
          (b.endDate ?? b.startDate).compareTo(a.endDate ?? a.startDate));

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
                _buildSectionTitle('Équipes Actuelles'),
                if (currentTeams.isEmpty)
                  _buildEmptyState(
                      'Vous ne faites partie d\'aucune équipe active')
                else
                  ...currentTeams.map((link) => _buildTeamCard(link)),
                const SizedBox(height: 32),
                _buildSectionTitle('Équipes Dissoutes'),
                if (historicalTeams.isEmpty)
                  _buildEmptyState('Aucune équipe dissoute dans l\'historique')
                else
                  ...historicalTeams
                      .map((link) => _buildTeamCard(link, isHistorical: true)),
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

  Widget _buildTeamCard(UserTeamLink teamLink, {bool isHistorical = false}) {
    final team = teamLink.team;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: isHistorical
            ? Border.all(color: Colors.red.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetails(teamId: team.id),
              ),
            );
            if (result == true) {
              await _loadTeams();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with team name and badges
                Row(
                  children: [
                    // Team avatar/icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1E88E5),
                            const Color(0xFF42A5F5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _getSportIcon(team.sport),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  team.name,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isHistorical
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (teamLink.isCaptain)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'CAPITAINE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSportName(team.sport),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.emoji_events,
                      label: 'Score',
                      value: '${team.totalScore}',
                      color: const Color(0xFF2EE59D),
                      isHistorical: isHistorical,
                    ),
                    const SizedBox(width: 12),
                    _buildStatChip(
                      icon: Icons.star_rounded,
                      label: 'Note',
                      value: team.averageRating.toStringAsFixed(1),
                      color: Colors.amber,
                      isHistorical: isHistorical,
                    ),
                    if (isHistorical) ...[
                      const SizedBox(width: 12),
                      _buildStatChip(
                        icon: Icons.event_busy_rounded,
                        label: 'Dissoute',
                        value: teamLink.endDate != null
                            ? '${teamLink.endDate!.day}/${teamLink.endDate!.month}'
                            : 'N/A',
                        color: Colors.red,
                        isHistorical: true,
                      ),
                    ],
                  ],
                ),

                // Team image
                if (team.image != null) ...[
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColorFiltered(
                      colorFilter: isHistorical
                          ? ColorFilter.mode(
                              Colors.grey.shade400,
                              BlendMode.saturation,
                            )
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: Image.network(
                        team.fullImagePath,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                              size: 32,
                            ),
                          );
                        },
                      ),
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

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isHistorical,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: (isHistorical ? Colors.grey.shade100 : color.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                (isHistorical ? Colors.grey.shade300 : color.withOpacity(0.3)),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isHistorical ? Colors.grey.shade500 : color,
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isHistorical ? Colors.grey.shade600 : color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
