import 'package:flutter_app/models/User.dart';

enum InvitationType { friend, team, match }

enum InvitationStatus { pending, accepted, rejected }

class Invitation {
  final int id;
  final User sender;
  final User receiver;
  final InvitationType type;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Invitation({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      sender: json['sender'] != null
          ? User.fromJson(json['sender'])
          : User.fromJson({
              'id': json['sender_id'],
              'name': 'Capitaine', // Valeur par défaut
              'email': '', // Valeur par défaut
              'profile_image': null,
            }),
      receiver: User.fromJson(json['receiver']),
      type: InvitationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
