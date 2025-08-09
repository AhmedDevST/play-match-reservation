import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final int notificationCount; // Add notification count parameter

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.notificationCount = 0, // Default to 0 if not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home, 'label': 'Accueil'},
      {'icon': Icons.people, 'label': 'Amis'},
      {'icon': Icons.notifications, 'label': 'Notifications'},
      {'icon': Icons.calendar_today, 'label': 'Réservations'},
      {'icon': Icons.logout, 'label': 'Déconnexion'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          return InkWell(
            onTap: () {
              if (index == 0) {
                Navigator.of(context).pushNamed('/home');
              } else if (index == 1) {
                Navigator.of(context).pushNamed('/friends');
              } else if (index == 2) {
                Navigator.of(context).pushNamed('/notifications');
              } else if (index == 3) {
                Navigator.of(context).pushNamed('/my-booking');
              } else if (index == 4) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Special handling for notification icon with badge
                index == 2 
                  ? _buildNotificationIconWithBadge(
                      items[index]['icon'],
                      selectedIndex == index
                          ? const Color(0xFF1E88E5)
                          : Colors.grey.shade400,
                      notificationCount,
                    )
                  : Icon(
                      items[index]['icon'],
                      color: selectedIndex == index
                          ? const Color(0xFF1E88E5)
                          : Colors.grey.shade400,
                      size: 22,
                    ),
                const SizedBox(height: 2),
                Text(
                  items[index]['label'],
                  style: TextStyle(
                    color: selectedIndex == index
                        ? const Color(0xFF1E88E5)
                        : Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Helper method to build notification icon with badge
  Widget _buildNotificationIconWithBadge(IconData icon, Color color, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          color: color,
          size: 22,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  } 
}