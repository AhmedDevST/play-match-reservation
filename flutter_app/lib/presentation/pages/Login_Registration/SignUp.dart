import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/pages/Login_Registration/Login.dart';
import 'package:flutter_app/presentation/pages/home/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'package:lottie/lottie.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _picker = ImagePicker();
  
  // Utiliser ValueNotifier pour éviter le rebuild complet
  final ValueNotifier<String?> _selectedImageNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _base64ImageNotifier = ValueNotifier<String?>(null);

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

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
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
    _selectedImageNotifier.dispose();
    _base64ImageNotifier.dispose();
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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildForm(),
                  ),
                ),
              ),
            ),
          ),

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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (image != null) {
        // Lire l'image en bytes
        final bytes = await image.readAsBytes();
        // Convertir en base64
        final base64Image = base64Encode(bytes);
        // Ajouter le préfixe data:image
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final imageString = 'data:$mimeType;base64,$base64Image';

        // Utiliser ValueNotifier au lieu de setState
        _selectedImageNotifier.value = image.path;
        _base64ImageNotifier.value = imageString;
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network(
                  'https://lottie.host/de911dfc-703a-4131-ae9a-ec69a5e06fbc/obAB83LlN9.json',
                  repeat: false,
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Inscription réussie !',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'username': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'profile_picture': _base64ImageNotifier.value ?? '',
      }),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${data['message']}')),
      );
    }
  }

  Widget _buildForm() {
    return Container(
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
            // Image de profil avec ValueListenableBuilder
            _buildDelayedAnimation(
              child: Center(
                child: _buildProfileImagePicker(),
              ),
              delayFactor: 1,
            ),
            const SizedBox(height: 24),
            
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
              delayFactor: 2,
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
              delayFactor: 3,
            ),
            const SizedBox(height: 16),
            
            // Champ mot de passe
            _buildPasswordField(
              controller: _passwordController,
              hintText: 'Mot de passe',
              delayFactor: 4,
            ),
            const SizedBox(height: 16),
            
            // Champ confirmation mot de passe
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: 'Confirmer le mot de passe',
              delayFactor: 5,
            ),
            const SizedBox(height: 30),
            
            // Bouton d'inscription
            _buildDelayedAnimation(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _signUp();
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
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
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
    );
  }

  // Widget séparé pour l'image de profil
  Widget _buildProfileImagePicker() {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedImageNotifier,
      builder: (context, selectedImage, child) {
        return Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: selectedImage != null 
                ? (kIsWeb 
                    ? NetworkImage(selectedImage) 
                    : FileImage(File(selectedImage))) as ImageProvider
                : null,
              child: selectedImage == null 
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade400,
                  )
                : null,
            ),
            Positioned(
              bottom: -10,
              right: -10,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required int delayFactor,
  }) {
    final isPasswordVisibleNotifier = ValueNotifier<bool>(false);

    return _buildDelayedAnimation(
      child: ValueListenableBuilder<bool>(
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
              if (controller == _confirmPasswordController) {
                if (value != _passwordController.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
              }
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
      ),
      delayFactor: delayFactor,
    );
  }

  Widget _buildDelayedAnimation({
    required Widget child,
    required int delayFactor,
  }) {
    final delay = Duration(milliseconds: 150 * delayFactor);
    
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Opacity(
            opacity: 0,
            child: child,
          );
        }
        
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