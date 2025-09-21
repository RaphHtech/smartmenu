import 'package:cloud_firestore/cloud_firestore.dart';

class SlugService {
  static final _db = FirebaseFirestore.instance;

  /// Transforme un nom en slug: "Crème & Pâtes" -> "creme-pates"
  static String normalize(String input) {
    var s = input.trim().toLowerCase();

    const from = 'àáâäãåçèéêëìíîïñòóôöõùúûüýÿœæ';
    const to = 'aaaaaaceeeeeiiiinoooooouuuuyyoeae';
    for (var i = 0; i < from.length; i++) {
      s = s.replaceAll(from[i], to[i]);
    }

    s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-'); // non alphanum -> -
    s = s.replaceAll(RegExp(r'-{2,}'), '-'); // -- -> -
    s = s.replaceAll(RegExp(r'^-|-$'), ''); // bords
    if (s.isEmpty) s = 'restaurant';
    return s;
  }

  /// Réserve un slug unique avec une transaction Firestore.
  /// Crée/claim un doc: slugs/{slug} => { rid: ... }
  static Future<String> claim(String desired, String rid) async {
    String candidate = desired;
    int i = 1;

    while (true) {
      final ref = _db.collection('slugs').doc(candidate);

      try {
        await _db.runTransaction((tx) async {
          final snap = await tx.get(ref);
          if (!snap.exists) {
            tx.set(ref, {
              'rid': rid,
              'created_at': FieldValue.serverTimestamp(),
            });
          } else {
            final existingRid = snap.data()?['rid'];
            if (existingRid != rid) {
              throw StateError('TAKEN');
            }
          }
        });
        return candidate; // réservé
      } catch (_) {
        i += 1;
        candidate = '$desired-$i'; // essaie next: "-2", "-3", ...
      }
    }
  }
}
