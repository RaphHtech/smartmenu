import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseMenuService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Récupérer les items du menu pour un restaurant - correspond à la structure Firebase
  static Future<List<Map<String, dynamic>>> getMenuItems(
      String restaurantId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('restaurant')
          .doc(restaurantId)
          .collection('menus')
          .get();

      List<Map<String, dynamic>> items = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['signature'] = (data['signature'] == true) ||
            (data['hasSignature'] == true); // bool sûr
        data['category'] =
            (data['category'] ?? '').toString().toLowerCase(); // nettoyé
// IMPORTANT : ne pas mettre encore le symbole '₪' ici — on formatera dans organizeByCategory

        items.add(data);
      }

      return items;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du menu: $e');
      return [];
    }
  }

  // Récupérer les informations d'un restaurant
  static Future<Map<String, dynamic>?> getRestaurant(
      String restaurantId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('restaurant').doc(restaurantId).get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du restaurant: $e');
      return null;
    }
  }

  // Organiser les items par catégorie (comme votre ancien menu_data.dart)
  static Map<String, List<Map<String, dynamic>>> organizeByCategory(
      List<Map<String, dynamic>> items) {
    Map<String, List<Map<String, dynamic>>> organized = {};

    for (var item in items) {
      String category = (item['category'] ?? '').toString().trim();
      if (category.isEmpty) category = 'Autres';

      // Correspondances spécifiques
      switch (category.toLowerCase()) {
        case 'pizza':
        case 'pizzas':
          category = 'Pizzas';
          break;
        case 'salade':
        case 'salades':
        case 'entrée':
        case 'entree':
        case 'entrées':
        case 'entrees':
          category = 'Entrées';
          break;
        default:
          category = category.isEmpty
              ? 'Autres'
              : '${category[0].toUpperCase()}${category.substring(1)}s';
      }

      if (!organized.containsKey(category)) {
        organized[category] = [];
      }

      final priceRaw = item['price'];
      final String priceStr = priceRaw is num
          ? '₪${priceRaw.toStringAsFixed(2)}'
          : (priceRaw?.toString().contains('₪') == true
              ? priceRaw.toString()
              : '₪${priceRaw ?? '0'}');

      organized[category]!.add({
        'id': item['id'] ?? '',
        'name': item['name'] ?? '',
        'price': priceStr,
        'description': item['description'] ?? '',
        'signature': item['signature'] == true,
        'order': (item['order'] is num) ? (item['order'] as num).toInt() : 0,
      });
    }

    for (final key in organized.keys) {
      organized[key]!.sort((a, b) {
        final ao = (a['order'] is num) ? (a['order'] as num).toInt() : 0;
        final bo = (b['order'] is num) ? (b['order'] as num).toInt() : 0;

        if (ao != bo) return ao.compareTo(bo);
        return (a['name'] as String).compareTo(b['name'] as String);
      });
    }

    return organized;
  }
}
