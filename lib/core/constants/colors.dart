import 'package:flutter/material.dart';

/// Palette de couleurs SmartMenu - Design System v2
/// Philosophie : Flat Design, couleurs unies, contraste optimal
/// Cible : Restaurants de quartier - Simple, chaleureux, accessible

class AppColors {
  // ═══════════════════════════════════════════════════════════
  // COULEURS PRINCIPALES
  // ═══════════════════════════════════════════════════════════

  /// Rouge tomate - Couleur primaire (boutons, accents)
  static const Color primary = Color(0xFFE8573E);
  static const Color primaryDark = Color(0xFFD14532);
  static const Color primaryLight = Color(0xFFFF6B54);

  /// Bleu ardoise - Couleur secondaire (header, éléments structurels)
  static const Color secondary = Color(0xFF2C3E50);
  static const Color secondaryLight = Color(0xFF34495E);

  /// Orange miel - Accent chaleureux (badges, highlights)
  static const Color accent = Color(0xFFF39C12);
  static const Color accentLight = Color(0xFFF8B849);

  // ═══════════════════════════════════════════════════════════
  // SURFACES & BACKGROUNDS
  // ═══════════════════════════════════════════════════════════

  /// Fond principal de l'app
  static const Color background = Color(0xFFFAFAFA);

  /// Surface des cartes et modals
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface légèrement teintée (alternate)
  static const Color surfaceAlt = Color(0xFFF8F9FA);

  // ═══════════════════════════════════════════════════════════
  // TEXTE
  // ═══════════════════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textTertiary = Color(0xFFBDC3C7);
  static const Color textOnColor = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════
  // FEEDBACK (Success, Error, Warning, Info)
  // ═══════════════════════════════════════════════════════════

  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF2ECC71);

  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFF5A4D);

  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFF8B849);

  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFF5DADE2);

  // ═══════════════════════════════════════════════════════════
  // NEUTRALS (Gris)
  // ═══════════════════════════════════════════════════════════

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF8F9FA);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF7F8C8D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // ═══════════════════════════════════════════════════════════
  // LEGACY (pour compatibilité temporaire)
  // ═══════════════════════════════════════════════════════════

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey =
      Color(0xFF7F8C8D); // Maintenant = textSecondary
  static const Color textPremium =
      Color(0xFFFFFFFF); // Maintenant = textOnColor

  // ═══════════════════════════════════════════════════════════
  // BADGES - Couleurs spécifiques
  // ═══════════════════════════════════════════════════════════

  static const Color badgePopular = Color(0xFFF39C12); // Orange
  static const Color badgePopularBg = Color(0xFFFFF3E0); // Orange très pâle

  static const Color badgeNew = Color(0xFFE8573E); // Rouge tomate
  static const Color badgeNewBg = Color(0xFFFFEBEE); // Rouge très pâle

  static const Color badgeSpecialty = Color(0xFF8E44AD); // Violet
  static const Color badgeSpecialtyBg = Color(0xFFF3E5F5); // Violet pâle

  static const Color badgeChef = Color(0xFF16A085); // Turquoise
  static const Color badgeChefBg = Color(0xFFE0F2F1); // Turquoise pâle

  static const Color badgeSeasonal = Color(0xFF27AE60); // Vert
  static const Color badgeSeasonalBg = Color(0xFFE8F5E9); // Vert pâle

  // ═══════════════════════════════════════════════════════════
  // OMBRES
  // ═══════════════════════════════════════════════════════════

  /// Ombre légère pour les cartes
  static BoxShadow get cardShadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      );

  /// Ombre moyenne pour les éléments flottants
  static BoxShadow get elevatedShadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  /// Ombre forte pour les modals
  static BoxShadow get modalShadow => BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.20),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  // ═══════════════════════════════════════════════════════════
  // SUPPRIMÉ - Gradients (plus utilisés dans le nouveau design)
  // ═══════════════════════════════════════════════════════════
  // Les dégradés ont été supprimés pour un design flat moderne
  // Si besoin de dégradés subtils à l'avenir, les ajouter ici
}
