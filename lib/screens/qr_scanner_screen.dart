// lib/screens/qr_scanner_screen.dart - Version corrigée
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/qr_service.dart';
import 'menu/resolve_restaurant_screen.dart';
import '../core/constants/colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with TickerProviderStateMixin {
  late MobileScannerController cameraController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  bool _isProcessing = false;
  String? _error;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();

    // Animation de scanning
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner camera
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
            errorBuilder: (context, error, child) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Caméra non disponible',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.errorDetails?.message ?? 'Erreur inconnue',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Overlay avec cadre de scan
          CustomPaint(
            painter: _ScanOverlayPainter(_animation.value),
            child: Container(),
          ),

          // Top bar avec contrôles
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildTopControls(),
          ),

          // Bottom instructions
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 24,
            right: 24,
            child: _buildInstructions(),
          ),

          // Message d'erreur
          if (_error != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 160,
              left: 24,
              right: 24,
              child: _buildErrorMessage(),
            ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Vérification...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ CORRECTION PRINCIPALE : Gestion URLs web modernes
  void _handleQRCode(String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // 1) Vérifier si c'est une URL SmartMenu valide
      if (QRService.isValidSmartMenuQR(qrData)) {
        final slug = QRService.extractSlugFromUrl(qrData);
        if (slug != null) {
          // Arrêter le scanner
          await cameraController.stop();

          // Délai pour UX (éviter flash trop rapide)
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // ✅ UTILISER ResolveRestaurantScreen pour gérer slug→rid
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResolveRestaurantScreen(idOrSlug: slug),
              ),
            );
          }
          return;
        }
      }

      // 2) Fallback : anciens QR codes "smartmenu://restaurant/"
      if (qrData.startsWith('smartmenu://restaurant/')) {
        final restaurantId = qrData.split('/').last;
        if (restaurantId.isNotEmpty) {
          await cameraController.stop();
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ResolveRestaurantScreen(idOrSlug: restaurantId),
              ),
            );
          }
          return;
        }
      }

      // 3) QR non reconnu
      setState(() {
        _error = 'QR code non reconnu. Scannez un code SmartMenu valide.';
        _isProcessing = false;
      });

      // Clear l'erreur après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _error = null);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du scan : $e';
        _isProcessing = false;
      });
    }
  }

  void _toggleFlash() async {
    try {
      await cameraController.toggleTorch();
      setState(() {
        _flashEnabled = !_flashEnabled;
      });
    } catch (e) {
      // Ignore les erreurs de flash (pas supporté sur tous les devices)
    }
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            onPressed: () {
              cameraController.stop();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
          ),

          const Expanded(
            child: Text(
              'Scanner le QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Bouton flash
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _flashEnabled ? Icons.flash_on : Icons.flash_off,
              color: _flashEnabled ? AppColors.primary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.qr_code_scanner,
            color: AppColors.primary,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            'Pointez la caméra vers le QR code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Il doit être visible dans le cadre',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }
}

/// Painter pour l'overlay de scan avec animation
class _ScanOverlayPainter extends CustomPainter {
  final double animationValue;

  _ScanOverlayPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Dimensions du cadre de scan
    const frameSize = 250.0;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSize,
      height: frameSize,
    );

    // Dessiner l'overlay sombre avec trou transparent
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Dessiner les coins du cadre
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Coin top-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top + cornerLength),
      Offset(frameRect.left, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLength, frameRect.top),
      cornerPaint,
    );

    // Coin top-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.top),
      Offset(frameRect.right, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLength),
      cornerPaint,
    );

    // Coin bottom-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      Offset(frameRect.left, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      cornerPaint,
    );

    // Coin bottom-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      cornerPaint,
    );

    // Ligne de scan animée
    final scanLinePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scanY = frameRect.top + (frameRect.height * animationValue);
    canvas.drawLine(
      Offset(frameRect.left + 20, scanY),
      Offset(frameRect.right - 20, scanY),
      scanLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
