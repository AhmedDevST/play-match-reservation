import 'package:flutter/material.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
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
      body: _buildBody(_userTeamLinks), // Utiliser les données locales
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
        // Ajouter un border pour les équipes dissoutes
        border: isHistorical
            ? Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              )
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

            // Si l'équipe a été dissoute (result == true), recharger les données
            if (result == true) {
              await _loadTeams();
            }
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
                                color: isHistorical
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (teamLink.isCaptain) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              color: isHistorical ? Colors.grey : Colors.amber,
                              size: 20,
                            ),
                          ],
                          if (isHistorical) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DISSOUTE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                        color: const Color(0xFF2EE59D)
                            .withOpacity(isHistorical ? 0.05 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Score: ${team.totalScore}',
                        style: TextStyle(
                          color: isHistorical
                              ? Colors.grey
                              : const Color(0xFF2EE59D),
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
                          color: const Color(0xFF1E88E5)
                              .withOpacity(isHistorical ? 0.05 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSportIcon(team.sport),
                          color: isHistorical
                              ? Colors.grey
                              : const Color(0xFF1E88E5),
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
                          color: const Color(0xFF1E88E5)
                              .withOpacity(isHistorical ? 0.05 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.star,
                          color: isHistorical
                              ? Colors.grey
                              : const Color(0xFF1E88E5),
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
                      if (isHistorical && teamLink.endDate != null) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event_busy,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dissoute le: ${teamLink.endDate?.day}/${teamLink.endDate?.month}/${teamLink.endDate?.year}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (team.image != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColorFiltered(
                      colorFilter: isHistorical
                          ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.multiply),
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
