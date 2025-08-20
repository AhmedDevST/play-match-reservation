import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingContent extends StatelessWidget {
  final String? lottieUrl;
  final String message;

  const LoadingContent({
    super.key,
    this.lottieUrl,
    this.message = "Loading...", // default text
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          lottieUrl != null && lottieUrl!.isNotEmpty
              ? Lottie.network(
                  lottieUrl!,
                  errorBuilder: (context, error, stackTrace) =>
                      const CircularProgressIndicator(),
                )
              : const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
