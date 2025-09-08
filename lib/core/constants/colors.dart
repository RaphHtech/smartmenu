import 'package:flutter/material.dart';

// Seule source de vérité pour la palette et les gradients (headerGradient, surfaces…).

class AppColors {
  // Couleurs principales Pizza Power (identiques au HTML)
  static const Color primary = Color(0xFFDC2626);
  static const Color secondary = Color(0xFFF97316);
  static const Color accent = Color(0xFFFCD34D);
  static const Color textPremium = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFF3A3A3A);

// // === Dégradé global du BODY (HTML: 135deg, 0%/50%/100%) ===
//   static const LinearGradient bgGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primary, secondary, accent],
//     stops: [0.0, 0.65, 1.0],
//   );

  // 🔥 SOLUTION 2: Alternative avec couleurs intermédiaires
  static const LinearGradient bgGradientWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primary, // Rouge pur
      Color(0xFFE53E3E), // Rouge-orange intermédiaire
      secondary, // Orange
      Color(0xFFF6AD55), // Orange-jaune intermédiaire
      accent, // Jaune
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // Voile global très léger (assombrit surtout le haut, quasi nul en bas)
  static const LinearGradient pageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(0, 0, 0, 0.05), // haut
      Color.fromRGBO(0, 0, 0, 0.02), // milieu
      Color.fromRGBO(0, 0, 0, 0.00), // bas
    ],
    stops: [0.0, 0.35, 0.80],
  );

  // Overlay sombre du header (rgba(0,0,0,0.20))
  static const Color headerOverlay = Color.fromRGBO(
      0, 0, 0, 0.1); // titleGradient permet le texte en dégradé du nom du resto

  static const Color heroOverlay = Color.fromRGBO(0, 0, 0, 0.05); // héro

  // Gradients harmonisés avec HTML
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary, accent],
    stops: [0.0, 0.9, 1.0],
  );

  // Dégradé du titre centré ("PIZZA POWER") : blanc → jaune
  static const LinearGradient titleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, accent],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, secondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromRGBO(255, 255, 255, 0.15),
      Color.fromRGBO(255, 255, 255, 0.05),
    ],
  );

  static const Color waiterPillBg = Color(0xFFFCD34D);
  static const Color headerDivider =
      Color.fromRGBO(255, 255, 255, 0.10); // Bordure basse du header

  // static const LinearGradient primaryGradient = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [primary, secondary, accent],
  //   stops: [0.0, 0.5, 1.0],
  // );

  // Couleurs fonctionnelles
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Couleurs neutres
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey800 = Color(0xFF1F2937);

  // Ombres
  static BoxShadow get primaryShadow => const BoxShadow(
        color: Color.fromRGBO(220, 38, 38, 0.3),
        blurRadius: 25,
        offset: Offset(0, 8),
      );

  static BoxShadow get cardShadow => const BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        blurRadius: 15,
        offset: Offset(0, 4),
      );
}
