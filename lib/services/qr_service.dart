// lib/services/qr_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service centralisé pour génération et gestion des QR codes
/// Pattern statique + injection pour tests, cohérent avec CategoryManager
class QRService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  // Injection pour tests
  static void setFirestoreInstance(FirebaseFirestore instance) {
    _db = instance;
  }

  /// Génère l'URL publique complète pour un restaurant
  static String generateRestaurantUrl(String slug) {
    return 'https://smartmenu-mvp.web.app/r/$slug';
  }

  /// Récupère le slug d'un restaurant pour générer son QR
  static Future<String> getRestaurantSlug(String restaurantId) async {
    try {
      final doc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (!doc.exists) {
        throw Exception('Restaurant introuvable');
      }

      final data = doc.data()!;

      // Priorité : slug > code > restaurantId (fallback)
      return data['slug'] ?? data['code'] ?? restaurantId;
    } catch (e) {
      debugPrint('Erreur récupération slug: $e');
      // Fallback sur l'ID si problème réseau
      return restaurantId;
    }
  }

  /// Sauvegarde les paramètres QR dans Firestore
  static Future<void> saveQRConfig(
    String restaurantId, {
    String? customMessage,
    bool showLogo = true,
    String size = 'medium',
  }) async {
    try {
      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('info')
          .doc('qr_config')
          .set({
        'customMessage': customMessage,
        'showLogo': showLogo,
        'size': size,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erreur sauvegarde config QR: $e');
      rethrow;
    }
  }

  /// Récupère la configuration QR
  static Future<QRConfig> getQRConfig(String restaurantId) async {
    try {
      final doc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('info')
          .doc('qr_config')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return QRConfig(
          customMessage: data['customMessage'],
          showLogo: data['showLogo'] ?? true,
          size: data['size'] ?? 'medium',
        );
      }

      // Configuration par défaut
      return const QRConfig();
    } catch (e) {
      debugPrint('Erreur récupération config QR: $e');
      return const QRConfig();
    }
  }

  /// Valide qu'une URL scannée est un QR SmartMenu valide
  static bool isValidSmartMenuQR(String url) {
    try {
      final uri = Uri.parse(url);

      // Vérifier le format /r/{slug}
      if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'r') {
        final slug = uri.pathSegments[1];

        // Validation basique du slug
        return RegExp(r'^[a-z0-9-]{3,32}$').hasMatch(slug);
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Extrait le slug depuis une URL scannée
  static String? extractSlugFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'r') {
        return uri.pathSegments[1];
      }
    } catch (e) {
      debugPrint('Erreur extraction slug: $e');
    }
    return null;
  }
}

/// Configuration pour la génération de QR codes
class QRConfig {
  final String? customMessage;
  final bool showLogo;
  final String size;

  const QRConfig({
    this.customMessage,
    this.showLogo = true,
    this.size = 'medium',
  });

  QRConfig copyWith({
    String? customMessage,
    bool? showLogo,
    String? size,
  }) {
    return QRConfig(
      customMessage: customMessage ?? this.customMessage,
      showLogo: showLogo ?? this.showLogo,
      size: size ?? this.size,
    );
  }
}

/// Tailles de QR disponibles
enum QRSize {
  small(200, 'small', 'Petit (200px)'),
  medium(300, 'medium', 'Moyen (300px)'),
  large(400, 'large', 'Grand (400px)'),
  xlarge(600, 'xlarge', 'Très grand (600px)');

  const QRSize(this.pixels, this.key, this.label);
  final int pixels;
  final String key;
  final String label;

  static QRSize fromKey(String key) {
    return values.firstWhere(
      (size) => size.key == key,
      orElse: () => medium,
    );
  }
}
