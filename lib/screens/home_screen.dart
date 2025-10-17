import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? errorMessage;

  const HomeScreen({super.key, this.errorMessage});

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

  @override
  void initState() {
    super.initState();
    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _errorMessage = widget.errorMessage;
        });
        _codeFocus.requestFocus();
      });
    }
  }

  bool get _isScannerSupported {
    if (!kIsWeb) return true;

    // Desktop HTTPS uniquement
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) return false;

    final uri = Uri.base;
    return uri.scheme == 'https' || uri.host == 'localhost';
  }

  Future<void> _accessRestaurant() async {
    final raw = _codeController.text.trim();
    final code = raw.toLowerCase();

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

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

    if (!RegExp(r'^[a-z0-9-]{3,32}$').hasMatch(code)) {
      setState(() {
        _errorMessage =
            'Code invalide (lettres, chiffres et tirets uniquement)';
        _isLoading = false;
      });
      _codeFocus.requestFocus();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    _codeFocus.unfocus();
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed('/r/$code');
  }

  void _openScanner() {
    if (!_isScannerSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanner non disponible - Utilisez HTTPS ou localhost'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isSmallMobile = screenHeight < 700; // iPhone SE, etc.

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculer l'espace disponible
            final availableHeight = constraints.maxHeight;
            final contentPadding = isMobile ? 20.0 : 32.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: contentPadding,
                    vertical: isSmallMobile ? 16 : 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header compact - moins d'espace
                      SizedBox(height: isSmallMobile ? 20 : 40),
                      _buildCompactHeader(isMobile, isSmallMobile),

                      // Espace réduit entre header et contenu
                      SizedBox(height: isSmallMobile ? 32 : 48),

                      // Contenu principal en colonnes sur desktop
                      if (!isMobile)
                        _buildDesktopLayout()
                      else
                        _buildMobileLayout(isSmallMobile),

                      // Spacer flexible pour pousser le footer
                      SizedBox(height: isSmallMobile ? 20 : 32),

                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactHeader(bool isMobile, bool isSmallMobile) {
    final logoSize = isSmallMobile ? 60.0 : (isMobile ? 70.0 : 80.0);

    return Column(
      children: [
        // Logo compact
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withAlpha((255 * 0.25).round()),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: logoSize * 0.5,
          ),
        ),

        SizedBox(height: isSmallMobile ? 16 : 20),

        // Titre
        Text(
          'SmartMenu',
          style: TextStyle(
            fontSize: isSmallMobile ? 28 : (isMobile ? 30 : 32),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: isSmallMobile ? 8 : 12),

        // Sous-titre
        Text(
          'Accédez au menu de votre restaurant',
          style: TextStyle(
            fontSize: isSmallMobile ? 16 : 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne gauche : Code restaurant
        Expanded(
          flex: 1,
          child: _buildCodeSection(false),
        ),

        const SizedBox(width: 32),

        // Colonne droite : Scanner
        Expanded(
          flex: 1,
          child: _isScannerSupported
              ? _buildScannerSection(false)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isSmallMobile) {
    return Column(
      children: [
        // Code restaurant en premier (action principale)
        _buildCodeSection(true, isSmallMobile),

        SizedBox(height: isSmallMobile ? 20 : 24),

        // Scanner en second
        if (_isScannerSupported) _buildScannerSection(true, isSmallMobile),
      ],
    );
  }

  Widget _buildCodeSection(bool isMobile, [bool isSmallMobile = false]) {
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 24 : (isMobile ? 28 : 32)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.06).round()),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Code restaurant',
            style: TextStyle(
              fontSize: isSmallMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),

          SizedBox(height: isSmallMobile ? 6 : 8),

          Text(
            'Saisissez le code fourni par votre restaurant',
            style: TextStyle(
              fontSize: isSmallMobile ? 13 : 14,
              color: Colors.grey[600],
            ),
          ),

          SizedBox(height: isSmallMobile ? 20 : 24),

          // Champ de saisie
          TextField(
            controller: _codeController,
            focusNode: _codeFocus,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            textInputAction: TextInputAction.go,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Exemple: pizza-mario',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(
                Icons.store_outlined,
                color: Color(0xFF6366F1),
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorText: _errorMessage,
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
            ),
            onSubmitted: (_) => _accessRestaurant(),
          ),

          SizedBox(height: isSmallMobile ? 20 : 24),

          // Bouton d'accès
          SizedBox(
            height: isSmallMobile ? 52 : 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _accessRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor:
                    const Color(0xFF6366F1).withAlpha((255 * 0.3).round()),
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
                  : Text(
                      'Accéder au menu',
                      style: TextStyle(
                        fontSize: isSmallMobile ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerSection(bool isMobile, [bool isSmallMobile = false]) {
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 20 : (isMobile ? 24 : 28)),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: isSmallMobile ? 40 : 48,
            color: const Color(0xFF6366F1),
          ),
          SizedBox(height: isSmallMobile ? 12 : 16),
          Text(
            'Scanner QR Code',
            style: TextStyle(
              fontSize: isSmallMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: isSmallMobile ? 6 : 8),
          Text(
            'Scannez le QR code sur votre table',
            style: TextStyle(
              fontSize: isSmallMobile ? 13 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isSmallMobile ? 16 : 20),
          SizedBox(
            width: double.infinity,
            height: isSmallMobile ? 44 : 48,
            child: OutlinedButton.icon(
              onPressed: _openScanner,
              icon: const Icon(
                Icons.camera_alt_outlined,
              ),
              label: const Text('Ouvrir la caméra'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
          fontSize: 11,
          color: Colors.grey[400],
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
