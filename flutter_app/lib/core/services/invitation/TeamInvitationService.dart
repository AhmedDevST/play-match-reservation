import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Invitation.dart';
import 'package:flutter_app/models/User.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

const TEAM_INVITATION_URL = "$API_URL/api/teams/invitations";

class TeamInvitationService {
  /// Envoyer une invitation d'équipe à un utilisateur
  Future<Invitation> sendInvitation(User receiver) async {
    try {
      final response = await http.post(
        Uri.parse('$TEAM_INVITATION_URL/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'receiver_id': receiver.id,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Invitation.fromJson(data['invitation']);
      } else if (response.statusCode == 403) {
        throw Exception(
            'Vous devez être capitaine d\'une équipe pour envoyer des invitations');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message']);
      }

      throw Exception(
          'Erreur lors de l\'envoi de l\'invitation: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error in sendInvitation: $e'); // Debug log
      rethrow;
    }
  }

  /// Récupérer les invitations d'équipe en attente
  Future<List<Invitation>> getPendingInvitations() async {
    try {
      final response = await http.get(
        Uri.parse('$TEAM_INVITATION_URL/pending'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['invitations'] as List)
            .map((invitation) => Invitation.fromJson(invitation))
            .toList();
      }

      throw Exception(
          'Erreur lors de la récupération des invitations: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error in getPendingInvitations: $e'); // Debug log
      rethrow;
    }
  }

  /// Répondre à une invitation d'équipe
  Future<Invitation> respondToInvitation(
      Invitation invitation, InvitationStatus status) async {
    try {
      final response = await http.post(
        Uri.parse('$TEAM_INVITATION_URL/${invitation.id}/respond'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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
        final data = jsonDecode(response.body);
        return Invitation.fromJson(data['invitation']);
      } else if (response.statusCode == 403) {
        throw Exception('Non autorisé à répondre à cette invitation');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message']);
      }

      throw Exception(
          'Erreur lors de la réponse à l\'invitation: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error in respondToInvitation: $e'); // Debug log
      rethrow;
    }
  }

  // Récupérer les utilisateurs invités pour une équipe spécifique
  Future<List<Invitation>> getInvitedUsers(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$API_URL/api/team/$teamId/invited-users'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['invited_users'] == null) {
          return [];
        }

        final List<dynamic> invitedUsers = data['invited_users'];
        return invitedUsers
            .where((invitation) => invitation != null)
            .map((invitation) {
              try {
                return Invitation.fromJson(invitation as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing invitation: $e');
                return null;
              }
            })
            .where((invitation) => invitation != null)
            .cast<Invitation>()
            .toList();
      } else if (response.statusCode == 403) {
        throw Exception(
            'Vous n\'êtes pas autorisé à voir les utilisateurs invités');
      } else if (response.statusCode == 404) {
        return [];
      }

      throw Exception(
          'Erreur lors de la récupération des utilisateurs invités: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error in getInvitedUsers: $e'); // Debug log
      rethrow;
    }
  }
}
