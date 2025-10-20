import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LanguageService {
  static const String _languageKey = 'app_language';

  // Langues supportées
  static const List<Locale> supportedLocales = [
    Locale('he'),
    Locale('en'),
    Locale('fr'),
  ];

  // Récupère la langue sauvegardée ou détecte celle du système
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      return Locale(languageCode);
    }

    // Si pas de langue sauvegardée, retourne null (système par défaut)
    return const Locale('fr'); // Fallback français
  }

// Récupère la langue par défaut du restaurant (pour le menu client)
  static Future<Locale> getRestaurantDefaultLanguage(
      String? restaurantId) async {
    // 1. Si l'utilisateur a déjà choisi une langue, utilise-la
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      return Locale(savedLang);
    }

    // 2. Si on a un restaurantId, récupère la langue par défaut de l'admin
    if (restaurantId != null && restaurantId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('info')
            .doc('details')
            .get();

        final defaultLang = doc.data()?['defaultLanguage'] as String?;
        if (defaultLang != null && ['fr', 'en', 'he'].contains(defaultLang)) {
          return Locale(defaultLang);
        }
      } catch (e) {
        debugPrint('Erreur chargement langue restaurant: $e');
      }
    }

    // 3. Sinon, fallback anglais
    return const Locale('en');
  }

  // Sauvegarde la langue choisie
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  // Récupère le nom natif de la langue
  static String getNativeName(String languageCode) {
    switch (languageCode) {
      case 'he':
        return 'עברית';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }

  // Récupère l'emoji drapeau de la langue
  static String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'he':
        return '🇮🇱';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌐';
    }
  }
}
