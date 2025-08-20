import 'package:flutter/material.dart';

class SportIconUtil {
  /// Returns the appropriate sport icon based on sport name
  static IconData getSportIcon(String sportName) {
    switch (sportName.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'handball':
        return Icons.sports_handball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_tennis; // Using tennis icon for badminton
      case 'golf':
        return Icons.sports_golf;
      case 'cricket':
        return Icons.sports_cricket;
      case 'rugby':
        return Icons.sports_rugby;
      case 'hockey':
        return Icons.sports_hockey;
      case 'baseball':
        return Icons.sports_baseball;
      case 'american football':
        return Icons.sports_football;
      case 'esports':
        return Icons.sports_esports;
      case 'martial arts':
      case 'karate':
      case 'judo':
        return Icons.sports_martial_arts;
      case 'motorsports':
        return Icons.sports_motorsports;
      default:
        return Icons.sports;
    }
  }

  /// Returns a map of all available sports with their icons
  static Map<String, IconData> getAllSportsIcons() {
    return {
      'football': Icons.sports_soccer,
      'soccer': Icons.sports_soccer,
      'basketball': Icons.sports_basketball,
      'volleyball': Icons.sports_volleyball,
      'handball': Icons.sports_handball,
      'tennis': Icons.sports_tennis,
      'badminton': Icons.sports_tennis,
      'golf': Icons.sports_golf,
      'cricket': Icons.sports_cricket,
      'rugby': Icons.sports_rugby,
      'hockey': Icons.sports_hockey,
      'baseball': Icons.sports_baseball,
      'american football': Icons.sports_football,
      'esports': Icons.sports_esports,
      'martial arts': Icons.sports_martial_arts,
      'karate': Icons.sports_martial_arts,
      'judo': Icons.sports_martial_arts,
      'motorsports': Icons.sports_motorsports,
    };
  }

}