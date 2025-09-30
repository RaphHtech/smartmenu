class MenuItemTranslation {
  final String name;
  final String description;

  MenuItemTranslation({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory MenuItemTranslation.fromJson(Map<String, dynamic> json) =>
      MenuItemTranslation(
        name: json['name'] ?? '',
        description: json['description'] ?? '',
      );
}
