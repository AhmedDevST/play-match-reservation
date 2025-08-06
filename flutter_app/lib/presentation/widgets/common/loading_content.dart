import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingContent extends StatelessWidget {
  final String lottieUrl;

  const LoadingContent({
    super.key,
    required this.lottieUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.network(lottieUrl),
    );
  }
}
