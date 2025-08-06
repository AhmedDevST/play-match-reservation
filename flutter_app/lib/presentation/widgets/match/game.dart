// Model for match data
import 'package:flutter/material.dart';

class Game {
  final String imageUrl;
  final String proposedBy;
  final String sport;
  final DateTime date;
  final String address;
  final Color? teamColor;
  bool isInvitationSent;

  Game({
    required this.imageUrl,
    required this.proposedBy,
    required this.sport,
    required this.date,
    required this.address,
    this.teamColor,
    this.isInvitationSent = false,
  });
}