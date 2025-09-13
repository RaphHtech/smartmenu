import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  bool get _isScannerSupported {
    // Scanner disponible uniquement sur HTTPS/localhost avec support caméra
    if (kIsWeb) {
      final uri = Uri.base;
      final isSecure = uri.scheme == 'https' ||
          uri.host == 'localhost' ||
          uri.host == '127.0.0.1';
      return isSecure;
    }
    return true; // Mobile toujours supporté
  }

  Future<void> _accessRestaurant() async {
    final raw = _codeController.text.trim();
    final code = raw.toLowerCase();

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validation
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir un code restaurant';
        _isLoading = false;
      });
      _codeFocus.requestFocus();
      return;
    }

    if (code.length < 3) {
      setState(() {
        _errorMessage = 'Le code doit contenir au moins 3 caractères';
        _isLoading = false;
      });
      _codeFocus.requestFocus();
      return;
    }

    // Validation format simple (lettres, chiffres, tirets)
    if (!RegExp(r'^[a-z0-9-]{3,32}$').hasMatch(code)) {
      setState(() {
        _errorMessage =
            'Code invalide (lettres, chiffres et tirets uniquement)';
        _isLoading = false;
      });
      _codeFocus.requestFocus();
      return;
    }

    // Simulation délai réseau
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Unfocus clavier
    _codeFocus.unfocus();

    setState(() => _isLoading = false);

    // Navigation vers le menu restaurant
    Navigator.of(context).pushReplacementNamed('/r/$code');
  }

  void _openScanner() {
    // TODO: Implémenter scanner QR (Étape 5.2)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scanner QR - Fonctionnalité en développement'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Header logo + titre
              _buildHeader(),

              const SizedBox(height: 80),

              // Section principale : Code restaurant
              _buildCodeSection(),

              const SizedBox(height: 40),

              // Section scanner (conditionnel)
              if (_isScannerSupported) _buildScannerSection(),

              const SizedBox(height: 60),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        // Titre principal
        const Text(
          'SmartMenu',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        // Sous-titre
        Text(
          'Accédez au menu de votre restaurant',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCodeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Code restaurant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Saisissez le code fourni par votre restaurant',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Champ de saisie
          TextField(
            controller: _codeController,
            focusNode: _codeFocus,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              hintText: 'Exemple: newtest',
              prefixIcon: const Icon(Icons.store_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFEF4444), width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFEF4444), width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _accessRestaurant(),
          ),

          const SizedBox(height: 24),

          // Bouton d'accès
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _accessRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Accéder au menu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 48,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scanner QR Code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez le QR code sur votre table (Beta)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _openScanner,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Ouvrir la caméra'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'SmartMenu - Solution digitale pour restaurants',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}
