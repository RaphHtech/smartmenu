import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// Typo / tailles texte

class AppTextStyles {
  // Base font family
  static TextStyle get _baseStyle => GoogleFonts.inter();

  // Headers

  static TextStyle get headerTitle => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: 0.5,
        height: 1.1,
      );

  static TextStyle get heroTitle => _baseStyle.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
        height: 1.1,
      );

  static TextStyle get sectionTitle => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.accent,
        height: 1.2,
      );

  static TextStyle get cardTitle => _baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
        height: 1.3,
      );

  // Body text
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.4,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        height: 1.4,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color.fromRGBO(255, 255, 255, 0.9),
        height: 1.4,
      );

  // Buttons
  static TextStyle get buttonLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get buttonMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  // Prices
  static TextStyle get priceMain => _baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.accent,
      );

  static TextStyle get priceSecondary => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.accent,
      );

  // Navigation
  static TextStyle get navActive => _baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get navInactive => _baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // Special effects
  static TextStyle get gradientText => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        foreground: Paint()
          ..shader = const LinearGradient(
            colors: [AppColors.white, AppColors.accent],
          ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
      );

  static TextStyle get headerSubtitle => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color.fromRGBO(255, 255, 255, 0.85),
        height: 1.2,
      );
}
