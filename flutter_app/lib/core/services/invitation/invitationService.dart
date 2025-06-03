import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Invitation.dart';
import 'package:http/http.dart' as http;

const INVITATION_URL = "$API_URL/api/invitations";

Future<bool> respondToInvitation(
    int id_invitation, InvitationStatus status, String token) async {
  try {
    final response = await http.patch(
      Uri.parse('$INVITATION_URL/$id_invitation/status'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': " Bearer $token",
      },
      body: jsonEncode({
        'status': status
            .toString()
            .split('.')
            .last
            .toLowerCase(), // 'accepted' ou 'rejected'
      }),
    );

    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      return true;
      ;
    }

    return false;
  } catch (e) {
    return false;
    // Debug log
  }
}
