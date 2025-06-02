import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';


enum ReservationStatus {
  pending,
  paid,
  cancelled,
  completed
}

extension ReservationStatusExtension on ReservationStatus {
  String get value {
    switch (this) {
      case ReservationStatus.pending:
        return 'pending';
      case ReservationStatus.paid:
        return 'paid';
      case ReservationStatus.cancelled:
        return 'cancelled';
      case ReservationStatus.completed:
        return 'completed';
    }
  }

  static ReservationStatus fromString(String status) {
    switch (status) {
      case 'pending':
        return ReservationStatus.pending;
      case 'paid':
        return ReservationStatus.paid;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      default:
        return ReservationStatus.pending;
    }
  }
}
class Reservation {
  int id;
  int userId;
  SportFacility facility;
  TimeSlot ?timeSlot;
  DateTime date;
  Game ?game;
  bool autoConfirm;
  String ?status;

 

  Reservation({
    required this.id,
    required this.userId,
    required this.facility,
    this.timeSlot,
    required this.date,
    this.game,
    this.autoConfirm = true,
    this.status
  });

  factory Reservation.init({
    required int userId,
    required SportFacility facility,
  }) {
    return Reservation(
      id: 1, 
      userId: userId,
      facility: facility,
      timeSlot: null,
      date: DateTime.now(),
      game: null,
    );
  }
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      facility: SportFacility.fromJson(json['facility']),
      timeSlot: json['time_slot'] != null ? TimeSlot.fromJson(json['time_slot']) : null,
      date: DateTime.parse(json['date']),
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      autoConfirm: json['auto_confirm'] ?? true,
    );
  }

  
}