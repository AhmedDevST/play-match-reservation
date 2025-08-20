import 'package:flutter_app/models/TimeZone.dart';

class TimeSlot {
  final int id;
  final String startTime;
  final String endTime;
  final String  status;
  final bool isException;
  final DateTime date;
  final String? exceptionReason;
  final TimeZone timeZone;
 
  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isException,
    required this.exceptionReason,
    required this.timeZone,
    required this.date,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
      isException: json['is_exception'],
      exceptionReason: json['exception_reason'] as String?,
      timeZone: TimeZone.fromJson(json['time_zone']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'is_exception': isException,
      'exception_reason': exceptionReason,
      'time_zone': timeZone.toJson(),
      'date': date.toIso8601String(),
    };
  }
}
