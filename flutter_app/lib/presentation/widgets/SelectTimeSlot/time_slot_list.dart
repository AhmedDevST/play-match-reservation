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
    Key? key,
    required this.timeSlots,
    required this.selectedTimeZone,
    required this.slotFilter,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelected,
  }) : super(key: key);

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

    if (slots.isEmpty) {
      return Center(
         child: Lottie.network(
         "https://lottie.host/737bc8cb-4eb1-4821-9473-5a6fd5c260a3/VhVQcvzrZV.json",
         ),
        /*
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No time slots available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),*/
      );
    }

    return ListView.builder(
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final slot = slots[i];
        final isBooked = slot.status == 'reserved';
        final isSelected = selectedTimeSlot == slot;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: isBooked ? null : () => onTimeSlotSelected(slot),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isBooked
                    ? Colors.redAccent
                    : isSelected
                        ? Colors.blue
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isBooked
                      ? Colors.redAccent
                      : isSelected
                          ? Colors.blue
                          : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${slot.startTime} - ${slot.endTime}',
                  style: TextStyle(
                    color: isBooked
                        ? Colors.white
                        : isSelected
                            ? Colors.white
                            : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
