import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'core/routes/app_router.dart';
import 'screens/menu/simple_menu_screen.dart'; // ← NOUVEAU
import 'core/constants/colors.dart';
import 'core/constants/text_styles.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la langue
  final languageProvider = LanguageProvider();
  await languageProvider.initializeLanguage();

  runApp(SmartMenuApp(languageProvider: languageProvider));
}

class SmartMenuApp extends StatelessWidget {
  final LanguageProvider languageProvider;

  const SmartMenuApp({
    super.key,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            // MaterialApp.router(
            title: 'SmartMenu',
            debugShowCheckedModeBanner: false,

            // Configuration des langues
            locale: languageProvider.currentLocale,
            supportedLocales: languageProvider.supportedLocales,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Configuration du router
            // routerConfig: AppRouter.router,
            home: const SimpleMenuScreen(),

            // Thème de l'application
            // N’affecte PAS le header custom car il est dans le body.
            theme: _buildTheme(languageProvider),
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(LanguageProvider languageProvider) {
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

      // Configuration des textes
      textTheme: TextTheme(
        displayLarge: AppTextStyles.heroTitle,
        displayMedium: AppTextStyles.sectionTitle,
        displaySmall: AppTextStyles.cardTitle,
        headlineLarge: AppTextStyles.sectionTitle,
        headlineMedium: AppTextStyles.cardTitle,
        headlineSmall: AppTextStyles.bodyLarge,
        titleLarge: AppTextStyles.cardTitle,
        titleMedium: AppTextStyles.bodyLarge,
        titleSmall: AppTextStyles.bodyMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
      ),

      // Configuration des boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color.fromRGBO(220, 38, 38, 0.3),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Configuration de l'AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.gradientText,
      ),

      // Configuration des chips
      chipTheme: ChipThemeData(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.1),
        selectedColor: const Color.fromRGBO(255, 255, 255, 0.9),
        labelStyle: AppTextStyles.navInactive,
        secondaryLabelStyle: AppTextStyles.navActive,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(
            color: Color.fromRGBO(255, 255, 255, 0.3),
            width: 2,
          ),
        ),
      ),

      // Configuration des FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Support RTL
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
