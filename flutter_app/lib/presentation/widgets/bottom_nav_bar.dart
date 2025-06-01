import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
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
              onItemSelected(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
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
}
