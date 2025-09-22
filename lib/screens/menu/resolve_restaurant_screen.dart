import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'menu_screen.dart';
import '../home_screen.dart';

class ResolveRestaurantScreen extends StatelessWidget {
  final String idOrSlug;
  const ResolveRestaurantScreen({super.key, required this.idOrSlug});
  Future<String?> _resolve() async {
    final db = FirebaseFirestore.instance;

    final byId = await db.collection('restaurants').doc(idOrSlug).get();
    if (byId.exists) return idOrSlug;

    // Fallback : certains projets n'ont que /info/details
    final details = await db
        .collection('restaurants')
        .doc(idOrSlug)
        .collection('info')
        .doc('details')
        .get();
    if (details.exists) return idOrSlug;

    // Slug → RID
    final bySlug = await db.collection('slugs').doc(idOrSlug).get();
    if (bySlug.exists) {
      final rid = (bySlug.data()?['rid'] ?? '').toString();
      if (rid.isNotEmpty) return rid;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolve(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final rid = snap.data;
        if (rid == null || rid.isEmpty) {
          return HomeScreen(
            errorMessage:
                'Restaurant "$idOrSlug" introuvable. Vérifiez le code.',
          );
        }
        return MenuScreen(restaurantId: rid);
      },
    );
  }
}
