import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Notification.dart';

import 'package:http/http.dart' as http;

const NOTIFICATION_URL = "$API_URL/api/notifications";

Future<List<NotificationModel>> getNotificationOfUser(String token) async {
  final url = Uri.parse("$NOTIFICATION_URL/user");
  final response = await http.get(url, headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  });
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['notifications'] as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch notification of user");
}

Future<bool> markAsRead(int id_notification, String token) async {
  try {
    final response = await http.patch(
      Uri.parse('$NOTIFICATION_URL/$id_notification/read'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': " Bearer $token",
      },
    );
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    return false;
  }
}
