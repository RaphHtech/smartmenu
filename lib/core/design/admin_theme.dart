// lib/core/design/admin_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_tokens.dart';
import 'admin_typography.dart';

/// Thème premium pour l'interface Admin
/// Design inspiré de Notion, Linear, Stripe Dashboard
class AdminTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // ===== COULEURS DE BASE =====
      colorScheme: ColorScheme.light(
        primary: AdminTokens.primary500,
        onPrimary: Colors.white,
        primaryContainer: AdminTokens.primary50,
        onPrimaryContainer: AdminTokens.primary600,
        secondary: AdminTokens.neutral600,
        onSecondary: Colors.white,
        secondaryContainer: AdminTokens.neutral100,
        onSecondaryContainer: AdminTokens.neutral700,
        surface: Colors.white,
        onSurface: AdminTokens.neutral800,
        surfaceContainerHighest: AdminTokens.neutral50,
        onSurfaceVariant: AdminTokens.neutral600,
        error: AdminTokens.error500,
        onError: Colors.white,
        errorContainer: AdminTokens.error50,
        onErrorContainer: AdminTokens.error500,
        outline: AdminTokens.neutral200,
        outlineVariant: AdminTokens.neutral100,
        shadow: AdminTokens.neutral900.withOpacity(0.1),
      ),

      // ===== TYPOGRAPHY =====
      textTheme: const TextTheme(
        displayLarge: AdminTypography.displayLarge,
        displayMedium: AdminTypography.displayMedium,
        displaySmall: AdminTypography.displaySmall,
        headlineLarge: AdminTypography.headlineLarge,
        headlineMedium: AdminTypography.headlineMedium,
        headlineSmall: AdminTypography.headlineSmall,
        bodyLarge: AdminTypography.bodyLarge,
        bodyMedium: AdminTypography.bodyMedium,
        bodySmall: AdminTypography.bodySmall,
        labelLarge: AdminTypography.labelLarge,
        labelMedium: AdminTypography.labelMedium,
        labelSmall: AdminTypography.labelSmall,
      ),

      // ===== APP BAR =====
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: AdminTokens.neutral800,
        surfaceTintColor: Colors.transparent,
        shadowColor: AdminTokens.neutral900.withOpacity(0.1),
        titleTextStyle: AdminTypography.headlineLarge,
        toolbarHeight: AdminTokens.topbarHeight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: const Border(
          bottom: BorderSide(
            color: AdminTokens.neutral200,
            width: 1,
          ),
        ),
      ),

      // ===== CARDS =====
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: AdminTokens.neutral900.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius12),
          side: const BorderSide(
            color: AdminTokens.neutral200,
            width: 1,
          ),
        ),
      ),

      // ===== BUTTONS =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AdminTokens.primary500,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTokens.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AdminTokens.space20,
            vertical: AdminTokens.space12,
          ),
          minimumSize: const Size(0, AdminTokens.buttonHeightMd),
          textStyle: AdminTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          // Hover effects
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withOpacity(0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withOpacity(0.2);
            }
            return null;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AdminTokens.neutral300;
            }
            if (states.contains(WidgetState.hovered)) {
              return AdminTokens.primary600;
            }
            return AdminTokens.primary500;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AdminTokens.neutral600,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTokens.radius8),
          ),
          side: const BorderSide(
            color: AdminTokens.neutral300,
            width: 1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AdminTokens.space20,
            vertical: AdminTokens.space12,
          ),
          minimumSize: const Size(0, AdminTokens.buttonHeightMd),
          textStyle: AdminTypography.labelLarge.copyWith(
            color: AdminTokens.neutral600,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          // Hover effects
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AdminTokens.neutral100;
            }
            if (states.contains(WidgetState.pressed)) {
              return AdminTokens.neutral200;
            }
            return null;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(color: AdminTokens.neutral400, width: 1);
            }
            return const BorderSide(color: AdminTokens.neutral300, width: 1);
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AdminTokens.primary600,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTokens.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AdminTokens.space16,
            vertical: AdminTokens.space8,
          ),
          minimumSize: const Size(0, AdminTokens.buttonHeightSm),
          textStyle: AdminTypography.labelMedium.copyWith(
            color: AdminTokens.primary600,
            fontWeight: FontWeight.w500,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AdminTokens.primary50;
            }
            if (states.contains(WidgetState.pressed)) {
              return AdminTokens.primary50.withOpacity(0.8);
            }
            return null;
          }),
        ),
      ),

      // ===== INPUT FIELDS =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
          borderSide: const BorderSide(
            color: AdminTokens.neutral300,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
          borderSide: const BorderSide(
            color: AdminTokens.neutral300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
          borderSide: const BorderSide(
            color: AdminTokens.primary500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
          borderSide: const BorderSide(
            color: AdminTokens.error500,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
          borderSide: const BorderSide(
            color: AdminTokens.error500,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdminTokens.space16,
          vertical: AdminTokens.space12,
        ),
        labelStyle: AdminTypography.labelLarge,
        hintStyle: AdminTypography.placeholder,
        errorStyle: AdminTypography.bodySmall.copyWith(
          color: AdminTokens.error500,
        ),
        prefixIconColor: AdminTokens.neutral400,
        suffixIconColor: AdminTokens.neutral400,
      ),

      // ===== LIST TILES =====
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AdminTokens.space16,
          vertical: AdminTokens.space8,
        ),
        minLeadingWidth: 40,
        horizontalTitleGap: AdminTokens.space12,
        titleTextStyle: AdminTypography.headlineMedium,
        subtitleTextStyle: AdminTypography.bodyMedium,
        leadingAndTrailingTextStyle: AdminTypography.bodyMedium,
      ),

      // ===== DIVIDERS =====
      dividerTheme: const DividerThemeData(
        color: AdminTokens.neutral200,
        thickness: 1,
        space: 1,
      ),

      // ===== SWITCHES =====
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AdminTokens.neutral300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AdminTokens.primary500;
          return AdminTokens.neutral200;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ===== CHECKBOX =====
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return AdminTokens.primary500;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AdminTokens.neutral300, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius4),
        ),
      ),

      // ===== SNACKBAR =====
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminTokens.neutral800,
        contentTextStyle: AdminTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ===== DIALOG =====
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: AdminTokens.neutral900.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius16),
        ),
        titleTextStyle: AdminTypography.headlineLarge,
        contentTextStyle: AdminTypography.bodyMedium,
      ),

      // ===== SCAFFOLD =====
      scaffoldBackgroundColor: AdminTokens.neutral50,

      // ===== ICONS =====
      iconTheme: const IconThemeData(
        color: AdminTokens.neutral500,
        size: AdminTokens.iconMd,
      ),

      // ===== FLOATING ACTION BUTTON =====
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AdminTokens.primary500,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        shape: CircleBorder(),
      ),
    );
  }

  // Méthode pour appliquer le thème dans main.dart
  static ThemeData get theme => lightTheme;
}
