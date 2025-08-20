import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final String? lottieUrl; // Optional Lottie animation

  const EmptyStateWidget({
    Key? key,
    this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.lottieUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget animatedOrIcon = lottieUrl != null
        ? SizedBox(
            height: 100,
            child: Lottie.network(lottieUrl!),
          )
        : CircleAvatar(
            radius: 30,
            backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
            child: Icon(
              icon ?? Icons.info,
              color: iconColor ?? Colors.white,
              size: 30,
            ),
          );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          animatedOrIcon,
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: titleColor ?? Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: subtitleColor ?? Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
