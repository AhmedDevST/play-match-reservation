import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/Notification/Notification.dart';
import 'package:flutter_app/core/services/invitation/TeamInvitationService.dart';
import 'package:flutter_app/core/services/invitation/invitationService.dart';
import 'package:flutter_app/models/Invitation.dart';
import 'package:flutter_app/models/Notification.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:flutter_app/presentation/pages/match/details_match.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedFilter = 'All';
  late List<NotificationModel> _notifications = [];
  late List<NotificationModel> _filteredNotifications = [];
  bool isLoading = false;
  TeamInvitationService teamInvitationService = TeamInvitationService();
  @override
  void initState() {
    super.initState();
    _selectedFilter = "All";
    LoadNotification();
  }

  Future<void> RespondingInvitation(
      Invitation invitation, InvitationStatus status) async {
    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    bool success = false;
    if (invitation.type == InvitationType.team) {
      await teamInvitationService.respondToInvitation(
          invitation, status, token);
      success = true; // Si pas d'exception, c'est réussi
    } else if (invitation.type == InvitationType.friend ||
        invitation.type == InvitationType.match) {
      success = await respondToInvitation(invitation.id, status, token);
    }

    if (!success) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la réponse à l\'invitation'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
  }

  Future<void> markNotificationAsRead(int id) async {
    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    await markAsRead(id, token);
  }

  Future<void> LoadNotification() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    final authState = ref.read(authProvider);
    final token = authState.accessToken;
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final loadedNotificationData = await getNotificationOfUser(token);

      if (!mounted) return;
      setState(() {
        _notifications = loadedNotificationData;
        _filteredNotifications = _notifications;
        isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des notifications: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterNotifications() {
    setState(() {
      if (_selectedFilter.toLowerCase() == 'all') {
        _filteredNotifications = _notifications;
      } else {
        _filteredNotifications = _notifications.where((notification) {
          Invitation invitation = notification.notifiable as Invitation;
          return invitation.type.name.toLowerCase() ==
              _selectedFilter.toLowerCase();
        }).toList();
      }
    });
  }

  int get _unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                fontSize: 22,
              ),
            ),
            if (_unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3182CE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF4A5568), size: 15),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: LoadNotification,
              color: const Color(0xFF3182CE),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Filtres en haut
                  SliverToBoxAdapter(
                    child: _buildFilterTabs(),
                  ),

                  // Liste des notifications
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final filteredNotifications = _filteredNotifications;
                        if (index >= filteredNotifications.length) return null;
                        return _buildNotificationCard(
                            filteredNotifications[index]);
                      },
                      childCount: _filteredNotifications.length,
                    ),
                  ),

                  // Message si aucune notification
                  if (_filteredNotifications.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildEmptyState(),
                    ),

                  // Espacement en bas
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            const SizedBox(width: 8),
            _buildFilterChip(InvitationType.friend.name),
            const SizedBox(width: 8),
            _buildFilterChip(InvitationType.team.name),
            const SizedBox(width: 8),
            _buildFilterChip(InvitationType.match.name),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type) {
    bool isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = type;
          filterNotifications();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3182CE) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF3182CE) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF3182CE).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A5568),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF3182CE).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 40,
              color: Color(0xFF3182CE),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous n\'avez aucune notification pour le moment.',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: notification.isRead
                ? const Color(0xFFE2E8F0)
                : const Color(0xFF3182CE).withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleNotificationTap(notification),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar ou icône avec animation
                  _buildNotificationAvatar(notification),
                  const SizedBox(width: 12),

                  // Contenu
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec nom et timestamp
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _getNotifiableName(notification),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: notification.isRead
                                      ? const Color(0xFF718096)
                                      : const Color(0xFF2D3748),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getNotificationColor(notification)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatTimestamp(notification.createdAt),
                                style: TextStyle(
                                  color: _getNotificationColor(notification),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Message avec style amélioré
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: notification.isRead
                                ? const Color(0xFF718096)
                                : const Color(0xFF4A5568),
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        // Actions si nécessaire
                        if (notification.type ==
                                NotificationType.invitationNotification)
                          _buildInvitationActions(notification),

                        // Détails spécifiques selon le type de notification
                        //_buildNotificationDetails(notification),
                      ],
                    ),
                  ),

                  // Indicateur non lu avec animation
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3182CE),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3182CE).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationAvatar(NotificationModel notification) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getNotificationColor(notification).withOpacity(0.1),
              border: Border.all(
                color: _getNotificationColor(notification).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _getNotificationImage(notification) != null
                ? ClipOval(
                    child: Image.network(
                      _getNotificationImage(notification)!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    _getNotificationIcon(notification),
                    color: _getNotificationColor(notification),
                    size: 22,
                  ),
          ),
        ),
        if (!notification.isRead)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF3182CE),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInvitationActions(NotificationModel notification) {
    Invitation invitation = notification.notifiable as Invitation;
    if (invitation.status != InvitationStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: invitation.status == InvitationStatus.accepted
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: invitation.status == InvitationStatus.accepted
                  ? Colors.green
                  : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                invitation.status == InvitationStatus.accepted
                    ? Icons.check_circle
                    : Icons.cancel,
                color: invitation.status == InvitationStatus.accepted
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                invitation.status == InvitationStatus.accepted
                    ? 'Invitation acceptée'
                    : 'Invitation refusée',
                style: TextStyle(
                  color: invitation.status == InvitationStatus.accepted
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _acceptInvitation(notification),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3182CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Accepter',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _declineInvitation(notification),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF718096),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Refuser',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.invitationNotification:
        Invitation invitation = notification.notifiable as Invitation;
        switch (invitation.type) {
          case InvitationType.team:
            return Icons.person_add;

          case InvitationType.friend:
            return Icons.person;
          case InvitationType.match:
            return Icons.gamepad;
        }
    }
  }

  Color _getNotificationColor(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.invitationNotification:
        Invitation invitation = notification.notifiable as Invitation;
        switch (invitation.type) {
          case InvitationType.team:
            return const Color(0xFF38B2AC); // teal
          case InvitationType.friend:
            return const Color(0xFF805AD5); // purple
          case InvitationType.match:
            return const Color(0xFFED8936); // orange
        }
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      markNotificationAsRead(notification.id);
    }
    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.invitationNotification:
        Invitation invitation = notification.notifiable as Invitation;
        switch (invitation.type) {
          case InvitationType.team:
            break;
          case InvitationType.friend:
            break;
          case InvitationType.match:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetails(
                  idGame: invitation.invitableId ?? 0,
                ),
              ),
            );
        }
        break;
    }
  }

  void _acceptInvitation(NotificationModel notification) {
    Invitation invitation = notification.notifiable as Invitation;

    RespondingInvitation(invitation, InvitationStatus.accepted);
    setState(() {
      LoadNotification();
    });
  }

  void _declineInvitation(NotificationModel notification) {
    Invitation invitation = notification.notifiable as Invitation;
    RespondingInvitation(invitation, InvitationStatus.rejected);
    setState(() {
      LoadNotification();
    });
  }

  // Méthodes utilitaires pour accéder aux attributs notifiable
  String? _getNotificationImage(NotificationModel notification) {
    if (notification.notifiable == null) return null;

    switch (notification.type) {
      case NotificationType.invitationNotification:
        Invitation invitation = notification.notifiable as Invitation;
        switch (invitation.type) {
          case InvitationType.team:
            if (invitation.invitable is TeamInvitable) {
              return (invitation.invitable as TeamInvitable).fullImagePath;
            }
            break;

          case InvitationType.friend:
            // Toujours retourner null pour les friend requests afin d'utiliser l'icône utilisateur
            return null;

          case InvitationType.match:
            // Les matchs n'ont généralement pas d'image
            return null;
        }
        break;
    }
    return null;
  }

  String _getNotifiableName(NotificationModel notification) {
    if (notification.notifiable == null) {
      return 'Inconnu';
    }
    Invitation invitation = notification.notifiable as Invitation;
    switch (invitation.type) {
      case InvitationType.team:
        if (invitation.invitable is TeamInvitable) {
          return (invitation.invitable as TeamInvitable).name;
        }
        return 'Équipe';
      case InvitationType.friend:
        if (invitation.invitable is UserInvitable) {
          return (invitation.invitable as UserInvitable).name;
        }
        return invitation.sender.name;
      case InvitationType.match:
        if (invitation.invitable is GameInvitable) {
          return (invitation.invitable as GameInvitable).name;
        }
        return 'Match';
    }
  }
}
