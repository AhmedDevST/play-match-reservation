import 'package:flutter/material.dart';

class StatusColorUtil {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'canceled':
        return Colors.red;
      case 'live':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
