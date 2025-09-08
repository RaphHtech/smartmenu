// lib/core/design/admin_typography.dart
import 'package:flutter/material.dart';
import 'admin_tokens.dart';

/// Système typographique premium pour l'interface Admin
/// Police système optimisée (San Francisco/Segoe UI/Roboto)
class AdminTypography {
  // ===== TITRES =====

  /// Titre principal de page (ex: "Gestion du menu")
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.5,
    height: 1.2,
    color: AdminTokens.neutral900,
  );

  /// Titre de section (ex: "Plats du menu")
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semibold
    letterSpacing: -0.25,
    height: 1.3,
    color: AdminTokens.neutral800,
  );

  /// Sous-titre (ex: "4 plats au menu")
  static const TextStyle displaySmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AdminTokens.neutral700,
  );

  // ===== HEADINGS =====

  /// Titre de carte/composant
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AdminTokens.neutral800,
  );

  /// Titre de liste item
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.5,
    color: AdminTokens.neutral800,
  );

  /// Titre de formulaire/label
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AdminTokens.neutral700,
  );

  // ===== BODY TEXT =====

  /// Texte principal
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    letterSpacing: 0,
    height: 1.5,
    color: AdminTokens.neutral600,
  );

  /// Texte standard
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
    color: AdminTokens.neutral600,
  );

  /// Texte petit/secondaire
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
    color: AdminTokens.neutral500,
  );

  // ===== LABELS & CAPTIONS =====

  /// Labels de formulaire
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 0,
    height: 1.4,
    color: AdminTokens.neutral700,
  );

  /// Labels de boutons
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: AdminTokens.neutral700,
  );

  /// Captions, hints, metadata
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.3,
    color: AdminTokens.neutral500,
  );

  // ===== VARIANTS SÉMANTIQUES =====

  /// Prix, valeurs importantes
  static TextStyle get priceLarge => bodyLarge.copyWith(
        fontWeight: FontWeight.w700,
        color: AdminTokens.primary600,
      );

  static TextStyle get priceMedium => bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AdminTokens.primary600,
      );

  /// Status/badges
  static TextStyle get badgeText => labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  /// Actions destructives
  static TextStyle get destructive => bodyMedium.copyWith(
        color: AdminTokens.error500,
        fontWeight: FontWeight.w500,
      );

  /// Liens/actions
  static TextStyle get link => bodyMedium.copyWith(
        color: AdminTokens.primary600,
        fontWeight: FontWeight.w500,
      );

  /// Succès
  static TextStyle get success => bodyMedium.copyWith(
        color: AdminTokens.success500,
        fontWeight: FontWeight.w500,
      );

  /// Placeholders
  static TextStyle get placeholder => bodyMedium.copyWith(
        color: AdminTokens.neutral400,
        fontStyle: FontStyle.italic,
      );

  // ===== HELPER METHODS =====

  /// Applique une couleur custom à n'importe quel style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Applique un poids custom
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Applique une taille custom
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
