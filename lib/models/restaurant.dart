class Restaurant {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String? logoUrl;
  final String? coverUrl;
  final String theme; // 'pizza', 'sushi', 'burger', etc.
  final List<String> openingHours;
  final bool isOpen;
  final List<String> supportedLanguages;
  final String defaultLanguage;
  final Map<String, String> nameTranslations;
  final Map<String, String> descriptionTranslations;
  final RestaurantSettings settings;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    this.logoUrl,
    this.coverUrl,
    this.theme = 'restaurant',
    this.openingHours = const [],
    this.isOpen = true,
    this.supportedLanguages = const ['fr', 'en', 'he'],
    this.defaultLanguage = 'fr',
    this.nameTranslations = const {},
    this.descriptionTranslations = const {},
    required this.settings,
  });

  // Obtenir le nom dans la langue demandée
  String getLocalizedName(String languageCode) {
    return nameTranslations[languageCode] ?? name;
  }

  // Obtenir la description dans la langue demandée
  String getLocalizedDescription(String languageCode) {
    return descriptionTranslations[languageCode] ?? description;
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'theme': theme,
      'openingHours': openingHours,
      'isOpen': isOpen,
      'supportedLanguages': supportedLanguages,
      'defaultLanguage': defaultLanguage,
      'nameTranslations': nameTranslations,
      'descriptionTranslations': descriptionTranslations,
      'settings': settings.toJson(),
    };
  }

  // Création depuis JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      logoUrl: json['logoUrl'],
      coverUrl: json['coverUrl'],
      theme: json['theme'] ?? 'restaurant',
      openingHours: List<String>.from(json['openingHours'] ?? []),
      isOpen: json['isOpen'] ?? true,
      supportedLanguages:
          List<String>.from(json['supportedLanguages'] ?? ['fr', 'en', 'he']),
      defaultLanguage: json['defaultLanguage'] ?? 'fr',
      nameTranslations:
          Map<String, String>.from(json['nameTranslations'] ?? {}),
      descriptionTranslations:
          Map<String, String>.from(json['descriptionTranslations'] ?? {}),
      settings: RestaurantSettings.fromJson(json['settings'] ?? {}),
    );
  }
}

class RestaurantSettings {
  final bool allowCallServer;
  final bool showPrices;
  final bool enableCart;
  final bool requireTableNumber;
  final String currency;
  final String timezone;
  final List<String> categories;
  final Map<String, String> categoryTranslations;

  RestaurantSettings({
    this.allowCallServer = true,
    this.showPrices = true,
    this.enableCart = true,
    this.requireTableNumber = true,
    this.currency = '₪',
    this.timezone = 'Asia/Jerusalem',
    this.categories = const [
      'pizzas',
      'entrees',
      'pates',
      'desserts',
      'boissons'
    ],
    this.categoryTranslations = const {},
  });

  // Obtenir la traduction d'une catégorie
  String getLocalizedCategory(String category, String languageCode) {
    final key = '${category}_$languageCode';
    return categoryTranslations[key] ?? category;
  }

  Map<String, dynamic> toJson() {
    return {
      'allowCallServer': allowCallServer,
      'showPrices': showPrices,
      'enableCart': enableCart,
      'requireTableNumber': requireTableNumber,
      'currency': currency,
      'timezone': timezone,
      'categories': categories,
      'categoryTranslations': categoryTranslations,
    };
  }

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) {
    return RestaurantSettings(
      allowCallServer: json['allowCallServer'] ?? true,
      showPrices: json['showPrices'] ?? true,
      enableCart: json['enableCart'] ?? true,
      requireTableNumber: json['requireTableNumber'] ?? true,
      currency: json['currency'] ?? '₪',
      timezone: json['timezone'] ?? 'Asia/Jerusalem',
      categories: List<String>.from(json['categories'] ??
          ['pizzas', 'entrees', 'pates', 'desserts', 'boissons']),
      categoryTranslations:
          Map<String, String>.from(json['categoryTranslations'] ?? {}),
    );
  }
}
