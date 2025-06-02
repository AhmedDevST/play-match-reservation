import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedFilter = 'Tout';

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.friendNotification,
      title: 'Demande d\'amitié',
      message: 'Ahmed Youness vous a envoyé une demande d\'amitié',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      avatarUrl: null,
      senderName: 'Ahmed Youness',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.teamNotification,
      title: 'Invitation d\'équipe',
      message: 'Vous avez été invité à rejoindre l\'équipe "Les Tigres"',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      avatarUrl: null,
      senderName: 'Capitaine',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.matchNotification,
      title: 'Résultat de match',
      message:
          'Votre équipe "Les Lions" a gagné le match contre "Les Aigles" 3-2',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
      avatarUrl: null,
      senderName: 'Système',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.teamNotification,
      title: 'Nouveau membre',
      message: 'Sarah Martin a rejoint votre équipe "Les Lions"',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      avatarUrl: null,
      senderName: 'Sarah Martin',
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.matchNotification,
      title: 'Match programmé',
      message:
          'Un nouveau match a été programmé pour demain à 16h00 contre "Les Panthères"',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      avatarUrl: null,
      senderName: 'Capitaine',
    ),
    NotificationItem(
      id: '6',
      type: NotificationType.friendNotification,
      title: 'Ami accepté',
      message: 'Mohamed Hassan a accepté votre demande d\'amitié',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
      avatarUrl: null,
      senderName: 'Mohamed Hassan',
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'Tout') {
      return _notifications;
    }

    switch (_selectedFilter) {
      case 'Amis':
        return _notifications
            .where((n) => n.type == NotificationType.friendNotification)
            .toList();
      case 'Équipes':
        return _notifications
            .where((n) => n.type == NotificationType.teamNotification)
            .toList();
      case 'Matchs':
        return _notifications
            .where((n) => n.type == NotificationType.matchNotification)
            .toList();
      default:
        return _notifications;
    }
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
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
                  return _buildNotificationCard(filteredNotifications[index]);
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
            _buildFilterChip('Tout', _selectedFilter == 'Tout'),
            const SizedBox(width: 8),
            _buildFilterChip('Amis', _selectedFilter == 'Amis'),
            const SizedBox(width: 8),
            _buildFilterChip('Équipes', _selectedFilter == 'Équipes'),
            const SizedBox(width: 8),
            _buildFilterChip('Matchs', _selectedFilter == 'Matchs'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
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
          label,
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

  Widget _buildNotificationCard(NotificationItem notification) {
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
                                notification.senderName,
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
                                color: _getNotificationColor(notification.type)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(
                                  color:
                                      _getNotificationColor(notification.type),
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
                                NotificationType.teamNotification &&
                            !notification.isRead)
                          _buildInvitationActions(notification),
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

  Widget _buildNotificationAvatar(NotificationItem notification) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              border: Border.all(
                color:
                    _getNotificationColor(notification.type).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: notification.avatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      notification.avatarUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
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

  Widget _buildInvitationActions(NotificationItem notification) {
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

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.friendNotification:
        return Icons.person_add;
      case NotificationType.teamNotification:
        return Icons.group_add;
      case NotificationType.matchNotification:
        return Icons.sports_soccer;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.friendNotification:
        return const Color(0xFF3182CE);
      case NotificationType.teamNotification:
        return const Color(0xFF4299E1);
      case NotificationType.matchNotification:
        return const Color(0xFF48BB78);
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

  void _handleNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.friendNotification:
        // Naviguer vers les amis
        break;
      case NotificationType.teamNotification:
        // Naviguer vers les équipes
        break;
      case NotificationType.matchNotification:
        // Naviguer vers les matchs
        break;
    }
  }

  void _acceptInvitation(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invitation acceptée !'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _declineInvitation(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invitation refusée'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _refreshNotifications() async {
    // Simuler le rechargement
    await Future.delayed(const Duration(seconds: 1));

    // Ici vous pourriez recharger les notifications depuis l'API
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notifications mises à jour'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// Modèles de données
enum NotificationType {
  friendNotification,
  teamNotification,
  matchNotification,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String? avatarUrl;
  final String senderName;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.avatarUrl,
    required this.senderName,
  });
}
