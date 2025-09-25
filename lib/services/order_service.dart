import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../models/order.dart' as models; // Ajouter 'as models'
import '../services/table_service.dart';

class OrderService {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  // Injection pour tests
  static void setFirestoreInstance(FirebaseFirestore instance) {
    _db = instance;
  }

  /// Génère un ID de commande idempotent basé sur un hash
  static String generateOrderId(
      String rid, String table, Map<String, int> items, double total) {
    // Timeslot de 30 secondes pour idempotence
    final now = DateTime.now();
    final timeslot = (now.millisecondsSinceEpoch / 30000).floor();

    // Empreinte du panier : nombre d'items + total arrondi
    final itemCount = items.values.fold(0, (sum, qty) => sum + qty);
    final totalRounded = total.round();

    // Hash des composants
    final components = '$rid|$table|$timeslot|$itemCount|$totalRounded';
    final bytes = utf8.encode(components);
    final hash = sha256.convert(bytes).toString();

    return hash.substring(0, 16); // 16 caractères
  }

  /// Soumet une nouvelle commande
  static Future<String> submitOrder({
    required String restaurantId,
    required Map<String, int> itemQuantities,
    required Map<String, List<Map<String, dynamic>>> menuData,
    required String currency,
  }) async {
    // Récupérer la table depuis TableService
    final table = 'table${TableService.getTableId() ?? "1"}';

    // Calculer le total
    final total = _calculateTotal(itemQuantities, menuData);

    // Générer l'ID idempotent
    final oid = generateOrderId(restaurantId, table, itemQuantities, total);

    // Construire la liste des items
    final orderItems = <models.OrderItem>[]; // Utiliser models.OrderItem
    for (final entry in itemQuantities.entries) {
      final itemName = entry.key;
      final quantity = entry.value;
      final price = _getItemPrice(itemName, menuData);

      orderItems.add(models.OrderItem(
        // Utiliser models.OrderItem
        name: itemName,
        price: price,
        quantity: quantity,
      ));
    }

    // Créer l'objet Order
    final order = models.Order(
      // Utiliser models.Order
      oid: oid,
      rid: restaurantId,
      table: table,
      items: orderItems,
      total: total,
      currency: currency,
      status: models.OrderStatus.received, // Utiliser models.OrderStatus
      createdAt: DateTime.now(), // Sera remplacé par serverTimestamp
      channel: {
        'source': 'web',
        'email': {
          'sent': false,
          'error': null,
        },
      },
    );

    try {
      // Tentative de création (idempotente grâce à l'ID)
      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('orders')
          .doc(oid)
          .set(order.toMap());

      return oid;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Impossible de créer la commande. Vérifiez vos paramètres.');
      }
      rethrow;
    }
  }

  /// Stream des commandes d'un restaurant
  static Stream<List<models.Order>> getOrdersStream(String restaurantId) {
    // Utiliser models.Order
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('orders')
        .orderBy('created_at', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => models.Order.fromFirestore(doc))
          .toList(); // Utiliser models.Order
    });
  }

  /// Stream filtré par statut
  static Stream<List<models.Order>> getOrdersByStatusStream(
      String restaurantId, models.OrderStatus status) {
    // Utiliser models.
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('orders')
        .where('status', isEqualTo: status.name)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => models.Order.fromFirestore(doc))
          .toList(); // Utiliser models.Order
    });
  }

  /// Met à jour le statut d'une commande
  static Future<void> updateOrderStatus(
      String restaurantId, String orderId, models.OrderStatus newStatus) async {
    // Utiliser models.OrderStatus
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('orders')
        .doc(orderId)
        .update({
      'status': newStatus.name,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Supprime une commande (admin seulement)
  static Future<void> deleteOrder(String restaurantId, String orderId) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('orders')
        .doc(orderId)
        .delete();
  }

  // --- Méthodes utilitaires privées ---

  static double _calculateTotal(Map<String, int> itemQuantities,
      Map<String, List<Map<String, dynamic>>> menuData) {
    double total = 0.0;
    for (final entry in itemQuantities.entries) {
      final price = _getItemPrice(entry.key, menuData);
      total += price * entry.value;
    }
    return total;
  }

  static double _getItemPrice(
      String itemName, Map<String, List<Map<String, dynamic>>> menuData) {
    for (final categoryItems in menuData.values) {
      for (final item in categoryItems) {
        if (item['name'] == itemName) {
          return (item['price'] ?? 0).toDouble();
        }
      }
    }
    return 0.0;
  }
}
