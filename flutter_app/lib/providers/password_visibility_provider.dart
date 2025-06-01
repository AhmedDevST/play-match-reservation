import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pour gérer la visibilité des mots de passe
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);
final confirmPasswordVisibilityProvider = StateProvider<bool>((ref) => false);
