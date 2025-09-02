import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/colors.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Redirection vers dashboard (pour l'instant placeholder)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie!')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Format email invalide';
      default:
        return 'Erreur de connexion';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Titre
                const Text(
                  'SmartMenu',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dashboard Restaurateur',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: AppColors.accent),
                    labelStyle: TextStyle(color: AppColors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email requis';
                    if (!value!.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock, color: AppColors.accent),
                    labelStyle: TextStyle(color: AppColors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Mot de passe requis';
                    if (value!.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Erreur
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Bouton connexion
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.primary)
                        : const Text('SE CONNECTER'),
                  ),
                ),
                const SizedBox(height: 20),

                // Lien inscription
                TextButton(
                  onPressed: () {
                    // Pour l'instant, message placeholder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Inscription à venir')),
                    );
                  },
                  child: const Text(
                    'Créer un compte restaurant',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
