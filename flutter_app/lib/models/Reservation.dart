import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';

class Reservation {
  int id;
  int userId;
  SportFacility facility;
  TimeSlot ?timeSlot;
  DateTime date;
  Game ?game;
 

  Reservation({
    required this.id,
    required this.userId,
    required this.facility,
    this.timeSlot,
    required this.date,
    this.game,
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

  
}