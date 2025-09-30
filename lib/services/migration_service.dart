import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationService {
  /// Migre les plats d'un restaurant vers la structure multilingue
  static Future<void> migrateRestaurantMenuItems(String restaurantId) async {
    print('🔄 Migration restaurant: $restaurantId');

    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menus')
        .get();

    int migrated = 0;
    int skipped = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Skip si déjà migré
      if (data.containsKey('translations')) {
        skipped++;
        continue;
      }

      final name = data['name']?.toString() ?? '';
      final description = data['description']?.toString() ?? '';

      await doc.reference.update({
        'translations': {
          'fr': {
            'name': name,
            'description': description,
          }
        },
        'translationStatus': {
          'he': 'missing',
          'en': 'missing',
          'fr': 'complete',
        },
        'updated_at': FieldValue.serverTimestamp(),
      });

      migrated++;
    }

    print('✅ Migration terminée: $migrated migrés, $skipped déjà faits');
  }

  /// Migre la config du restaurant pour ajouter defaultLocale
  static Future<void> migrateRestaurantConfig(String restaurantId) async {
    print('🔄 Migration config restaurant: $restaurantId');

    final docRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details');

    final doc = await docRef.get();
    final data = doc.data();

    if (data == null) {
      print('❌ Document details introuvable');
      return;
    }

    // Skip si déjà migré
    if (data.containsKey('defaultLocale')) {
      print('⏭️  Déjà migré');
      return;
    }

    await docRef.update({
      'defaultLocale': 'he',
      'enabledLocales': ['he', 'en', 'fr'],
      'updated_at': FieldValue.serverTimestamp(),
    });

    print('✅ Config migrée');
  }
}
