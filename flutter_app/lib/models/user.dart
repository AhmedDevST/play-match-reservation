import 'package:flutter_app/core/config/apiConfig.dart';

class User {
  final int id; // Changé de String à dynamic pour supporter les deux types
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;
  final String? memberSince; // Date d'inscription
  final double? rating; // Note moyenne de l'utilisateur

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
    this.memberSince,
    this.rating,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Accepte maintenant les deux types
      name: json['username'] ??
          json['name'] ??
          'Utilisateur sans nom', // Gestion des valeurs null
      email: json['email'] ?? 'email@exemple.com', // Gestion des valeurs null
      profileImage: json['profile_picture'],
      bio: json['bio'] ?? 'Aucune biographie disponible',
      memberSince: json['member_since'] ?? 'N/A',
      rating: json['rating']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profileImage,
      'bio': bio,
      'member_since': memberSince,
      'rating': rating,
    };
  }
  String get fullImagePath{

    
      return '$API_URL$profileImage'; // Chemin par défaut
  
  }
}
