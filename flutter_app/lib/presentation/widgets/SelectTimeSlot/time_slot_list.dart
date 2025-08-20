import 'package:flutter/material.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/models/TimeZone.dart';
import 'package:lottie/lottie.dart';

class TimeSlotsList extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeZone selectedTimeZone;
  final String slotFilter;
  final TimeSlot? selectedTimeSlot;
  final Function(TimeSlot) onTimeSlotSelected;

  const TimeSlotsList({
    super.key,
    required this.timeSlots,
    required this.selectedTimeZone,
    required this.slotFilter,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  });

  List<TimeSlot> get filteredSlots {
    return timeSlots
        .where((slot) =>
            slot.timeZone.id == selectedTimeZone.id &&
            ((slotFilter == 'available' && slot.status == 'available') ||
             (slotFilter == 'booked' && slot.status == 'reserved')))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final slots = filteredSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2EE59D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.event_available,
                color: Color(0xFF2EE59D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Available Time Slots',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: slots.isEmpty ? _buildEmptyState() : _buildSlotsList(slots),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Lottie.network(
              "https://lottie.host/737bc8cb-4eb1-4821-9473-5a6fd5c260a3/VhVQcvzrZV.json",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No time slots available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try selecting a different date or time zone',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList(List<TimeSlot> slots) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isBooked = slot.status == 'reserved';
        final isSelected = selectedTimeSlot == slot;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: isBooked ? null : () => onTimeSlotSelected(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _getContainerGradient(isBooked, isSelected),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _getBorderColor(isBooked, isSelected),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: _getBoxShadow(isBooked, isSelected),
              ),
              child: Row(
                children: [
                  // Time display section
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getIconBackgroundColor(isBooked, isSelected),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getStatusIcon(isBooked),
                            color: _getIconColor(isBooked, isSelected),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${slot.startTime} - ${slot.endTime}',
                              style: TextStyle(
                                color: _getTextColor(isBooked, isSelected),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(isBooked),
                              style: TextStyle(
                                color: _getSubtitleColor(isBooked, isSelected),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusBadgeColor(isBooked, isSelected),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusBadgeText(isBooked, isSelected),
                      style: TextStyle(
                        color: _getStatusBadgeTextColor(isBooked, isSelected),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper methods for styling
  Gradient? _getContainerGradient(bool isBooked, bool isSelected) {
    if (isBooked) {
      return const LinearGradient(
        colors: [Color(0xFFFF5722), Color(0xFFE53935)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (isSelected) {
      return const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return null;
  }

  Color _getBorderColor(bool isBooked, bool isSelected) {
    if (isBooked) return const Color(0xFFFF5722);
    if (isSelected) return const Color(0xFF1E88E5);
    return Colors.grey.shade200;
  }

  List<BoxShadow> _getBoxShadow(bool isBooked, bool isSelected) {
    if (isBooked) {
      return [
        BoxShadow(
          color: const Color(0xFFFF5722).withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isSelected) {
      return [
        BoxShadow(
          color: const Color(0xFF1E88E5).withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 2),
      ),
    ];
  }

  IconData _getStatusIcon(bool isBooked) {
    return isBooked ? Icons.lock : Icons.access_time;
  }

  Color _getIconBackgroundColor(bool isBooked, bool isSelected) {
    if (isBooked || isSelected) return Colors.white.withOpacity(0.2);
    return const Color(0xFF1E88E5).withOpacity(0.1);
  }

  Color _getIconColor(bool isBooked, bool isSelected) {
    if (isBooked || isSelected) return Colors.white;
    return const Color(0xFF1E88E5);
  }

  Color _getTextColor(bool isBooked, bool isSelected) {
    if (isBooked || isSelected) return Colors.white;
    return Colors.black87;
  }

  Color _getSubtitleColor(bool isBooked, bool isSelected) {
    if (isBooked || isSelected) return Colors.white70;
    return Colors.grey.shade600;
  }

  String _getStatusText(bool isBooked) {
    return isBooked ? 'Already booked' : 'Available for booking';
  }

  Color _getStatusBadgeColor(bool isBooked, bool isSelected) {
    if (isBooked) return Colors.white.withOpacity(0.2);
    if (isSelected) return Colors.white.withOpacity(0.2);
    return const Color(0xFF2EE59D).withOpacity(0.1);
  }

  String _getStatusBadgeText(bool isBooked, bool isSelected) {
    if (isBooked) return 'Booked';
    if (isSelected) return 'Selected';
    return 'Available';
  }

  Color _getStatusBadgeTextColor(bool isBooked, bool isSelected) {
    if (isBooked || isSelected) return Colors.white;
    return const Color(0xFF2EE59D);
  }
}