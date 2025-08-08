import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/models/Invitation.dart';

class PublicGame {
  final Game game;
  final TimeSlot timeSlot;
  final SportFacility facility;
  final Invitation? invitation;

  PublicGame({
    required this.game,
    required this.timeSlot,
    required this.facility,
    this.invitation,
  });

  factory PublicGame.fromJson(Map<String, dynamic> json) {
    return PublicGame(
      game: Game.fromJson(json['game']),
      timeSlot: TimeSlot.fromJson(json['time_slot']),
      facility: SportFacility.fromJson(json['facility']),
      invitation: json['invitation'] != null
          ? Invitation.fromJson(json['invitation'])
          : null,
    );
  }

  PublicGame copyWith({
    Game? game,
    TimeSlot? timeSlot,
    SportFacility? facility,
    Invitation? invitation,
  }) {
    return PublicGame(
      game: game ?? this.game,
      timeSlot: timeSlot ?? this.timeSlot,
      facility: facility ?? this.facility,
      invitation: invitation ?? this.invitation,
    );
  }
}
