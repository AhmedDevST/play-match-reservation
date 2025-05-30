import 'package:flutter/material.dart';
import 'package:flutter_app/models/TimeZone.dart';

class SlotFilter extends StatelessWidget {
  final TimeZone selectedTimeZone;
  final String slotFilter;
  final Function(String) onFilterChanged;

  const SlotFilter({
    super.key,
    required this.selectedTimeZone,
    required this.slotFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${selectedTimeZone.name} slots',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Radio<String>(
          value: 'available',
          groupValue: slotFilter,
          onChanged: (val) => onFilterChanged(val!),
        ),
        const Text('Available'),
        Radio<String>(
          value: 'booked',
          groupValue: slotFilter,
          onChanged: (val) => onFilterChanged(val!),
        ),
        const Text('Booked'),
      ],
    );
  }
}