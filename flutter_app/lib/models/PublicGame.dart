import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';

class PublicGame {
  final Game game;
  final TimeSlot timeSlot;
  final SportFacility facility;

  PublicGame({
    required this.game,
    required this.timeSlot,
    required this.facility,
  });

  factory PublicGame.fromJson(Map<String, dynamic> json) {
    return PublicGame(
      game: Game.fromJson(json['game']),
      timeSlot: TimeSlot.fromJson(json['time_slot']),
      facility: SportFacility.fromJson(json['facility']),
    );
  }
}