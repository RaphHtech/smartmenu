class AnalyticsService {
  static void logMenuOpen(String restaurantId, {String? tableId}) {
    print('ANALYTICS: menu_open - resto: $restaurantId, table: $tableId');
    // TODO: intégration Firebase Analytics
  }

  static void logAddToCart(String restaurantId, String itemName,
      {String? tableId}) {
    print(
        'ANALYTICS: add_to_cart - resto: $restaurantId, item: $itemName, table: $tableId');
    // TODO: intégration Firebase Analytics
  }
}
