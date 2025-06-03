import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_app/core/config/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacementNamed(context, Routes.landing);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width , // 70% de la largeur de l'écran
          height: MediaQuery.of(context).size.width , // Garde un ratio carré
          //https://lottie.host/embed/d938741d-8754-44f1-91cf-80fee5ddd587/SaOX2SpGTv.json
          child: Lottie.network(
            'https://lottie.host/d938741d-8754-44f1-91cf-80fee5ddd587/SaOX2SpGTv.json',
            controller: _controller,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _controller.forward();
            },
          ),
        ),
      ),
    );
  }
}
