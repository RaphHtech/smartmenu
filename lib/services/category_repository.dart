import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/category.dart';

class CategoryManager {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream unifié des infos restaurant
  static Stream<Map<String, dynamic>> getRestaurantInfoStream(
      String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details')
        .snapshots()
        .map((snap) => snap.data() ?? {});
  }

  // Stream des plats pour compter par catégorie
  static Stream<Map<String, int>> getCategoryCountsStream(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .snapshots()
        .map((snapshot) {
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final category = (data['category'] ?? '').toString().trim();
        if (category.isNotEmpty) {
          counts[category] = (counts[category] ?? 0) + 1;
        }
      }
      return counts;
    });
  }

  static Stream<CategoryLiveState> getLiveState(String restaurantId) {
    return CombineLatestStream.combine2(
      getRestaurantInfoStream(restaurantId),
      getCategoryCountsStream(restaurantId),
      (Map<String, dynamic> info, Map<String, int> counts) => CategoryLiveState(
        order: List<String>.from(info['categoriesOrder'] ?? []),
        hidden: Set<String>.from(info['categoriesHidden'] ?? []),
        counts: counts,
      ),
    );
  }

  // Réorganiser les catégories
  static Future<void> reorderCategories(
      String restaurantId, List<String> newOrder) async {
    await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details')
        .update({
      'categoriesOrder': newOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Toggle visibilité
  static Future<void> toggleCategoryVisibility(
      String restaurantId, String category) async {
    final doc = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = doc.data() ?? {};
    final hidden = Set<String>.from(data['categoriesHidden'] ?? []);

    if (hidden.contains(category)) {
      hidden.remove(category);
    } else {
      hidden.add(category);
    }

    await doc.reference.update({
      'categoriesHidden': hidden.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Renommer une catégorie avec gestion de fusion
  static Future<void> renameCategory(
      String restaurantId, String oldName, String newName,
      {bool forceMerge = false}) async {
    if (oldName == newName) return;

    final batch = _db.batch();

    // Vérifier si la nouvelle catégorie existe déjà
    final menuSnapshot = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .where('category', isEqualTo: newName)
        .limit(1)
        .get();

    if (menuSnapshot.docs.isNotEmpty && !forceMerge) {
      throw Exception('MERGE_REQUIRED');
    }

    // Mettre à jour tous les plats
    final itemsToUpdate = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .where('category', isEqualTo: oldName)
        .get();

    for (final doc in itemsToUpdate.docs) {
      batch.update(doc.reference, {'category': newName});
    }

    // Mettre à jour l'ordre des catégories
    final infoDoc = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = infoDoc.data() ?? {};
    final order = List<String>.from(data['categoriesOrder'] ?? []);
    final hidden = Set<String>.from(data['categoriesHidden'] ?? []);

    final oldIndex = order.indexOf(oldName);
    if (oldIndex >= 0) {
      order[oldIndex] = newName;
    }

    if (hidden.contains(oldName)) {
      hidden.remove(oldName);
      hidden.add(newName);
    }

    batch.update(infoDoc.reference, {
      'categoriesOrder': order,
      'categoriesHidden': hidden.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Ajouter une nouvelle catégorie
  static Future<void> addCategory(
      String restaurantId, String categoryName) async {
    final infoRef = _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details');

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(infoRef);
      final data = doc.data() ?? {};
      final order = List<String>.from(data['categoriesOrder'] ?? []);

      if (!order.contains(categoryName)) {
        order.add(categoryName);
        transaction.update(infoRef, {
          'categoriesOrder': order,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Supprimer une catégorie (seulement si vide)
  static Future<void> deleteCategory(
      String restaurantId, String category) async {
    // Vérifier que la catégorie est vide
    final itemsCount = await _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .where('category', isEqualTo: category)
        .limit(1)
        .get();

    if (itemsCount.docs.isNotEmpty) {
      throw Exception('CATEGORY_NOT_EMPTY');
    }

    final infoRef = _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details');

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(infoRef);
      final data = doc.data() ?? {};
      final order = List<String>.from(data['categoriesOrder'] ?? []);
      final hidden = Set<String>.from(data['categoriesHidden'] ?? []);

      order.remove(category);
      hidden.remove(category);

      transaction.update(infoRef, {
        'categoriesOrder': order,
        'categoriesHidden': hidden.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
