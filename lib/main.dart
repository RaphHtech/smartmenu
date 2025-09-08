import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/menu/menu_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_signup_screen.dart';

// Import core
import 'core/constants/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartMenuApp());
}

class SmartMenuApp extends StatelessWidget {
  const SmartMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartMenu',
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
      theme: _buildTheme(),
    );
  }

  Widget _getInitialScreen() {
    if (kIsWeb) {
      final segments = Uri.base.pathSegments;

      // Route /admin
      if (segments.isNotEmpty && segments[0] == 'admin') {
        if (segments.length > 1 && segments[1] == 'signup') {
          return const AdminSignupScreen();
        }
        return const AdminLoginScreen();
      }

      // Route /r/{restaurantId}
      if (segments.length >= 2 && segments[0] == 'r') {
        return MenuScreen(restaurantId: segments[1]);
      }
    }

    // Route par défaut
    return HomeScreen();
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
