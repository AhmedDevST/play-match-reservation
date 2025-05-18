import 'package:flutter/material.dart';

class SportChip extends StatelessWidget {
  final String label;
  const SportChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 12,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColorLight,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
} 