import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Prix total pour cet item
  double get totalPrice => menuItem.price * quantity;

  // Prix formaté
  String get formattedTotalPrice => '₪${totalPrice.toStringAsFixed(0)}';

  // Copie avec modifications
  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Création depuis JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem']),
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  String toString() {
    return 'CartItem(menuItem: ${menuItem.name}, quantity: $quantity, total: $formattedTotalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.menuItem.id == menuItem.id &&
        other.specialInstructions == specialInstructions;
  }

  @override
  int get hashCode => Object.hash(menuItem.id, specialInstructions);
}
