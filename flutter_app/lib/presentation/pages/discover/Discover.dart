import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiscoverPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Users'),
      ),
      body: ListView.builder(
        itemCount: 10, // Replace with the actual number of users
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person),
            ),
            title: Text('User $index'), // Replace with actual user name
            trailing: ElevatedButton(
              onPressed: () async {
                // Call the API to send a friendship invitation
                await sendFriendInvitation(index);
              },
              child: const Text('Invite'),
            ),
          );
        },
      ),
    );
  }

  Future<void> sendFriendInvitation(int userId) async {
    final url = Uri.parse('http://your-backend-url/api/invitations/send');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Replace with actual token
      },
      body: jsonEncode({'receiver_id': userId}),
    );

    if (response.statusCode == 201) {
      print('Invitation sent successfully');
    } else {
      print('Failed to send invitation: ${response.body}');
    }
  }
}
