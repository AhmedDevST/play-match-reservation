import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/TeamPlayer.dart';

class Team {
  final int id;
  final String name;
  final int totalScore;
  final String? image;
  final double averageRating;
  final Sport sport;
  List<TeamPlayer>? players;

  Team({
    required this.id,
    required this.name,
    required this.totalScore,
    this.image,
    required this.averageRating,
    required this.sport,
    this.players = const [],
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      totalScore: json['total_score'] ?? 0,
      image: json['image'],
      averageRating: (json['average_rating'] as num).toDouble(),
      sport: Sport.fromJson(json['sport']),
      players: json['players'] != null
          ? List<TeamPlayer>.from(
              json['players'].map((x) => TeamPlayer.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_score': totalScore,
      'image': image,
      'average_rating': averageRating,
      'sport': sport.toJson(),
    };
  }

  String get fullImagePath {
    if (image == null) return '';
    return "$API_URL$image";
  }
}
