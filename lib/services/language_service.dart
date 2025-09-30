import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return const Locale('he'); // Fallback hebreu
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
