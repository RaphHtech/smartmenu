class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool visible;
  final bool signature; // Legacy - garder temporairement
  final bool featured; // NOUVEAU
  final List<String> badges; // NOUVEAU
  final double? position;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.visible = true,
    this.signature = false,
    this.featured = false,
    this.badges = const [],
    this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'visible': visible,
      'signature': signature,
      'featured': featured,
      'badges': badges,
      'position': position,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MenuItem.fromJson(Map<String, dynamic> json, String id) {
    return MenuItem(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      visible: json['visible'] ?? true,
      signature: json['signature'] ?? false,
      featured: json['featured'] ?? false,
      badges: List<String>.from(json['badges'] ?? []),
      position: json['position']?.toDouble(),
      createdAt: json['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: json['updated_at']?.toDate() ?? DateTime.now(),
    );
  }
}
