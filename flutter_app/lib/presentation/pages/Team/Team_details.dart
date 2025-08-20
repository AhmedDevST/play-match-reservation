import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:flutter_app/models/Invitation.dart';
import 'package:flutter_app/core/services/invitation/TeamInvitationService.dart';
import 'package:flutter_app/core/services/team/TeamMembersService.dart';
import 'package:flutter_app/core/services/Team/UserTeamService.dart';
import 'package:flutter_app/presentation/widgets/team/userTeamDetails.dart';

class TeamDetails extends ConsumerStatefulWidget {
  final int teamId;

  const TeamDetails({Key? key, required this.teamId}) : super(key: key);

  @override
  ConsumerState<TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends ConsumerState<TeamDetails> {
  final TeamInvitationService _invitationService = TeamInvitationService();
  final TeamMembersService _teamMembersService = TeamMembersService();
  final UserTeamService _userTeamService = UserTeamService();

  UserTeamLink? _currentUserTeamLink;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    try {
      final authState = ref.read(authProvider);
      final token = authState.accessToken;

      if (token == null) {
        throw Exception('Token d\'authentification requis');
      }

      // Charger l'historique pour obtenir les informations complètes de l'équipe
      final historyResponse = await _userTeamService.getUserTeamHistory(token);
      final teamHistoryList = historyResponse['team_history'] as List;

      // Trouver le lien de l'utilisateur actuel avec cette équipe
      final currentUserLink = teamHistoryList
          .where((item) => item['team']['id'] == widget.teamId)
          .map((item) => UserTeamLink.fromJson(item))
          .firstOrNull;

      if (mounted) {
        setState(() {
          _currentUserTeamLink = currentUserLink;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _disbandTeam() async {
    final authState = ref.read(authProvider);
    final token = authState.accessToken;

    if (token == null) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dissoudre l\'équipe'),
        content: const Text(
            'Êtes-vous sûr de vouloir dissoudre cette équipe ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Dissoudre', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userTeamService.disbandTeam(widget.teamId, token);

        // Nettoyer automatiquement les invitations orphelines après dissolution
        await _userTeamService.cleanupOrphanedInvitations(token);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Équipe dissoute avec succès')),
          );
          // Retourner au dashboard avec rechargement
          Navigator.of(context).pop(true); // true indique qu'il faut recharger
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Chargement...',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
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
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Erreur',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(32),
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Oups! Une erreur s\'est produite',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_error',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadTeamData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Réessayer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentUserTeamLink == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Équipe introuvable'),
        ),
        body: const Center(
          child: Text(
              'Cette équipe n\'existe pas ou vous n\'en faites pas partie.'),
        ),
      );
    }

    final teamLink = _currentUserTeamLink!;
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    // Déterminer si l'utilisateur était capitaine ET si l'équipe est encore active
    final isCaptain = teamLink.userId.id == currentUserId && teamLink.isCaptain;
    final isTeamDisbanded = teamLink.hasLeftTeam;

    // Pour les équipes dissoutes, tout le monde ne voit que l'onglet membres
    final showCaptainFeatures = isCaptain && !isTeamDisbanded;

    return DefaultTabController(
      length: showCaptainFeatures ? 2 : 1,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1E88E5),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: showCaptainFeatures
                    ? [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete_forever,
                                  color: Colors.white, size: 20),
                            ),
                            tooltip: 'Dissoudre l\'équipe',
                            onPressed: _disbandTeam,
                          ),
                        ),
                      ]
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  title: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            teamLink.team.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isTeamDisbanded) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DISSOUTE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (teamLink.team.image != null)
                        ColorFiltered(
                          colorFilter: isTeamDisbanded
                              ? ColorFilter.mode(
                                  Colors.grey, BlendMode.saturation)
                              : const ColorFilter.mode(
                                  Colors.transparent, BlendMode.multiply),
                          child: Image.network(
                            teamLink.team.fullImagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1E88E5),
                                      const Color(0xFF42A5F5),
                                    ],
                                  ),
                                ),
                                child: const Icon(Icons.group,
                                    size: 80, color: Colors.white),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isTeamDisbanded
                                  ? [Colors.grey.shade400, Colors.grey.shade600]
                                  : [
                                      const Color(0xFF1E88E5),
                                      const Color(0xFF42A5F5)
                                    ],
                            ),
                          ),
                          child: const Icon(Icons.group,
                              size: 80, color: Colors.white),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
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
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          'Sport',
                          teamLink.team.sport.name,
                          Icons.sports_soccer_rounded,
                          isTeamDisbanded
                              ? Colors.grey
                              : const Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernStatCard(
                          'Score',
                          '${teamLink.team.totalScore}',
                          Icons.emoji_events_rounded,
                          isTeamDisbanded
                              ? Colors.grey
                              : const Color(0xFF2EE59D),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernStatCard(
                          'Note',
                          teamLink.team.averageRating.toStringAsFixed(1),
                          Icons.star_rounded,
                          isTeamDisbanded ? Colors.grey : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: showCaptainFeatures
                        ? const [
                            Tab(text: 'Membres', icon: Icon(Icons.people)),
                            Tab(text: 'En attente', icon: Icon(Icons.pending)),
                          ]
                        : const [
                            Tab(text: 'Membres', icon: Icon(Icons.people)),
                          ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: showCaptainFeatures
                ? [
                    _buildMembersList(),
                    _buildPendingList(),
                  ]
                : [
                    _buildMembersList(),
                  ],
          ),
        ),
        // FloatingActionButton seulement pour les capitaines d'équipes actives
        floatingActionButton: showCaptainFeatures
            ? Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/team-invitations',
                      arguments: {'teamId': teamLink.team.id},
                    );
                  },
                  icon:
                      const Icon(Icons.person_add_rounded, color: Colors.white),
                  label: const Text(
                    'Inviter',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1E88E5),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildModernStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    final authState = ref.watch(authProvider);
    final token = authState.accessToken;

    if (token == null) {
      return const Center(
        child: Text('Token d\'authentification requis'),
      );
    }

    // Pour les équipes dissoutes, utiliser l'historique complet
    // Pour les équipes actives, utiliser les membres actuels
    final teamLink = _currentUserTeamLink!;
    final isTeamDisbanded = teamLink.hasLeftTeam;

    Future<List<UserTeamLink>> getMembers() async {
      if (isTeamDisbanded) {
        // Pour les équipes dissoutes, utiliser la nouvelle API pour récupérer tous les membres
        final membersResponse =
            await _userTeamService.getAllTeamMembers(widget.teamId, token);
        final teamMembersList = membersResponse['team_members'] as List;

        return teamMembersList
            .map((item) => UserTeamLink.fromJson(item))
            .toList();
      } else {
        // Pour les équipes actives, utiliser l'API normale
        return _teamMembersService.getTeamMembers(widget.teamId, token);
      }
    }

    return FutureBuilder<List<UserTeamLink>>(
      future: getMembers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          print('Error in _buildMembersList: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur lors du chargement des membres',
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

        final teamMembers = snapshot.data ?? [];

        if (teamMembers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucun membre dans l\'équipe',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            final member = teamMembers[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isTeamDisbanded
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UserTeamDetails(
                                userId: member.userId.id,
                                teamId: widget.teamId,
                              ),
                            ),
                          );
                        },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Avatar with online indicator
                        Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: member.isCaptain
                                      ? Colors.amber.withOpacity(0.5)
                                      : Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: member.userId.profileImage != null
                                    ? Image.network(
                                        member.userId.profileImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF1E88E5),
                                                  const Color(0xFF42A5F5),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                member.userId.name.isNotEmpty
                                                    ? member.userId.name[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1E88E5),
                                              const Color(0xFF42A5F5),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            member.userId.name.isNotEmpty
                                                ? member.userId.name[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            // Captain crown
                            if (member.isCaptain)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Member info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.userId.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (member.isCaptain) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.amber, Colors.orange],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
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
                                  ] else ...[
                                    Text(
                                      'Membre',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Arrow or disabled indicator
                        if (!isTeamDisbanded) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingList() {
    final authState = ref.watch(authProvider);
    final token = authState.accessToken;

    if (token == null) {
      return const Center(
        child: Text('Token d\'authentification requis'),
      );
    }

    return FutureBuilder<List<Invitation>>(
      future: _invitationService.getInvitedUsers(widget.teamId, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final invitedUsers = snapshot.data;
        if (invitedUsers == null || invitedUsers.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.pending_actions_outlined,
                      size: 48,
                      color: Colors.orange.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune invitation en attente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les invitations que vous envoyez apparaîtront ici',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: invitedUsers.length,
          itemBuilder: (context, index) {
            final invitation = invitedUsers[index];
            final user = invitation.receiver;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: user.profileImage != null
                            ? Image.network(
                                user.profileImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.shade400,
                                          Colors.orange.shade600,
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.pending_outlined,
                                      size: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'EN ATTENTE',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Cancel button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        onPressed: () async {
                          // Show confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Annuler l\'invitation'),
                              content: Text(
                                'Voulez-vous vraiment annuler l\'invitation de ${user.name} ?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Non',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Oui, annuler'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            // TODO: Implement invitation cancellation logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Invitation de ${user.name} annulée'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        tooltip: 'Annuler l\'invitation',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
