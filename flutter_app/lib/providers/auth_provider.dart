import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/core/services/token_service.dart';
import 'package:flutter_app/providers/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _loadSavedAuth();
  }

  // Charger l'état d'authentification sauvegardé
  Future<void> _loadSavedAuth() async {
    final accessToken = await TokenService.getAccessToken();
    final refreshToken = await TokenService.getRefreshToken();
    final user = await TokenService.getUser();

    if (accessToken != null && user != null) {
      state = AuthState.authenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  // Méthode pour définir l'utilisateur et les tokens après connexion
  Future<void> login({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) async {
    
    // Sauvegarder les tokens et l'utilisateur
    await TokenService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await TokenService.saveUser(user);

    state = AuthState.authenticated(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // Méthode pour mettre à jour seulement l'utilisateur
  Future<void> setUser(User user) async {
    await TokenService.saveUser(user);
    state = state.copyWith(user: user);
  }

  // Méthode pour mettre à jour les tokens
  Future<void> updateTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    final newAccessToken = accessToken ?? state.accessToken;
    final newRefreshToken = refreshToken ?? state.refreshToken;

    if (newAccessToken != null) {
      await TokenService.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
    }

    state = state.copyWith(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
  }

  // Méthode pour mettre à jour seulement l'access token
  Future<void> updateAccessToken(String accessToken) async {
    await TokenService.saveTokens(
      accessToken: accessToken,
      refreshToken: state.refreshToken,
    );
    state = state.copyWith(accessToken: accessToken);
  }

  // Méthode pour mettre à jour seulement le refresh token
  Future<void> updateRefreshToken(String refreshToken) async {
    if (state.accessToken != null) {
      await TokenService.saveTokens(
        accessToken: state.accessToken!,
        refreshToken: refreshToken,
      );
    }
    state = state.copyWith(refreshToken: refreshToken);
  }

  // Méthode pour déconnecter l'utilisateur
  Future<void> logout() async {
    await TokenService.clearAll();
    state = AuthState.unauthenticated();
  }

  // Getters pour faciliter l'accès aux propriétés
  User? get currentUser => state.user;
  String? get accessToken => state.accessToken;
  String? get refreshToken => state.refreshToken;
  bool get isAuthenticated => state.isAuthenticated;
}

// Providers pour faciliter l'accès aux propriétés spécifiques
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).accessToken;
});

final refreshTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).refreshToken;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Provider pour les headers d'authentification (utile pour les requêtes HTTP)
final authHeadersProvider = Provider<Map<String, String>>((ref) {
  final accessToken = ref.watch(accessTokenProvider);
  if (accessToken != null) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }
  return {
    'Content-Type': 'application/json',
  };
});

final rememberMeProvider = StateProvider<bool>((ref) => false);