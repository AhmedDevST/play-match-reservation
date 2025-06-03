import 'package:flutter/material.dart';
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Chargement...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Erreur'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTeamData,
                child: const Text('Réessayer'),
              ),
            ],
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
      length: showCaptainFeatures
          ? 2
          : 1, // 2 tabs seulement pour capitaine d'équipe active
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: showCaptainFeatures
                    ? [
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Colors.white),
                          tooltip: 'Dissoudre l\'équipe',
                          onPressed: _disbandTeam,
                        ),
                      ]
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        teamLink.team.name,
                        style: const TextStyle(
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 2)
                          ],
                        ),
                      ),
                      if (isTeamDisbanded) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
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
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.group, size: 64),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          color: isTeamDisbanded
                              ? Colors.grey.shade400
                              : Colors.blue.shade300,
                          child: const Icon(Icons.group,
                              size: 64, color: Colors.white),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        'Sport',
                        teamLink.team.sport.name,
                        Icons.sports,
                        isTeamDisbanded ? Colors.grey : Colors.blue,
                      ),
                      _buildStatCard(
                        'Score',
                        '${teamLink.team.totalScore}',
                        Icons.star,
                        isTeamDisbanded ? Colors.grey : Colors.amber,
                      ),
                      _buildStatCard(
                        'Note',
                        teamLink.team.averageRating.toStringAsFixed(1),
                        Icons.thumb_up,
                        isTeamDisbanded ? Colors.grey : Colors.green,
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
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/team-invitations',
                    arguments: {'teamId': teamLink.team.id},
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Inviter'),
                backgroundColor: Theme.of(context).primaryColor,
              )
            : null,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(16),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            final member = teamMembers[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: isTeamDisbanded
                    ? null
                    : () {
                        // Naviguer vers les détails de l'utilisateur seulement pour les équipes actives
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => UserTeamDetails(
                              userId: member.userId.id,
                              teamId: widget.teamId,
                            ),
                          ),
                        );
                      },
                leading: CircleAvatar(
                  backgroundImage: member.userId.profileImage != null
                      ? NetworkImage(member.userId.profileImage!)
                      : null,
                  child: member.userId.profileImage == null
                      ? Text(
                          member.userId.name.isNotEmpty
                              ? member.userId.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                title: Text(member.userId.name),
                subtitle: member.isCaptain
                    ? const Text(
                        'Capitaine',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w500),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (member.isCaptain)
                      const Icon(Icons.star, color: Colors.amber),
                    // Masquer la flèche de navigation pour les équipes dissoutes
                    if (!isTeamDisbanded)
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
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
          return const Center(
            child: Text('Aucune invitation en attente'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invitedUsers.length,
          itemBuilder: (context, index) {
            final invitation = invitedUsers[index];
            final user = invitation.receiver;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null ? Text(user.name[0]) : null,
                ),
                title: Text(user.name),
                subtitle: const Text('En attente de réponse'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pending_outlined),
                    const SizedBox(width: 8),
                    IconButton(
                      icon:
                          const Icon(Icons.cancel_outlined, color: Colors.red),
                      onPressed: () async {
                        // TODO: Ajouter la logique pour annuler l'invitation
                      },
                      tooltip: 'Annuler l\'invitation',
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
