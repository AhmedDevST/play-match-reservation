import 'package:flutter/material.dart';
import 'package:flutter_app/models/TimeZone.dart';

class TimeZoneSelector extends StatelessWidget {
  final List<TimeZone> timeZones;
  final TimeZone selectedTimeZone;
  final Function(TimeZone) onTimeZoneSelected;

  const TimeZoneSelector({
    super.key,
    required this.timeZones,
    required this.selectedTimeZone,
    required this.onTimeZoneSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select slots',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeZones.map((zone) {
            final isSelected = zone.id == selectedTimeZone.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: OutlinedButton(
                  onPressed: () => onTimeZoneSelected(zone),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? Theme.of(context).primaryColor : Colors.white,
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    zone.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}