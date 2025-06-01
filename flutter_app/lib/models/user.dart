class User {
  final int id; // Changé de String à dynamic pour supporter les deux types
  final String name;
  final String email;
  final String? profileImage;
  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // Accepte maintenant les deux types
      name: json['username'] ??
          json['name'] ??
          'Utilisateur sans nom', // Gestion des valeurs null
      email: json['email'] ?? 'email@exemple.com', // Gestion des valeurs null
      profileImage: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profileImage,
    };
  }
}
