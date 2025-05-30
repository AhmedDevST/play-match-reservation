import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  // Méthode pour définir l'utilisateur après connexion
  void setUser(User user) {
    state = user;
  }

  // Méthode pour déconnecter l'utilisateur
  void logout() {
    state = null;
  }
}
