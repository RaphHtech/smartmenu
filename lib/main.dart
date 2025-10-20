import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/admin/admin_dashboard_screen.dart';

// Import i18n
import 'l10n/app_localizations.dart';

// Import state
import 'state/language_provider.dart';

// Import screens
import 'screens/home_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_signup_screen.dart';
import 'package:smartmenu_app/screens/admin/auth/admin_reset_screen.dart';
// Import core
import 'core/constants/colors.dart';
import 'widgets/ui/admin_themed.dart';
import 'core/auth/auth_guard.dart';
import 'screens/menu/resolve_restaurant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const SmartMenuApp(),
    ),
  );
}

class SmartMenuApp extends StatelessWidget {
  const SmartMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'SmartMenu',
          debugShowCheckedModeBanner: false,

          // Configuration i18n avec provider
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: languageProvider.locale, // Langue du provider
          builder: (context, child) {
            final locale = languageProvider.locale;
            // Force LTR pour français et anglais, garde RTL pour hébreu
            final textDirection = locale.languageCode == 'he'
                ? TextDirection.rtl
                : TextDirection.ltr;

            return Directionality(
              textDirection: textDirection,
              child: child!,
            );
          },

          home: _getInitialScreen(),
          theme: _buildTheme(),
          onGenerateRoute: (settings) {
            final name = settings.name ?? '';
            final uri = Uri.tryParse(name);

            // Routes restaurant /r/...
            if (uri != null &&
                uri.pathSegments.isNotEmpty &&
                uri.pathSegments.first == 'r') {
              final idOrSlug =
                  (uri.pathSegments.length > 1) ? uri.pathSegments[1] : '';
              return MaterialPageRoute(
                builder: (_) => ResolveRestaurantScreen(idOrSlug: idOrSlug),
              );
            }

            // Routes admin /admin/...
            if (uri != null &&
                uri.pathSegments.isNotEmpty &&
                uri.pathSegments.first == 'admin') {
              final path = uri.path;
              final rid = uri.queryParameters['restaurantId'];

              if (path.startsWith('/admin/dashboard')) {
                return MaterialPageRoute(
                  builder: (_) =>
                      _getAdminDashboard(rid), // ⬅️ Passe rid en paramètre
                );
              }

              if (path == '/admin/login') {
                final returnUrl = uri.queryParameters['returnUrl'];
                return MaterialPageRoute(
                  builder: (_) => AdminThemed(
                    child: AdminLoginScreen(returnUrl: returnUrl),
                  ),
                );
              }

              if (path == '/admin/signup') {
                return MaterialPageRoute(
                  builder: (_) => const AdminThemed(child: AdminSignupScreen()),
                );
              }

              if (path == '/admin/reset') {
                return MaterialPageRoute(
                  builder: (_) => const AdminThemed(child: AdminResetScreen()),
                );
              }

              // Défaut : login
              return MaterialPageRoute(
                builder: (_) => const AdminThemed(child: AdminLoginScreen()),
              );
            }

            return null;
          },
        );
      },
    );
  }

  Widget _getInitialScreen() {
    if (kIsWeb) {
      final segments = Uri.base.pathSegments;

      if (segments.isNotEmpty && segments[0] == 'r') {
        final idOrSlug = (segments.length > 1) ? segments[1] : '';
        return ResolveRestaurantScreen(idOrSlug: idOrSlug);
      }

      if (segments.isNotEmpty && segments[0] == 'admin') {
        final requestedPath = '/${segments.join('/')}';
        final redirectRoute = AuthGuard.getRedirectRoute(requestedPath);

        if (redirectRoute != null) {
          final uri = Uri.parse(redirectRoute);
          final returnUrl = uri.queryParameters['returnUrl'];

          switch (uri.path) {
            case '/admin/login':
              return AdminThemed(child: AdminLoginScreen(returnUrl: returnUrl));
            case '/admin/dashboard':
              final rid = Uri.base.queryParameters['restaurantId'];
              return _getAdminDashboard(rid);
            default:
              return const AdminThemed(child: AdminLoginScreen());
          }
        }

        if (segments.length > 1) {
          switch (segments[1]) {
            case 'login':
              final returnUrl = Uri.base.queryParameters['returnUrl'];
              return AdminThemed(child: AdminLoginScreen(returnUrl: returnUrl));
            case 'signup':
              return const AdminThemed(child: AdminSignupScreen());
            case 'reset':
              return const AdminThemed(child: AdminResetScreen());
          }
        }

        return const AdminThemed(child: AdminLoginScreen());
      }
    }

    return const HomeScreen();
  }

  Widget _getAdminDashboard(String? rid) {
    debugPrint('🔵 _getAdminDashboard called with rid: $rid');

    if (rid == null || rid.isEmpty) {
      return const AdminThemed(
        child: AdminLoginScreen(returnUrl: '/admin/dashboard'),
      );
    }

    return AdminDashboardScreen(restaurantId: rid);
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
