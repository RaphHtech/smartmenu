class CartService {
  static double getItemPrice(String itemName, Map<String, dynamic> menuData) {
    for (var category in menuData.values) {
      for (var item in category) {
        if (item['name'] == itemName) {
          final priceText = item['price'].toString().replaceAll('₪', '');
          return double.tryParse(priceText) ?? 0.0;
        }
      }
    }
    return 0.0;
  }

  static double calculateTotal(
      Map<String, int> itemQuantities, Map<String, dynamic> menuData) {
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
      Map<String, int> itemQuantities, Map<String, dynamic> menuData) {
    String orderSummary = '🎉 COMMANDE CONFIRMÉE !\n\n📋 RÉCAPITULATIF:\n\n';

    for (var entry in itemQuantities.entries) {
      double itemPrice = getItemPrice(entry.key, menuData);
      orderSummary +=
          '• ${entry.key} x${entry.value} - ₪${(itemPrice * entry.value).toStringAsFixed(2)}\n';
    }

    double total = calculateTotal(itemQuantities, menuData);
    orderSummary += '\nTOTAL: ₪${total.toStringAsFixed(2)}\n\n';
    orderSummary += '✅ Votre commande a été transmise à la cuisine !\n';
    orderSummary += '⏱️ Temps d\'attente estimé: 15-20 minutes';

    return orderSummary;
  }
}
