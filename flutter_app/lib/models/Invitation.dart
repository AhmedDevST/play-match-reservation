import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Notification.dart';
import 'package:flutter_app/models/User.dart';

enum InvitationType { friend, team, match }

enum InvitationStatus { pending, accepted, rejected }

class Invitation implements NotifiableObject {
  final int id;
  final User sender;
  final User receiver;
  final InvitationType type;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? invitableType;
  final int invitableId;
  final InvitableObject? invitable;

  Invitation({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.invitableType,
    required this.invitableId,
    this.invitable,
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
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      invitableType: json['invitable_type'],
      invitableId: json['invitable_id'],
      invitable: json['invitable'] != null
          ? InvitableObject.fromJson(
              json['invitable'],
              InvitationType.values.firstWhere(
                (e) => e.toString().split('.').last == json['type'],
              ))
          : null,
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
      'updated_at': updatedAt?.toIso8601String(),
      'invitable_type': invitableType,
      'invitable_id': invitableId,
      'invitable': invitable?.toJson(),
    };
  }
}

// Classe abstraite pour les objets notifiables
abstract class InvitableObject {
  final int id;
  final String name;

  InvitableObject({
    required this.id,
    required this.name,
  });

  factory InvitableObject.fromJson(
      Map<String, dynamic> json, InvitationType invitationType) {
    switch (invitationType) {
      case InvitationType.team:
        return TeamInvitable.fromJson(json);
      case InvitationType.match:
        return GameInvitable.fromJson(json);
      case InvitationType.friend:
        return UserInvitable.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

// Modèle pour les notifications d'équipe
class TeamInvitable extends InvitableObject {
  final String? image;

  TeamInvitable({
    required super.id,
    required super.name,
    this.image,
  });

  factory TeamInvitable.fromJson(Map<String, dynamic> json) {
    return TeamInvitable(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
    };
  }

  String get fullImagePath {
    if (image == null) return '';
    return "$API_URL$image";
  }
}

// Modèle pour les notifications de jeu
class GameInvitable extends InvitableObject {
  final String? status;
  final String? type;

  GameInvitable({
    required super.id,
    required super.name,
    this.status,
    this.type,
  });

  factory GameInvitable.fromJson(Map<String, dynamic> json) {
    return GameInvitable(
      id: json['id'],
      name: json['name'] ?? 'Match #${json['id']}',
      status: json['status'],
      type: json['type'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'type': type,
    };
  }
}

// Modèle pour les notifications d'utilisateur
class UserInvitable extends InvitableObject {
  final String? avatar;
  final String? email;

  UserInvitable({
    required super.id,
    required super.name,
    this.avatar,
    this.email,
  });

  factory UserInvitable.fromJson(Map<String, dynamic> json) {
    return UserInvitable(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      email: json['email'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
    };
  }
}
