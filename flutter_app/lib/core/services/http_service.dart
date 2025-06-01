import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_constants.dart';
import '../../providers/auth_provider.dart';

class HttpService {
  final String? token;
  
  HttpService({this.token});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) ApiConstants.authHeader: '${ApiConstants.bearerPrefix} $token',
  };

  Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Failed to perform GET request: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(body['message'] ?? 'Unknown error occurred');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Unauthorized');
}

final httpServiceProvider = Provider.family<HttpService, String?>((ref, token) {
  return HttpService(token: token);
});
