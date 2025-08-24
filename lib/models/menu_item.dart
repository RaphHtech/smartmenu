class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final String emoji;
  final bool isSignature;
  final List<String> allergens;
  final bool isAvailable;
  final Map<String, String> nameTranslations;
  final Map<String, String> descriptionTranslations;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.emoji,
    this.isSignature = false,
    this.allergens = const [],
    this.isAvailable = true,
    this.nameTranslations = const {},
    this.descriptionTranslations = const {},
  });

  // Obtenir le nom dans la langue demandée
  String getLocalizedName(String languageCode) {
    return nameTranslations[languageCode] ?? name;
  }

  // Obtenir la description dans la langue demandée
  String getLocalizedDescription(String languageCode) {
    return descriptionTranslations[languageCode] ?? description;
  }

  // Prix formaté avec devise
  String get formattedPrice => '₪${price.toStringAsFixed(0)}';

  // Copie avec modifications
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    String? emoji,
    bool? isSignature,
    List<String>? allergens,
    bool? isAvailable,
    Map<String, String>? nameTranslations,
    Map<String, String>? descriptionTranslations,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      emoji: emoji ?? this.emoji,
      isSignature: isSignature ?? this.isSignature,
      allergens: allergens ?? this.allergens,
      isAvailable: isAvailable ?? this.isAvailable,
      nameTranslations: nameTranslations ?? this.nameTranslations,
      descriptionTranslations:
          descriptionTranslations ?? this.descriptionTranslations,
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'emoji': emoji,
      'isSignature': isSignature,
      'allergens': allergens,
      'isAvailable': isAvailable,
      'nameTranslations': nameTranslations,
      'descriptionTranslations': descriptionTranslations,
    };
  }

  // Création depuis JSON
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      emoji: json['emoji'] ?? '🍽️',
      isSignature: json['isSignature'] ?? false,
      allergens: List<String>.from(json['allergens'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      nameTranslations:
          Map<String, String>.from(json['nameTranslations'] ?? {}),
      descriptionTranslations:
          Map<String, String>.from(json['descriptionTranslations'] ?? {}),
    );
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
