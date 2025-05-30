import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/User.dart';
import 'package:flutter_app/core/config/apiConfig.dart';

class UserService {
  Future<List<User>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/users/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Failed to search users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  //Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> users = responseData['data'];
          return users.map((user) => User.fromJson(user)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}
