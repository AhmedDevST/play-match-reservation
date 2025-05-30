import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Sport.dart';
class Team {
  final int id;
  final String name;
  final String? image;
  final int totalScore;
  final double averageRating;
  final Sport sport;

  Team({
    required this.id,
    required this.name,
    this.image,
    required this.totalScore,
    required this.averageRating,
    required this.sport,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      totalScore: json['total_score'],
      averageRating: (json['average_rating'] as num).toDouble(),
      sport: Sport.fromJson(json['sport']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'total_score': totalScore,
      'average_rating': averageRating,
    };
  }
  String get fullImagePath =>
      "$API_URL$image";
}
