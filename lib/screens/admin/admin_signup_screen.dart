import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smartmenu_app/l10n/app_localizations.dart';
import 'package:smartmenu_app/state/language_provider.dart';
import '../../core/design/admin_tokens.dart';
import 'create_restaurant_screen.dart';

class AdminSignupScreen extends StatefulWidget {
  const AdminSignupScreen({super.key});

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted || cred.user == null) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateRestaurantScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Log détaillé en debug seulement
      debugPrint('Signup error: ${e.code}');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.adminSignupErrorGeneric;
      });
    } catch (_) {
      setState(() => _errorMessage =
          AppLocalizations.of(context)!.adminSignupErrorUnknown);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                                const Text(
                                  'Langue / Language / שפה',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AdminTokens.neutral700,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space12),

                                Consumer<LanguageProvider>(
                                  builder: (context, languageProvider, _) {
                                    return SegmentedButton<Locale>(
                                      selected: {languageProvider.locale},
                                      onSelectionChanged:
                                          (Set<Locale> selection) async {
                                        await languageProvider
                                            .setLocale(selection.first);
                                        if (context.mounted) {
                                          setState(() {});
                                        }
                                      },
                                      segments: const [
                                        ButtonSegment(
                                          value: Locale('fr'),
                                          label: Text('🇫🇷 FR'),
                                        ),
                                        ButtonSegment(
                                          value: Locale('en'),
                                          label: Text('🇬🇧 EN'),
                                        ),
                                        ButtonSegment(
                                          value: Locale('he'),
                                          label: Text('🇮🇱 HE'),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: AdminTokens.space32),

                                Text(
                                  AppLocalizations.of(context)!
                                      .adminSignupTitle,
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

                                Text(
                                  AppLocalizations.of(context)!
                                      .adminSignupSubtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space32),

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
                                    labelText: AppLocalizations.of(context)!
                                        .adminSignupEmailLabel,
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
                                      ? AppLocalizations.of(context)!
                                          .adminSignupEmailRequired
                                      : null,
                                ),
                                const SizedBox(height: AdminTokens.space4),
                                Text(
                                  AppLocalizations.of(context)!
                                      .adminSignupPasswordHint,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AdminTokens.neutral500,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space16),

                                // Champ Mot de passe
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .adminSignupPasswordLabel,
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .adminSignupPasswordRequired;
                                    }
                                    if (v.length < 8) {
                                      return AppLocalizations.of(context)!
                                          .adminSignupPasswordTooShort;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AdminTokens.space16),

                                // Champ Confirmation mot de passe
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signup(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(context)!
                                        .adminSignupConfirmPasswordLabel,
                                    labelStyle: const TextStyle(
                                        color: AdminTokens.neutral600),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AdminTokens.neutral500,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AdminTokens.neutral500,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return AppLocalizations.of(context)!
                                          .adminSignupConfirmPasswordRequired;
                                    }
                                    if (v != _passwordController.text) {
                                      return AppLocalizations.of(context)!
                                          .adminSignupPasswordMismatch;
                                    }
                                    return null;
                                  },
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

                                // Bouton d'inscription
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signup,
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
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
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
                                              const SizedBox(
                                                  width: AdminTokens.space8),
                                              Text(
                                                AppLocalizations.of(context)!
                                                    .adminSignupButtonLoading,
                                                semanticsLabel: AppLocalizations
                                                        .of(context)!
                                                    .adminSignupButtonLoading,
                                              ),
                                            ],
                                          )
                                        : Text(AppLocalizations.of(context)!
                                            .adminSignupButton),
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space16),

                                // Lien retour connexion
                                Center(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AdminTokens.neutral600,
                                      textStyle: const TextStyle(fontSize: 14),
                                    ),
                                    child: Text(
                                      '${AppLocalizations.of(context)!.adminSignupAlreadyHaveAccount} ${AppLocalizations.of(context)!.adminSignupLoginLink}',
                                    ),
                                  ),
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
