import 'package:flutter/material.dart';
import 'package:smartmenu_app/screens/home_screen.dart';
import 'package:smartmenu_app/screens/menu/menu_screen.dart';
import 'core/constants/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:smartmenu_app/screens/admin/admin_login_screen.dart';

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
      final currentUrl = Uri.base;
      final segments = currentUrl.pathSegments;

      // /admin -> login placeholder
      // /admin -> écran de login réel
      if (segments.isNotEmpty && segments[0] == 'admin') {
        return AdminLoginScreen();
      }

      // /r/restaurant-id -> menu direct
      if (segments.length >= 2 && segments[0] == 'r') {
        return MenuScreen(restaurantId: segments[1]);
      }
    }

    return HomeScreen();
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.black,
        onSurface: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          minimumSize: const Size(0, 48),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
