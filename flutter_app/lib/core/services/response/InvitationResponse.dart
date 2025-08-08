import 'package:flutter_app/models/Invitation.dart';

class InvitationResponse {
  final bool success;
  final String message;
  final Invitation? invitation;
  final List<String>? errors;

  InvitationResponse({
    required this.success,
    required this.message,
    this.invitation,
    this.errors,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      invitation: json['invitation'] != null
          ? Invitation.fromJson(json['invitation'])
          : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}
