import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';

class ApiService {
  final Ref ref;
  static const String baseUrl = 'http://localhost:8000/api';

  ApiService(this.ref);

  // 🔑 Headers automatiques avec token
  Map<String, String> get headers => ref.read(authHeadersProvider);

  // GET request avec authentification automatique
  Future<http.Response> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _handleResponse(response);
  }

  // POST request avec authentification automatique
  Future<http.Response> post(String endpoint, {Object? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    
    return _handleResponse(response);
  }

  // PUT request avec authentification automatique
  Future<http.Response> put(String endpoint, {Object? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    
    return _handleResponse(response);
  }

  // DELETE request avec authentification automatique
  Future<http.Response> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    
    return _handleResponse(response);
  }

  // Gestion centralisée des réponses
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Token expiré, déconnecter l'utilisateur
      ref.read(authProvider.notifier).logout();
    }
    return response;
  }

  // Méthodes spécifiques à votre API
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await get('/user/profile');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors de la récupération du profil');
  }

  Future<List<dynamic>> getUserBookings() async {
    final response = await get('/user/bookings');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['bookings'] ?? [];
    }
    throw Exception('Erreur lors de la récupération des réservations');
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final response = await put('/user/profile', body: profileData);
    return response.statusCode == 200;
  }
}

// Provider pour le service API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});