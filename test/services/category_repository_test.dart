import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:smartmenu_app/models/category.dart';
import 'package:smartmenu_app/services/category_repository.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  const testRestaurantId = 'test-restaurant';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    CategoryManager.setFirestoreInstance(fakeFirestore);
  });

  tearDown(() {});

  group('CategoryLiveState', () {
    test('should create with default values', () {
      final state = CategoryLiveState(
        order: ['Pizzas', 'Entrées'],
        hidden: {'Desserts'},
        counts: {'Pizzas': 5, 'Entrées': 3},
      );

      expect(state.order.length, 2);
      expect(state.hidden.contains('Desserts'), true);
      expect(state.counts['Pizzas'], 5);
    });
  });

  group('CategoryManager - addCategory', () {
    test('should add new category to order', () async {
      // Setup - créer le document d'abord
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({'categoriesOrder': []});

      await CategoryManager.addCategory(testRestaurantId, 'Boissons');

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final data = doc.data()!;
      final order = List<String>.from(data['categoriesOrder']);
      expect(order.contains('Boissons'), true);
    });

    test('should not add duplicate category', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({'categoriesOrder': []});

      // Ajouter une première fois
      await CategoryManager.addCategory(testRestaurantId, 'Pizzas');
      await CategoryManager.addCategory(testRestaurantId, 'Pizzas');

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final order = List<String>.from(doc.data()!['categoriesOrder']);
      final pizzaCount = order.where((cat) => cat == 'Pizzas').length;
      expect(pizzaCount, 1);
    });
  });

  group('CategoryManager - reorderCategories', () {
    test('should update category order', () async {
      // Setup initial order
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({
        'categoriesOrder': ['A', 'B', 'C']
      });

      // Reorder
      await CategoryManager.reorderCategories(
          testRestaurantId, ['C', 'A', 'B']);

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final order = List<String>.from(doc.data()!['categoriesOrder']);
      expect(order, ['C', 'A', 'B']);
    });
  });

  group('CategoryManager - toggleCategoryVisibility', () {
    test('should hide visible category', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({'categoriesHidden': []});

      // Toggle
      await CategoryManager.toggleCategoryVisibility(
          testRestaurantId, 'Pizzas');

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final hidden = List<String>.from(doc.data()!['categoriesHidden']);
      expect(hidden.contains('Pizzas'), true);
    });

    test('should show hidden category', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({
        'categoriesHidden': ['Pizzas']
      });

      // Toggle
      await CategoryManager.toggleCategoryVisibility(
          testRestaurantId, 'Pizzas');

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final hidden = List<String>.from(doc.data()!['categoriesHidden']);
      expect(hidden.contains('Pizzas'), false);
    });
  });
  group('CategoryManager - deleteCategory', () {
    test('should delete empty category', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({
        'categoriesOrder': ['Pizzas', 'Boissons'],
        'categoriesHidden': ['Boissons']
      });

      await CategoryManager.deleteCategory(testRestaurantId, 'Boissons');

      final doc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final data = doc.data()!;
      final order = List<String>.from(data['categoriesOrder']);
      final hidden = List<String>.from(data['categoriesHidden']);

      expect(order.contains('Boissons'), false);
      expect(hidden.contains('Boissons'), false);
    });

    test('should throw error for non-empty category', () async {
      // Setup - catégorie avec plats
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('menus')
          .add({'category': 'Pizzas', 'name': 'Margherita'});

      expect(
        () => CategoryManager.deleteCategory(testRestaurantId, 'Pizzas'),
        throwsException,
      );
    });
  });

  group('CategoryManager - renameCategory', () {
    test('should rename category and update items', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .set({
        'categoriesOrder': ['Pizzas', 'Entrées'],
        'categoriesHidden': ['Pizzas']
      });

      await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('menus')
          .add({'category': 'Pizzas', 'name': 'Margherita'});

      await CategoryManager.renameCategory(testRestaurantId, 'Pizzas', 'Pizza');

      // Vérifier ordre mis à jour
      final infoDoc = await fakeFirestore
          .collection('restaurants')
          .doc(testRestaurantId)
          .collection('info')
          .doc('details')
          .get();

      final order = List<String>.from(infoDoc.data()!['categoriesOrder']);
      final hidden = List<String>.from(infoDoc.data()!['categoriesHidden']);

      expect(order.contains('Pizza'), true);
      expect(order.contains('Pizzas'), false);
      expect(hidden.contains('Pizza'), true);
    });
  });
}
