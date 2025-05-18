import 'package:flutter_app/core/config/apiConfig.dart';

class Sport {
  final int id;
  final String name;
  final String? image;
  final int minPlayers;
  final int maxPlayers;

  Sport({
    required this.id,
    required this.name,
    this.image,
    required this.minPlayers,
    required this.maxPlayers,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      minPlayers: json['min_players'],
      maxPlayers: json['max_players'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'min_players': minPlayers,
      'max_players': maxPlayers,
    };
  }
  String get fullImagePath =>
      "$API_URL$image";
}
