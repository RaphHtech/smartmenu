import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';
import '../core/utils/mock_data.dart';

class MenuProvider with ChangeNotifier {
  Restaurant? _restaurant;
  List<MenuItem> _menuItems = [];
  String _selectedCategory = 'pizzas';
  bool _isLoading = false;
  String? _error;

  // Getters
  Restaurant? get restaurant => _restaurant;
  List<MenuItem> get menuItems => List.unmodifiable(_menuItems);
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtenir les items de la catégorie sélectionnée
  List<MenuItem> get currentCategoryItems {
    return _menuItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  // Obtenir toutes les catégories disponibles
  List<String> get availableCategories {
    if (_restaurant?.settings.categories != null) {
      return _restaurant!.settings.categories;
    }
    return _menuItems.map((item) => item.category).toSet().toList();
  }

  // Obtenir les items signature
  List<MenuItem> get signatureItems {
    return _menuItems.where((item) => item.isSignature).toList();
  }

  // Obtenir les items disponibles
  List<MenuItem> get availableItems {
    return _menuItems.where((item) => item.isAvailable).toList();
  }

  // Initialiser avec les données de test
  Future<void> loadMockData() async {
    _setLoading(true);
    _clearError();

    try {
      // Simuler un délai de chargement
      await Future.delayed(const Duration(milliseconds: 500));

      _restaurant = MockData.pizzaPowerRestaurant;
      _menuItems = MockData.menuItems;

      // S'assurer que la catégorie sélectionnée existe
      if (!availableCategories.contains(_selectedCategory)) {
        _selectedCategory = availableCategories.first;
      }

      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement du menu: $e');
      _setLoading(false);
    }
  }

  // Charger un restaurant depuis une API (futur)
  Future<void> loadRestaurant(String restaurantId) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implémenter l'appel API
      // Pour l'instant, on utilise les données de test
      await loadMockData();
    } catch (e) {
      _setError('Erreur lors du chargement du restaurant: $e');
      _setLoading(false);
    }
  }

  // Changer de catégorie
  void selectCategory(String category) {
    if (availableCategories.contains(category)) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Rechercher des items
  List<MenuItem> searchItems(String query) {
    if (query.isEmpty) return currentCategoryItems;

    final lowercaseQuery = query.toLowerCase();
    return _menuItems.where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Obtenir un item par ID
  MenuItem? getItemById(String id) {
    try {
      return _menuItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les items par catégorie
  List<MenuItem> getItemsByCategory(String category) {
    return _menuItems.where((item) => item.category == category).toList();
  }

  // Obtenir le nom localisé d'une catégorie
  String getLocalizedCategoryName(String category, String languageCode) {
    if (_restaurant?.settings != null) {
      return _restaurant!.settings.getLocalizedCategory(category, languageCode);
    }
    return category;
  }

  // Rafraîchir le menu
  Future<void> refreshMenu() async {
    await loadMockData();
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  String toString() {
    return 'MenuProvider(restaurant: ${_restaurant?.name}, items: ${_menuItems.length}, category: $_selectedCategory)';
  }
}
