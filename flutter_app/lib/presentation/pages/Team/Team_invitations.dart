import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/User.dart';
import 'package:flutter_app/core/services/invitation/TeamInvitationService.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class TeamInvitations extends ConsumerStatefulWidget {
  final int teamId;

  const TeamInvitations({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<TeamInvitations> createState() => _TeamInvitationsState();
}

class _TeamInvitationsState extends ConsumerState<TeamInvitations>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TeamInvitationService _invitationService = TeamInvitationService();

  List<User> _availableUsers = [];
  List<User> _filteredUsers = [];
  List<User> _invitedUsers = [];
  bool _isLoadingUsers = false;
  Set<int> _invitedUserIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadAvailableUsers();
  }

  void _handleTabChange() {
    if (_tabController.index == 1 && _searchController.text.isNotEmpty) {
      _filterUsers(_searchController.text);
    }
  }

  Future<void> _loadAvailableUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      // Utiliser l'authProvider au lieu de SharedPreferences
      final authState = ref.read(authProvider);
      final token = authState.accessToken;

      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      // Utiliser la nouvelle méthode pour récupérer les utilisateurs disponibles
      // (ni membres ni invités)
      _availableUsers = await _invitationService.getUsersNotInTeamOrInvited(
          widget.teamId, token);

      // Charger les utilisateurs invités pour les identifier dans l'UI
      final invitedUsers =
          await _invitationService.getInvitedUsers(widget.teamId, token);

      _invitedUsers =
          invitedUsers.map((invitation) => invitation.receiver).toList();
      _invitedUserIds = _invitedUsers.map((u) => u.id).toSet();

      if (mounted) {
        setState(() {
          _filteredUsers = _availableUsers; // Initialiser la liste filtrée
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      print('Error loading available users: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors du chargement des utilisateurs: $e')),
        );
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _availableUsers);
      return;
    }

    final filtered = _availableUsers
        .where((user) =>
            user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() => _filteredUsers = filtered);
  }

  Future<void> _sendInvitation(User user) async {
    // Marquer l'utilisateur comme invité sans le retirer de la liste
    setState(() {
      _invitedUserIds.add(user.id);
      _invitedUsers.add(user);
      // Ne pas retirer l'utilisateur de _availableUsers
    });

    try {
      // Récupérer le token depuis l'authProvider
      final authState = ref.read(authProvider);
      final token = authState.accessToken;

      if (token == null) {
        throw Exception('Token d\'authentification non disponible');
      }

      await _invitationService.sendInvitation(user, widget.teamId, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur, rétablir l'état précédent
      if (mounted) {
        setState(() {
          _invitedUserIds.remove(user.id);
          _invitedUsers.removeWhere((u) => u.id == user.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi de l\'invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inviter des membres',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Enlève la flèche retour
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                // Naviguer vers le dashboard en supprimant toutes les routes précédentes
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Terminer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1E88E5),
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Utilisateurs'),
            Tab(text: 'Recherche'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher des utilisateurs...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(isFriends: true),
                _buildUserList(isFriends: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList({required bool isFriends}) {
    if (_isLoadingUsers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
        ),
      );
    }

    // Pour l'onglet "Amis", on affiche les utilisateurs disponibles (non membres)
    // Pour l'onglet "Autres", on affiche aussi les utilisateurs disponibles
    // TODO: Implémenter un vrai système d'amis plus tard
    final users = _filteredUsers;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFriends ? Icons.people_outline : Icons.person_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isFriends
                  ? 'Aucun utilisateur disponible'
                  : 'Aucun utilisateur trouvé',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFriends
                  ? 'Tous les utilisateurs sont déjà dans l\'équipe ou invités'
                  : 'Essayez une recherche différente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final bool isInvited = _invitedUserIds.contains(user.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
              child: user.profileImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        user.profileImage!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            trailing: isInvited
                ? Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _sendInvitation(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Inviter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
