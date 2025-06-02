import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Notification.dart';

import 'package:http/http.dart' as http;

const NOTIFICATION_URL = "$API_URL/api/notifications";



Future<List<NotificationModel>> getNotificationOfUser(String token) async {
  print("Calling Fetch Notificaiton of User");
  final url = Uri.parse("$NOTIFICATION_URL/user");
  final response = await http.get(url,
      headers: {
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

void main() async {
  final reservations = await getNotificationOfUser('100|C8WuXahQ6RxE9tjOQY5GLzKtnDOjZC2149w3JDKE3ea68020');
  print(reservations);
}
