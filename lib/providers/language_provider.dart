import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Règle d’or : pas de if (lang), seulement translate('clé')

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('fr');
  final List<Locale> _supportedLocales = const [
    Locale('fr'),
    Locale('en'),
    Locale('he'),
  ];

  // Getters
  Locale get currentLocale => _currentLocale;
  List<Locale> get supportedLocales => List.unmodifiable(_supportedLocales);
  String get currentLanguageCode => _currentLocale.languageCode;

  // Mapping des codes de langue vers les noms affichés
  static const Map<String, Map<String, String>> _languageNames = {
    'fr': {
      'fr': 'Français',
      'en': 'French',
      'he': 'צרפתית',
    },
    'en': {
      'fr': 'Anglais',
      'en': 'English',
      'he': 'אנגלית',
    },
    'he': {
      'fr': 'Hébreu',
      'en': 'Hebrew',
      'he': 'עברית',
    },
  };

  // Drapeaux pour chaque langue
  static const Map<String, String> _languageFlags = {
    'fr': '🇫🇷',
    'en': '🇺🇸',
    'he': '🇮🇱',
  };

  // Initialiser la langue depuis les préférences
  Future<void> initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage != null && _isLanguageSupported(savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      } else {
        // Détecter la langue du système
        await _detectSystemLanguage();
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de la langue: $e');
      // Utiliser le français par défaut en cas d'erreur
      _currentLocale = const Locale('fr');
    }
  }

  // Changer de langue
  Future<void> changeLanguage(String languageCode) async {
    if (!_isLanguageSupported(languageCode)) {
      debugPrint('Langue non supportée: $languageCode');
      return;
    }

    _currentLocale = Locale(languageCode);
    notifyListeners();

    // Sauvegarder dans les préférences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de la langue: $e');
    }
  }

  // Obtenir le nom d'une langue dans la langue courante
  String getLanguageName(String languageCode) {
    return _languageNames[languageCode]?[currentLanguageCode] ?? languageCode;
  }

  // Obtenir le drapeau d'une langue
  String getLanguageFlag(String languageCode) {
    return _languageFlags[languageCode] ?? '🏳️';
  }

  // Obtenir toutes les langues disponibles avec leurs infos
  List<Map<String, String>> get availableLanguages {
    return _supportedLocales.map((locale) {
      final code = locale.languageCode;
      return {
        'code': code,
        'name': getLanguageName(code),
        'flag': getLanguageFlag(code),
      };
    }).toList();
  }

  // Vérifier si une langue est supportée
  bool _isLanguageSupported(String languageCode) {
    return _supportedLocales
        .any((locale) => locale.languageCode == languageCode);
  }

  // Détecter la langue du système
  Future<void> _detectSystemLanguage() async {
    try {
      // Obtenir la locale du système
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;

      for (final systemLocale in systemLocales) {
        if (_isLanguageSupported(systemLocale.languageCode)) {
          _currentLocale = Locale(systemLocale.languageCode);
          break;
        }
      }

      // Sauvegarder la langue détectée
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, _currentLocale.languageCode);
    } catch (e) {
      debugPrint('Erreur lors de la détection de la langue système: $e');
      // Garder le français par défaut
    }
  }

  // Obtenir la direction du texte pour la langue courante
  TextDirection get currentTextDirection {
    return currentLanguageCode == 'he' ? TextDirection.rtl : TextDirection.ltr;
  }

  // Vérifier si la langue courante est RTL
  bool get isRTL => currentLanguageCode == 'he';

  // Obtenir les traductions simples (pour les textes non externalisés)
  static const Map<String, Map<String, String>> _simpleTranslations = {
    'menu_title': {
      'fr': 'Menu',
      'en': 'Menu',
      'he': 'תפריט',
    },
    'cart': {
      'fr': 'Panier',
      'en': 'Cart',
      'he': 'עגלה',
    },
    'add_to_cart': {
      'fr': 'AJOUTER',
      'en': 'ADD',
      'he': 'הוסף',
    },
    'call_server': {
      'fr': 'Serveur',
      'en': 'Waiter',
      'he': 'מלצר',
    },
    'order_total': {
      'fr': 'TOTAL',
      'en': 'TOTAL',
      'he': 'סך הכל',
    },
    'confirm_order': {
      'fr': 'CONFIRMER COMMANDE',
      'en': 'CONFIRM ORDER',
      'he': 'אשר הזמנה',
    },
  };

  // Obtenir une traduction simple
  String translate(String key) {
    return _simpleTranslations[key]?[currentLanguageCode] ?? key;
  }

  @override
  String toString() {
    return 'LanguageProvider(currentLanguage: $currentLanguageCode, isRTL: $isRTL)';
  }
}
