// lib/core/design/admin_tokens.dart
import 'package:flutter/material.dart';

/// Design System Premium pour l'interface Admin
/// Inspiration: Notion + Linear + Stripe Dashboard
class AdminTokens {
  // ===== COULEURS PRINCIPALES =====

  // Palette neutre premium (base gris/noir)
  static const Color neutral50 = Color(0xFFFAFAFA); // Background très clair
  static const Color neutral100 = Color(0xFFF5F5F5); // Cards, surfaces
  static const Color neutral200 = Color(0xFFE5E5E5); // Borders, dividers
  static const Color neutral300 = Color(0xFFD4D4D4); // Borders actifs
  static const Color neutral400 = Color(0xFFA3A3A3); // Placeholders
  static const Color neutral500 = Color(0xFF737373); // Text secondaire
  static const Color neutral600 = Color(0xFF525252); // Text principal
  static const Color neutral700 = Color(0xFF404040); // Headings
  static const Color neutral800 = Color(0xFF262626); // Titres importants
  static const Color neutral900 = Color(0xFF171717); // Texte max contrast

  // Couleurs d'accent (pour actions, liens, états)
  static const Color primary500 = Color(0xFF6366F1); // Indigo moderne
  static const Color primary600 = Color(0xFF4F46E5); // Hover states
  static const Color primary100 =
      Color(0xFFE0E7FF); // Background primary très léger
  static const Color primary50 = Color(0xFFF0F1FF); // Background primary léger

  // Couleurs fonctionnelles
  static const Color success500 = Color(0xFF10B981); // Vert moderne
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color warning500 = Color(0xFFF59E0B); // Orange attention
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color error500 = Color(0xFFEF4444); // Rouge erreur
  static const Color error50 = Color(0xFFFEF2F2);

  // ===== ESPACEMENTS =====

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ===== RADIUS =====

  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;

  // ===== ÉLÉVATIONS =====

  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;

// ===== BREAKPOINTS RESPONSIVE =====
  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;

// Padding responsive
  static double responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) return space12;
    if (width < breakpointTablet) return space16;
    return space20;
  }

// Container max width responsive
  static double responsiveMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < breakpointMobile) return width - (space16 * 2);
    return 440.0;
  }

  // ===== OMBRES PREMIUM =====

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: neutral900.withAlpha((255 * 0.5).round()),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: neutral900.withAlpha((255 * 0.1).round()),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: neutral900.withAlpha((255 * 0.6).round()),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: neutral900.withAlpha((255 * 0.15).round()),
          blurRadius: 25,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: neutral900.withAlpha((255 * 0.8).round()),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // ===== TAILLES D'ICÔNES =====

  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;

  // ===== HAUTEURS DE COMPOSANTS =====

  static const double buttonHeightSm = 32.0;
  static const double buttonHeightMd = 40.0;
  static const double buttonHeightLg = 48.0;

  static const double inputHeight = 44.0;
  static const double listItemHeight = 60.0;
  static const double sidebarWidth = 280.0;
  static const double topbarHeight = 64.0;

  // ===== ANIMATIONS =====

  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  static const Curve animationCurve = Curves.easeInOutCubic;

  static const BoxShadow cardShadow = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // === Gradient pour hero card ===
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6D5DF6), primary600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

// === Couleur border unifiée ===
  static const Color border = Color(0xFFE5E7EB);
}
