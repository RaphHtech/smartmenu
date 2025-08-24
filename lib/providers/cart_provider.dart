import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  String? _tableNumber;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  String? get tableNumber => _tableNumber;

  // Nombre total d'articles
  int get totalItems {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // Prix total
  double get totalPrice {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  // Prix formaté
  String get formattedTotalPrice => '₪${totalPrice.toStringAsFixed(0)}';

  // Vérifier si le panier est vide
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  // Définir le numéro de table
  void setTableNumber(String? number) {
    _tableNumber = number;
    notifyListeners();
  }

  // Ajouter un item au panier
  void addItem(MenuItem menuItem, {String? specialInstructions}) {
    // Vérifier si l'item existe déjà avec les mêmes instructions
    final existingIndex = _items.indexWhere(
      (item) =>
          item.menuItem.id == menuItem.id &&
          item.specialInstructions == specialInstructions,
    );

    if (existingIndex >= 0) {
      // Augmenter la quantité
      _items[existingIndex].quantity++;
    } else {
      // Ajouter nouvel item
      _items.add(CartItem(
        menuItem: menuItem,
        quantity: 1,
        specialInstructions: specialInstructions,
      ));
    }

    notifyListeners();
  }

  // Retirer un item du panier
  void removeItem(String menuItemId, {String? specialInstructions}) {
    _items.removeWhere(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
    );
    notifyListeners();
  }

  // Mettre à jour la quantité d'un item
  void updateQuantity(String menuItemId, int newQuantity,
      {String? specialInstructions}) {
    if (newQuantity <= 0) {
      removeItem(menuItemId, specialInstructions: specialInstructions);
      return;
    }

    final index = _items.indexWhere(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
    );

    if (index >= 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Augmenter la quantité
  void increaseQuantity(String menuItemId, {String? specialInstructions}) {
    final index = _items.indexWhere(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
    );

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Diminuer la quantité
  void decreaseQuantity(String menuItemId, {String? specialInstructions}) {
    final index = _items.indexWhere(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
    );

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Obtenir la quantité d'un item spécifique
  int getItemQuantity(String menuItemId, {String? specialInstructions}) {
    final item = _items.firstWhere(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
      orElse: () => CartItem(
          menuItem: MenuItem(
            id: '',
            name: '',
            description: '',
            price: 0,
            category: '',
            emoji: '',
          ),
          quantity: 0),
    );
    return item.quantity;
  }

  // Vérifier si un item est dans le panier
  bool containsItem(String menuItemId, {String? specialInstructions}) {
    return _items.any(
      (item) =>
          item.menuItem.id == menuItemId &&
          item.specialInstructions == specialInstructions,
    );
  }

  // Vider le panier
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Créer le résumé de commande
  Map<String, dynamic> createOrderSummary() {
    return {
      'tableNumber': _tableNumber,
      'items': _items.map((item) => item.toJson()).toList(),
      'totalItems': totalItems,
      'totalPrice': totalPrice,
      'orderTime': DateTime.now().toIso8601String(),
    };
  }

  // Obtenir les items par catégorie
  Map<String, List<CartItem>> getItemsByCategory() {
    final Map<String, List<CartItem>> categorizedItems = {};

    for (final item in _items) {
      final category = item.menuItem.category;
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    return categorizedItems;
  }

  @override
  String toString() {
    return 'CartProvider(items: ${_items.length}, total: $formattedTotalPrice, table: $_tableNumber)';
  }
}
