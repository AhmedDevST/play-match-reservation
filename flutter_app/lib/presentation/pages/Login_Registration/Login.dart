import 'package:flutter_app/presentation/pages/Login_Registration/SignUp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

final rememberMeProvider = StateProvider<bool>((ref) => false);
final passwordVisibilityProvider = StateProvider<bool>((ref) => false);

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override 
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Démarrer l'animation après un court délai
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final rememberMe = ref.read(rememberMeProvider);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'remember': rememberMe,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        final token = data['token'];
        
        // Créer un objet User à partir des données
        final user = User.fromJson(userData);

        // Mettre à jour l'état d'authentification
        await ref.read(authProvider.notifier).login(
          user: user,
          accessToken: token,
        );

     
        // Stocker le token dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        // Navigate to the next page or show success message
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle error response
        final error = jsonDecode(response.body)['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Effet de flou
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo ou icône
                          Container(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 120,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Titre
                          const Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Formulaire
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Champ email
                                _buildAnimatedTextField(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Veuillez entrer un email valide';
                                    }
                                    return null;
                                  },
                                  delayFactor: 1,
                                ),
                                const SizedBox(height: 20),

                                // Champ mot de passe
                                _buildPasswordField(
                                  controller: _passwordController,
                                  hintText: 'Mot de passe',
                                  delayFactor: 2,
                                ),
                                const SizedBox(height: 12),

                                // Options de connexion
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Option Se souvenir de moi
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final rememberMe = ref.watch(rememberMeProvider);
                                        return Row(
                                          children: [
                                            SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Checkbox(
                                                value: rememberMe,
                                                onChanged: (value) {
                                                  ref.read(rememberMeProvider.notifier).state = value!;
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Se souvenir de moi',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    // Mot de passe oublié
                                    _buildDelayedAnimation(
                                      child: TextButton(
                                        onPressed: () {
                                          // TODO: Navigation vers la page de récupération de mot de passe
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(10, 10),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Mot de passe oublié ?',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      delayFactor: 3,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Bouton de connexion
                                _buildDelayedAnimation(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await _handleLogin();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2EE59D),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 3,
                                      shadowColor: const Color(0xFF2EE59D)
                                          .withOpacity(0.5),
                                    ),
                                    child: const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  delayFactor: 4,
                                ),
                                const SizedBox(height: 24),

                                // Option d'inscription
                                _buildDelayedAnimation(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Vous n'avez pas de compte ?",
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Navigation vers la page d'inscription

                                          // Navigation vers la page d'accueil après validation du formulaire
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()));
                                        },
                                        child: const Text(
                                          "S'inscrire",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  delayFactor: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bouton de retour
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.7),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    required int delayFactor,
  }) {
    return _buildDelayedAnimation(
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        validator: validator,
      ),
      delayFactor: delayFactor,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required int delayFactor,
  }) {
    final isPasswordVisibleNotifier = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isPasswordVisibleNotifier,
      builder: (context, isPasswordVisible, child) {
        return TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                isPasswordVisibleNotifier.value = !isPasswordVisible;
              },
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (value.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildDelayedAnimation({
    required Widget child,
    required int delayFactor,
  }) {
    // Créer une animation décalée basée sur le facteur de délai
    final delay = Duration(milliseconds: 150 * delayFactor);

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        // Si le délai n'est pas terminé, afficher un conteneur vide avec la même taille
        if (snapshot.connectionState != ConnectionState.done) {
          return Opacity(
            opacity: 0,
            child: child,
          );
        }

        // Sinon, afficher l'élément avec une animation
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child,
        );
      },
    );
  }
}

class PasswordVisibilityIcon extends StatelessWidget {
  final ValueNotifier<bool> isPasswordVisibleNotifier;

  const PasswordVisibilityIcon({
    super.key,
    required this.isPasswordVisibleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPasswordVisibleNotifier,
      builder: (context, isPasswordVisible, child) {
        return IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            isPasswordVisibleNotifier.value = !isPasswordVisible;
          },
        );
      },
    );
  }
}
