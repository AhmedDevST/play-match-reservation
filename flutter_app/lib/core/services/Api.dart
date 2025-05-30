import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/core/config/apiConfig.dart';

class ApiResponse {
  final dynamic data;
  final int statusCode;

  ApiResponse(this.data, this.statusCode);
}

class Api {
  final String baseUrl = API_URL;

  Future<ApiResponse> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        jsonDecode(response.body),
        response.statusCode,
      );
    } else {
      throw Exception('Failed to fetch data: ${response.body}');
    }
  }

  Future<ApiResponse> post(String endpoint, {dynamic data}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        jsonDecode(response.body),
        response.statusCode,
      );
    } else {
      throw Exception('Failed to post data: ${response.body}');
    }
  }
}
