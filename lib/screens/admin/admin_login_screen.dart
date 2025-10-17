import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/screens/admin/admin_dashboard_overview_screen.dart';
import 'package:smartmenu_app/screens/admin/auth/admin_reset_screen.dart';

import '../../core/design/admin_tokens.dart';
import 'admin_signup_screen.dart';
import 'create_restaurant_screen.dart';
import '../../widgets/ui/admin_themed.dart';

class AdminLoginScreen extends StatefulWidget {
  final String? returnUrl;
  const AdminLoginScreen({super.key, this.returnUrl});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = cred.user;
      if (user != null && mounted) {
        // Stocker le context avant les opérations async
        final navigator = Navigator.of(context);

        // Trouver le restaurant où l'uid est membre
        // Lecture directe du mapping user (O(1), pas d'index)
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Vérifier mounted avant d'utiliser Navigator
        if (!mounted) return;

        if (userDoc.exists &&
            userDoc.data()?['primary_restaurant_id'] != null) {
          final restaurantId =
              userDoc.data()!['primary_restaurant_id'] as String;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => AdminThemed(
                child: AdminDashboardOverviewScreen(restaurantId: restaurantId),
              ),
            ),
            (route) => false,
          );
        } else {
          // Cas où l'utilisateur n'a pas encore de restaurant
          navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => const CreateRestaurantScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageFromCode(e.code));
    } catch (_) {
      setState(() => _errorMessage = 'Une erreur est survenue. Réessayez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _messageFromCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Email ou mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      default:
        return 'Erreur de connexion.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTokens.neutral50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcul largeur carte pixel-perfect
            final maxCard =
                (math.min(440.0, constraints.maxWidth - 32)).floorToDouble();

            return Align(
              alignment: Alignment.topCenter, // Pas Center
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.viewInsetsOf(context).bottom, // Clavier mobile
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight, // Force remplissage viewport
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: maxCard),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AdminTokens.radius16),
                            boxShadow: const [AdminTokens.cardShadow],
                          ),
                          child: Form(
                            key: _formKey,
                            // ... le reste de votre Form reste identique
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo et titre
                                Image.asset(
                                  'assets/images/logo.png',
                                  width: 80,
                                  height: 80,
                                ),
                                const SizedBox(height: AdminTokens.space24),

                                Text(
                                  'Connexion restaurateur',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 400
                                            ? 24
                                            : 28,
                                    fontWeight: FontWeight.w700,
                                    color: AdminTokens.neutral900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space8),

                                const Text(
                                  'Accédez à votre tableau de bord',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral600,
                                    height: 1.4,
                                  ),
                                ),

                                // Champ Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization: TextCapitalization.none,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(
                                        color: AdminTokens.neutral600),
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AdminTokens.neutral500,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AdminTokens.radius8),
                                      borderSide: const BorderSide(
                                          color: AdminTokens.neutral300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AdminTokens.radius8),
                                      borderSide: const BorderSide(
                                        color: AdminTokens.primary600,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AdminTokens.space16,
                                      vertical: AdminTokens.space12,
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Veuillez saisir votre email'
                                      : null,
                                ),
                                const SizedBox(height: AdminTokens.space16),

                                // Champ Mot de passe avec show/hide
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    labelStyle: const TextStyle(
                                        color: AdminTokens.neutral600),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AdminTokens.neutral500,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AdminTokens.neutral500,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AdminTokens.radius8),
                                      borderSide: const BorderSide(
                                          color: AdminTokens.neutral300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AdminTokens.radius8),
                                      borderSide: const BorderSide(
                                        color: AdminTokens.primary600,
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AdminTokens.space16,
                                      vertical: AdminTokens.space12,
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Veuillez saisir votre mot de passe'
                                      : null,
                                ),
                                const SizedBox(height: AdminTokens.space24),

                                // Message d'erreur
                                if (_errorMessage != null)
                                  Container(
                                    padding: const EdgeInsets.all(
                                        AdminTokens.space12),
                                    margin: const EdgeInsets.only(
                                        bottom: AdminTokens.space16),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      border: Border.all(
                                          color: Colors.red.shade200),
                                      borderRadius: BorderRadius.circular(
                                          AdminTokens.radius8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade600,
                                          size: 20,
                                        ),
                                        const SizedBox(
                                            width: AdminTokens.space8),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Bouton de connexion avec accessibilité
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AdminTokens.primary600,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AdminTokens.radius8),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: AdminTokens.space8),
                                              Text(
                                                'Connexion en cours...',
                                                semanticsLabel:
                                                    'Connexion en cours',
                                              ),
                                            ],
                                          )
                                        : const Text('Se connecter'),
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space16),

                                // Liens de navigation
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminResetScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AdminTokens.neutral600,
                                        textStyle:
                                            const TextStyle(fontSize: 14),
                                      ),
                                      child:
                                          const Text('Mot de passe oublié ?'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AdminSignupScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: AdminTokens.primary600,
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Text('Créer un compte'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
