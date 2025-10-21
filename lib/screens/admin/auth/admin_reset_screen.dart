import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smartmenu_app/l10n/app_localizations.dart';
import 'package:smartmenu_app/state/language_provider.dart';
import '../../../core/design/admin_tokens.dart';

class AdminResetScreen extends StatefulWidget {
  const AdminResetScreen({super.key});

  @override
  State<AdminResetScreen> createState() => _AdminResetScreenState();
}

class _AdminResetScreenState extends State<AdminResetScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on FirebaseAuthException {
      // Message générique pour éviter l'énumération d'emails
      setState(() => _emailSent = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ✅ Page de confirmation d'email envoyé
    if (_emailSent) {
      return Scaffold(
        backgroundColor: AdminTokens.neutral50,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxCard =
                  (math.min(440.0, constraints.maxWidth - 32)).floorToDouble();

              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
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

                                // Icône email avec style
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AdminTokens.primary50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.email,
                                    size: 48,
                                    color: AdminTokens.primary600,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space24),

                                Text(
                                  l10n.adminResetEmailSentTitle,
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
                                  l10n.adminResetEmailSentMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space32),

                                // Bouton retour à la connexion
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
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
                                    child: Text(l10n.adminResetBackToLogin),
                                  ),
                                ),
                              ],
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

    // ✅ Page principale de réinitialisation
    return Scaffold(
      backgroundColor: AdminTokens.neutral50,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxCard =
                (math.min(440.0, constraints.maxWidth - 32)).floorToDouble();

            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
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

                                // Sélecteur de langue (comme signup/login)
                                Text(
                                  l10n.commonLanguage,
                                  style: const TextStyle(
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

                                // Icône lock_reset avec style
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AdminTokens.primary50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset,
                                    size: 48,
                                    color: AdminTokens.primary600,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space24),

                                Text(
                                  l10n.adminResetTitle,
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
                                  l10n.adminResetSubtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral600,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: AdminTokens.space32),

                                // Champ Email avec nouveau style
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textCapitalization: TextCapitalization.none,
                                  onFieldSubmitted: (_) => _resetPassword(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AdminTokens.neutral900,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: l10n.adminSettingsEmail,
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
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? l10n.adminSignupEmailRequired
                                          : null,
                                ),
                                const SizedBox(height: AdminTokens.space24),

                                // Bouton d'envoi avec loader
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _resetPassword,
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
                                              Text(l10n.adminResetSending),
                                            ],
                                          )
                                        : Text(l10n.adminResetButton),
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
                                    child: Text(l10n.adminResetBackToLogin),
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
