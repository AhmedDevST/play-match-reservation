import 'package:flutter_app/models/PublicGame.dart';

class HomeResponse {
  final bool success;
  final String message;
  final List<PublicGame> publicGames;
  final int notifications_count ;
  final List<String>? errors;

  HomeResponse({
    required this.success,
    required this.message,
    required this.publicGames,
    required this.notifications_count,
    this.errors,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      publicGames: json['matches'] != null
          ? List<PublicGame>.from(json['matches'].map((match) => PublicGame.fromJson(match)))
          : <PublicGame>[],
      notifications_count: json['notifications_count'] ?? 0,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}
