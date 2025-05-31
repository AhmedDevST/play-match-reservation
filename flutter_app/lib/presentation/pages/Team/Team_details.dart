import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/team_provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/models/UserTeamLink.dart';
import 'package:flutter_app/models/Invitation.dart';
import 'package:flutter_app/core/services/invitation/TeamInvitationService.dart';
import 'package:flutter_app/core/services/team/TeamMembersService.dart';

class TeamDetails extends ConsumerStatefulWidget {
  final int teamId;

  const TeamDetails({Key? key, required this.teamId}) : super(key: key);

  @override
  ConsumerState<TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends ConsumerState<TeamDetails> {
  final TeamInvitationService _invitationService = TeamInvitationService();
  final TeamMembersService _teamMembersService = TeamMembersService();

  @override
  void initState() {
    super.initState();

    // Forcer le rechargement des données de l'équipe
    Future.microtask(() {
      final authState = ref.read(authProvider);
      final token = authState.accessToken;
      if (token != null) {
        ref.read(teamsProvider.notifier).loadTeams(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teams = ref.watch(teamsProvider);
    final teamLink = teams.firstWhere((team) => team.team.id == widget.teamId);
    final membersInTeam = teams
        .where((t) => t.team.id == widget.teamId && !t.hasLeftTeam)
        .toList();
    final pendingMembers = teams
        .where((t) => t.team.id == widget.teamId && t.hasLeftTeam)
        .toList();

    return DefaultTabController(
      length: 2,
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
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    teamLink.team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      teamLink.team.image != null
                          ? Image.network(
                              teamLink.team.fullImagePath,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.blue.shade700,
                                    Colors.blue.shade900,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.sports_outlined,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
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
                        'Score',
                        teamLink.team.totalScore.toString(),
                        Icons.star,
                        Colors.amber,
                      ),
                      _buildStatCard(
                        'Note',
                        teamLink.team.averageRating.toStringAsFixed(1),
                        Icons.grade,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Sport',
                        teamLink.team.sport.name,
                        Icons.sports,
                        Colors.blue,
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
                    tabs: const [
                      Tab(text: 'JOUEURS'),
                      Tab(text: 'EN ATTENTE'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildMembersList(membersInTeam),
              _buildPendingList(pendingMembers),
            ],
          ),
        ),
        floatingActionButton: teamLink.isCaptain
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

  Widget _buildMembersList(List<UserTeamLink> members) {
    final authState = ref.watch(authProvider);
    final token = authState.accessToken;

    if (token == null) {
      return const Center(
        child: Text('Token d\'authentification requis'),
      );
    }

    // Utiliser FutureBuilder pour récupérer les membres depuis l'API
    return FutureBuilder<List<UserTeamLink>>(
      future: _teamMembersService.getTeamMembers(widget.teamId, token),
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
                trailing: member.isCaptain
                    ? const Icon(Icons.star, color: Colors.amber)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingList(List<UserTeamLink> pending) {
    final teams = ref.watch(teamsProvider);
    final teamLink = teams.firstWhere((team) => team.team.id == widget.teamId);
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
                    if (teamLink.isCaptain) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                        onPressed: () async {
                          // TODO: Ajouter la logique pour annuler l'invitation
                        },
                        tooltip: 'Annuler l\'invitation',
                      ),
                    ],
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
