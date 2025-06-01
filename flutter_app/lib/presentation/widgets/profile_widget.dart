import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class ProfileWidget extends ConsumerWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Accès direct au token
    final accessToken = ref.watch(accessTokenProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statut: ${isAuthenticated ? "Connecté" : "Déconnecté"}'),
            const SizedBox(height: 16),
            if (currentUser != null) ...[
              Text('Nom: ${currentUser.name}'),
              Text('Email: ${currentUser.email}'),
              const SizedBox(height: 16),
              Text('Token disponible: ${accessToken != null ? "Oui" : "Non"}'),
              if (accessToken != null) ...[
                const SizedBox(height: 16),
                Text('Token (tronqué): ${accessToken.substring(0, 20)}...'),
              ],
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: accessToken != null
                  ? () => _makeAuthenticatedRequest(ref)
                  : null,
              child: const Text('Faire une requête authentifiée'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeAuthenticatedRequest(WidgetRef ref) async {
    final token = ref.read(accessTokenProvider);
    print('Utilisation du token: Bearer $token');
    // Faire une requête HTTP avec ce token
  }
}
