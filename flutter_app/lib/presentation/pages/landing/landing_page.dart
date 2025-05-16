import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/login_registration/Login.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

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
          // Superposition de gradient avec opacité réduite
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1E88E5).withAlpha(217),  // Bleu plus clair avec opacité 0.85
                    const Color(0xFF1565C0).withAlpha(217),  // Bleu plus foncé avec opacité 0.85
                  ],
                ),
              ),
            ),
          ),
          // Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',  // À remplacer par votre logo
                    height: 150,
                  ),
                  
                  const SizedBox(height: 40), //espace entre le logo et le texte de bienvenue
                  
                  // Texte de bienvenue
                  const Text(
                    'Bienvenue dans votre\nespace sportif',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sous-titre
                  const Text(
                    'Réservez facilement vos terrains de foot, basket et handball selon vos disponibilités',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cambria',
                     
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Bouton Créer un compte
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                      // TODO: Navigation vers la page d'inscription
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EE59D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Bouton Se connecter
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/home');
                      // TODO: Navigation vers la page de connexion
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Section "Ou continuer avec"
                  const Text(
                    'Ou continuer avec',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Boutons de connexion sociale
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        icon: 'assets/icons/apple.png',
                        onPressed: () {
                          // TODO: Implémentation connexion Apple
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: 'assets/icons/google.png',
                        onPressed: () {
                          // TODO: Implémentation connexion Google
                        },
                      ),
                      const SizedBox(width: 16),
                      _SocialButton(
                        icon: 'assets/icons/facebook.png',
                        onPressed: () {
                          // TODO: Implémentation connexion Facebook
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Image.asset(icon),
        onPressed: onPressed,
      ),
    );
  }
} 