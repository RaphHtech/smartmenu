class TranslationHelper {
  /// Récupère un champ traduit avec cascade de fallback
  /// 1. Locale demandée
  /// 2. Locale par défaut du restaurant
  /// 3. Anglais
  /// 4. Première langue disponible
  /// 5. Champ legacy
  static String getTranslatedField(
    Map<String, dynamic> item,
    String locale,
    String field, {
    String restaurantDefaultLocale = 'he',
  }) {
    final translations = item['translations'] as Map<String, dynamic>?;

    // 1. Locale demandée
    if (translations?[locale]?[field] != null &&
        translations![locale]![field].toString().trim().isNotEmpty) {
      return translations[locale]![field].toString();
    }

    // 2. Restaurant default locale
    if (locale != restaurantDefaultLocale &&
        translations?[restaurantDefaultLocale]?[field] != null &&
        translations![restaurantDefaultLocale]![field]
            .toString()
            .trim()
            .isNotEmpty) {
      return translations[restaurantDefaultLocale]![field].toString();
    }

    // 3. Anglais
    if (locale != 'en' &&
        restaurantDefaultLocale != 'en' &&
        translations?['en']?[field] != null &&
        translations!['en']![field].toString().trim().isNotEmpty) {
      return translations['en']![field].toString();
    }

    // 4. Première langue disponible
    if (translations != null) {
      for (final lang in translations.keys) {
        if (translations[lang]?[field] != null &&
            translations[lang]![field].toString().trim().isNotEmpty) {
          return translations[lang]![field].toString();
        }
      }
    }

    // 5. Fallback legacy
    return item[field]?.toString() ?? '';
  }

  /// Vérifie si une traduction est complète
  static String getTranslationStatus(
    Map<String, dynamic>? translations,
    String locale,
  ) {
    if (translations == null || translations[locale] == null) {
      return 'missing';
    }

    final trans = translations[locale] as Map<String, dynamic>;
    final hasName = trans['name']?.toString().trim().isNotEmpty ?? false;
    final hasDesc = trans['description']?.toString().trim().isNotEmpty ?? false;

    if (hasName && hasDesc) return 'complete';
    if (hasName || hasDesc) return 'partial';
    return 'missing';
  }
}
