import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class LoginWidget extends ConsumerStatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // URL de votre API Laravel
  static const String apiUrl = 'http://your-laravel-api.com/api';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // 1. 🌐 Appel à l'API backend Laravel
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 2. 📦 Extraire les données de la réponse JSON
        final user = User.fromJson(data['user']);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        // 3. 🚀 Le AuthProvider s'occupe de TOUT le reste !
        await ref.read(authProvider.notifier).login(
              user: user,
              accessToken: accessToken,
              refreshToken: refreshToken,
            );

        // 4. ✅ L'utilisateur est maintenant connecté dans toute l'app !
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bienvenue ${user.name}!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Erreur d'authentification
        final errorData = jsonDecode(response.body);
        _showError(errorData['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      _showError('Erreur de réseau: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Widget qui montre comment l'état change automatiquement
class HomeWidget extends ConsumerWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Le provider fournit automatiquement les données
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Statut: ${isAuthenticated ? "Connecté" : "Déconnecté"}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (currentUser != null) ...[
              const SizedBox(height: 16),
              Text('Nom: ${currentUser.name}'),
              Text('Email: ${currentUser.email}'),
            ],
            const SizedBox(height: 24),
            const Text(
              '🎉 Toutes ces données viennent automatiquement du AuthProvider !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour faire des requêtes authentifiées
class AuthenticatedRequestExample extends ConsumerWidget {
  const AuthenticatedRequestExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔐 Headers avec token automatiquement inclus
    final headers = ref.watch(authHeadersProvider);

    return ElevatedButton(
      onPressed: () async {
        // Requête authentifiée automatique !
        final response = await http.get(
          Uri.parse('http://your-api.com/api/user/profile'),
          headers: headers, // Token inclus automatiquement
        );

        if (response.statusCode == 200) {
          print('Données reçues: ${response.body}');
        } else if (response.statusCode == 401) {
          // Token expiré, se déconnecter
          ref.read(authProvider.notifier).logout();
        }
      },
      child: const Text('Faire une requête authentifiée'),
    );
  }
}
