import 'package:cloud_firestore/cloud_firestore.dart';

class ServerCall {
  final String id;
  final String table;
  final String status;
  final DateTime createdAt;
  final DateTime? ackedAt;
  final DateTime? closedAt;

  ServerCall({
    required this.id,
    required this.table,
    required this.status,
    required this.createdAt,
    this.ackedAt,
    this.closedAt,
  });

  factory ServerCall.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServerCall(
      id: doc.id,
      table: data['table'] ?? 'table1',
      status: data['status'] ?? 'open',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ackedAt: (data['acked_at'] as Timestamp?)?.toDate(),
      closedAt: (data['closed_at'] as Timestamp?)?.toDate(),
    );
  }
}

class ServerCallService {
  static final _db = FirebaseFirestore.instance;
  static final Map<String, DateTime> _lastCallPerTable = {};
  static const _cooldown = Duration(seconds: 45);

  static Future<void> callServer({
    required String rid,
    required String table,
  }) async {
    // Cooldown côté client
    final key = '$rid|$table';
    final now = DateTime.now();
    final last = _lastCallPerTable[key];

    if (last != null && now.difference(last) < _cooldown) {
      throw 'Veuillez attendre ${_cooldown.inSeconds}s entre les appels';
    }

    // Vérifier s'il y a déjà un appel ouvert pour cette table
    final existingCall = await _db
        .collection('restaurants')
        .doc(rid)
        .collection('server_calls')
        .where('table', isEqualTo: table)
        .where('status', whereIn: ['open', 'acked'])
        .limit(1)
        .get();

    if (existingCall.docs.isNotEmpty) {
      throw 'Un appel serveur est déjà en cours pour votre table';
    }

    // Créer l'appel serveur
    await _db
        .collection('restaurants')
        .doc(rid)
        .collection('server_calls')
        .add({
      'rid': rid,
      'table': table,
      'status': 'open',
      'created_at': FieldValue.serverTimestamp(),
      'repeat': 0,
    });

    _lastCallPerTable[key] = now;
  }

  static Stream<List<ServerCall>> getServerCalls(String rid) {
    return _db
        .collection('restaurants')
        .doc(rid)
        .collection('server_calls')
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ServerCall.fromDoc(doc)).toList());
  }

  static Future<void> acknowledgeCall(String rid, String callId) async {
    await _db
        .collection('restaurants')
        .doc(rid)
        .collection('server_calls')
        .doc(callId)
        .update({
      'status': 'acked',
      'acked_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> closeCall(String rid, String callId) async {
    await _db
        .collection('restaurants')
        .doc(rid)
        .collection('server_calls')
        .doc(callId)
        .update({
      'status': 'done',
      'closed_at': FieldValue.serverTimestamp(),
    });
  }
}
