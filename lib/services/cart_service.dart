class CartService {
  // Version surchargée pour gérer les deux types
  static double getItemPrice(String itemName, dynamic menuData) {
    if (menuData is Map<String, List<Map<String, dynamic>>>) {
      // Nouveau format
      for (var categoryItems in menuData.values) {
        for (var item in categoryItems) {
          if (item['name'] == itemName) {
            return (item['price'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }
    } else if (menuData is Map<String, dynamic>) {
      // Ancien format
      for (var category in menuData.values) {
        if (category is List) {
          for (var item in category) {
            if (item['name'] == itemName) {
              return (item['price'] as num?)?.toDouble() ?? 0.0;
            }
          }
        }
      }
    }
    return 0.0;
  }

  static double calculateTotal(
      Map<String, int> itemQuantities, dynamic menuData) {
    double total = 0.0;
    for (var entry in itemQuantities.entries) {
      double itemPrice = getItemPrice(entry.key, menuData);
      total += itemPrice * entry.value;
    }
    return total;
  }

  static int getTotalItemCount(Map<String, int> itemQuantities) {
    return itemQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  static String buildOrderSummary(
      Map<String, int> itemQuantities, dynamic menuData) {
    String orderSummary = 'Commande confirmee !\n\nRecapitulatif:\n\n';

    for (var entry in itemQuantities.entries) {
      double itemPrice = getItemPrice(entry.key, menuData);
      orderSummary +=
          '• ${entry.key} x${entry.value} - ₪${(itemPrice * entry.value).toStringAsFixed(2)}\n';
    }

    double total = calculateTotal(itemQuantities, menuData);
    orderSummary += '\nTOTAL: ₪${total.toStringAsFixed(2)}\n\n';
    orderSummary += 'Votre commande a été transmise à la cuisine !\n';
    orderSummary += 'Temps d\'attente estimé: 15-20 minutes';

    return orderSummary;
  }
}
