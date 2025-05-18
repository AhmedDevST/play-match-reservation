import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/splash_screen.dart';
import 'package:flutter_app/theme/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Facility Booking',
      theme: ThemeData(
        primarySwatch: myBlue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: myBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: myBlue[50]!,
          selectedColor: myBlue[200]!,
          labelStyle: TextStyle(color: myBlue[900]),
          secondaryLabelStyle: TextStyle(color: myBlue[900]),
          brightness: Brightness.light,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: myBlue).copyWith(
          secondary: myBlue[200],
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
