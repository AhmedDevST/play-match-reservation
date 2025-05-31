import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/providers/auth_provider.dart';

class UserDataWidget extends ConsumerStatefulWidget {
  const UserDataWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<UserDataWidget> createState() => _UserDataWidgetState();
}

class _UserDataWidgetState extends ConsumerState<UserDataWidget> {
  List<dynamic> userData = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Données Utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchUserData,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Charger mes données'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: userData.isEmpty
                  ? const Center(child: Text('Aucune donnée chargée'))
                  : ListView.builder(
                      itemCount: userData.length,
                      itemBuilder: (context, index) {
                        final item = userData[index];
                        return ListTile(
                          title: Text(item['title'] ?? 'Sans titre'),
                          subtitle:
                              Text(item['description'] ?? 'Sans description'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchUserData() async {
    setState(() => isLoading = true);

    try {
      // 🔑 Utilisation automatique des headers avec token
      final headers = ref.read(authHeadersProvider);

      final response = await http.get(
        Uri.parse('http://localhost:8000/api/user/data'),
        headers:
            headers, // Headers contiennent automatiquement "Authorization: Bearer token"
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userData = data['data'] ?? [];
        });
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        _handleUnauthorized();
      } else {
        _showError('Erreur lors du chargement des données');
      }
    } catch (e) {
      _showError('Erreur de connexion: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleUnauthorized() {
    // Déconnecter l'utilisateur si le token est invalide
    ref.read(authProvider.notifier).logout();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session expirée, veuillez vous reconnecter'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
