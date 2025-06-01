import 'package:flutter_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.accessToken,
    this.refreshToken,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  // Method to set the token
  AuthState setToken(String token) {
    return copyWith(accessToken: token);
  }

  // État initial (non authentifié)
  factory AuthState.initial() {
    return const AuthState();
  }

  // État authentifié
  factory AuthState.authenticated({
    required User user,
    required String accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
  }

  // État déconnecté
  factory AuthState.unauthenticated() {
    return const AuthState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.isAuthenticated == isAuthenticated;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        accessToken.hashCode ^
        refreshToken.hashCode ^
        isAuthenticated.hashCode;
  }

  @override
  String toString() {
    return 'AuthState(user: $user, accessToken: ${accessToken != null ? '[HIDDEN]' : 'null'}, refreshToken: ${refreshToken != null ? '[HIDDEN]' : 'null'}, isAuthenticated: $isAuthenticated)';
  }
}
