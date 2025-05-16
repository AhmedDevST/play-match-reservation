import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/landing/landing_page.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:flutter_app/presentation/pages/profile/profile_page.dart';
import 'package:flutter_app/presentation/pages/home/friends/Network.dart';
import 'package:flutter_app/presentation/pages/messaging/ChatListPage.dart';
import 'package:flutter_app/presentation/pages/messaging/ChatDetailPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application Sportive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/friends': (context) => const NetworkPage(),
        '/messages': (context) => const ChatListPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat_detail') {
          final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChatDetailPage(chatData: args),
          );
        }
        return null;
      },
    );
  }
}
