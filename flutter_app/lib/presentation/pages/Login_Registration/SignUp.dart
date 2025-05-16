import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Démarrer l'animation après un court délai
    Future.delayed(const Duration(milliseconds: 100), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _fadeAnimation.value,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan avec animation
          _buildAnimatedBackground(),
          
          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête avec animations
                  _buildHeader(),
                  
                  const SizedBox(height: 30),
                  
                  // Formulaire avec animations
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Image de fond
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),
        
        // Effet de flou animé
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0 * _fadeAnimation.value,
                  sigmaY: 5.0 * _fadeAnimation.value,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.withOpacity(0.3 * _fadeAnimation.value),
                        const Color(0xFF1E88E5).withOpacity(0.6 * _fadeAnimation.value),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Éléments décoratifs animés
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value * 0.7,
              child: CustomPaint(
                painter: BubblesPainter(animation: _animationController),
                size: MediaQuery.of(context).size,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                ),
                
                const SizedBox(height: 20),
                
                // Titre
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Sous-titre
                const Text(
                  'Rejoignez notre communauté sportive !',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 - 20 * _fadeAnimation.value),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Champ nom complet
                    _buildAnimatedTextField(
                      controller: _nameController,
                      hintText: 'Nom complet',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                      delayFactor: 1,
                    ),
                    const SizedBox(height: 16),
                    
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
                      delayFactor: 2,
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ mot de passe
                    _buildAnimatedTextField(
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
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
                      delayFactor: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Champ confirmation mot de passe
                    _buildAnimatedTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirmer le mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                      delayFactor: 4,
                    ),
                    const SizedBox(height: 20),
                    
                    // Conditions d'utilisation
                    _buildDelayedAnimation(
                      child: Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: "J'accepte les "),
                                  TextSpan(
                                    text: "conditions d'utilisation",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " et la "),
                                  TextSpan(
                                    text: "politique de confidentialité",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      delayFactor: 5,
                    ),
                    const SizedBox(height: 30),
                    
                    // Bouton d'inscription
                    _buildDelayedAnimation(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate() && _acceptTerms) {
                            // TODO: Implémenter la logique d'inscription
                          } else if (!_acceptTerms) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez accepter les conditions d\'utilisation'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2EE59D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                          shadowColor: const Color(0xFF2EE59D).withOpacity(0.5),
                        ),
                        child: const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      delayFactor: 6,
                    ),
                    const SizedBox(height: 20),
                    
                    // Lien vers la page de connexion
                    _buildDelayedAnimation(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Déjà un compte ?',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Retourner à la page de connexion
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      delayFactor: 7,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        validator: validator,
      ),
      delayFactor: delayFactor,
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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: AnimatedPadding(
            padding: const EdgeInsets.all(0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          ),
        );
      },
    );
  }
}

// Classe pour dessiner des bulles animées en arrière-plan
class BubblesPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Bubble> bubbles = [];

  BubblesPainter({required this.animation}) : super(repaint: animation) {
    // Générer des bulles aléatoires
    for (int i = 0; i < 20; i++) {
      bubbles.add(Bubble.random());
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final offset = Offset(
        size.width * bubble.position.dx,
        size.height * (bubble.position.dy + (0.2 * animation.value * bubble.speed)),
      );
      
      // Effet d'apparition/disparition
      final opacity = (math.sin(animation.value * math.pi * 2 * bubble.speed + bubble.offset) + 1) / 2;
      
      final paint = Paint()
        ..color = bubble.color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(offset, bubble.size * size.width * 0.05, paint);
    }
  }

  @override
  bool shouldRepaint(BubblesPainter oldDelegate) => true;
}

class Bubble {
  final Offset position;
  final double size;
  final Color color;
  final double speed;
  final double offset;

  Bubble({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.offset,
  });

  factory Bubble.random() {
    final random = math.Random();
    
    List<Color> colors = [
      Colors.white,
      Colors.blue.shade300,
      Colors.lightBlue.shade200,
      Colors.blue.shade100,
    ];
    
    return Bubble(
      position: Offset(random.nextDouble(), random.nextDouble()),
      size: 0.2 + random.nextDouble() * 0.8,
      color: colors[random.nextInt(colors.length)],
      speed: 0.1 + random.nextDouble() * 0.4,
      offset: random.nextDouble() * math.pi * 2,
    );
  }
} 