import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/core/services/response/api_responses.dart';
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

Future<InvitationResponse> sendInvitation(int invitable_id,String type,int receiver_id , String token) async {
  try {
    final response = await http.post(
      Uri.parse('$INVITATION_URL'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': " Bearer $token",
      },
      body: jsonEncode({
        'invitable_id': invitable_id,
        'type': type,
        'receiver_id': receiver_id,
      }),
    );
     final data = jsonDecode(response.body);
    return InvitationResponse.fromJson(data);
 } catch (e) {
    return InvitationResponse(
      success: false,
      message: 'Failed to parse response $e',
    );
  }
}

void main() async {
  final response = await sendInvitation(31,"match",1,"60|c49LQv2MunJu1MXKNeVrxrdDvJbvRMae1w8gXGim59c38f87");
  print('Response: ${response.success}, Message: ${response.message}, Errors: ${response.errors} , Invitation: ${response.data?.id}');
}


