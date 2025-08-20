import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/Notification/Notifications.dart';
import 'package:flutter_app/presentation/pages/home/friends/Network.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:flutter_app/presentation/pages/messaging/ChatDetailPage.dart';
import 'package:flutter_app/presentation/pages/profile/profile_page.dart';
import 'package:flutter_app/presentation/pages/reservation/MyBooking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_app/presentation/pages/landing/landing_page.dart';
import 'package:flutter_app/presentation/pages/Team/User_Team_Dash.dart';
import 'package:flutter_app/presentation/pages/Team/Create_Team.dart';
import 'package:flutter_app/presentation/pages/Team/Team_invitations.dart';
import 'package:flutter_app/presentation/pages/Team/Team_details.dart';
import 'package:flutter_app/presentation/pages/reservation/SelectFacilitySport.dart';
import 'package:flutter_app/presentation/pages/splash/splash_screen.dart';
import 'package:flutter_app/core/config/routes.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Play Match Reservation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: Routes.splash,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case Routes.splash:
                return const SplashScreen();
              case Routes.landing:
                return const LandingPage();
              case Routes.booking:
                return const SelectFacilitySport();
              case Routes.myBooking:
                return const MyBooking();
              case Routes.teamDashboard:
                return const UserTeamDash();
              case Routes.createTeam:
                final args = settings.arguments as Map<String, dynamic>?;
                return CreateTeam(userId: args?['userId'] as String);
              case Routes.teamInvitations:
                final args = settings.arguments as Map<String, dynamic>?;
                return TeamInvitations(teamId: args?['teamId'] as int);
              case Routes.teamDetails:
                final teamId = settings.arguments as int;
                return TeamDetails(teamId: teamId);
              case Routes.profile:
                return const ProfilePage();
              case Routes.notifications:
                return const NotificationsPage();
              case Routes.home:
                return const HomePage();
              case Routes.messages:
                return const ChatDetailPage();
              case Routes.friends:
                return const NetworkPage();

              default:
                return const UserTeamDash();
            }
          },
        );
      },
    );
  }
}
