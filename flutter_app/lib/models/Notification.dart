// Énumération pour les types de notifications
import 'package:flutter_app/models/Invitation.dart';

enum NotificationType {
  invitationNotification('invitation_notification');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'invitation_notification':
        return NotificationType.invitationNotification;

      default:
        throw Exception('Type de notification non supporté: $value');
    }
  }
}

class NotificationModel {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final int? notifiableId;
  final Object? notifiable;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.notifiableId,
    this.notifiable,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = NotificationType.fromString(json['type']);
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: type,
      title: json['title'],
      message: json['message'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      notifiableId: json['notifiable_id'],
      notifiable: json['notifiable'] != null
          ? NotifiableObject.fromJson(json['notifiable'], type)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'notifiable_id': notifiableId,
      // 'notifiable': notifiable?.toJson(),
    };
  }
}

// Classe abstraite pour les objets notifiables
abstract class NotifiableObject {
  factory NotifiableObject.fromJson(
      Map<String, dynamic> json, NotificationType notificationType) {
    switch (notificationType) {
      case NotificationType.invitationNotification:
        return Invitation.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

// Modèle pour les notifications d'équipe
