import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { received, preparing, ready, served }

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
    );
  }
}

class Order {
  final String oid;
  final String rid;
  final String table;
  final List<OrderItem> items;
  final double total;
  final String currency;
  final OrderStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> channel;

  Order({
    required this.oid,
    required this.rid,
    required this.table,
    required this.items,
    required this.total,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.channel,
  });

  Map<String, dynamic> toMap() {
    return {
      'oid': oid,
      'rid': rid,
      'table': table,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'currency': currency,
      'status': status.name,
      'created_at': FieldValue.serverTimestamp(),
      'channel': channel,
    };
  }

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      oid: doc.id,
      rid: data['rid'] ?? '',
      table: data['table'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'ILS',
      status: OrderStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => OrderStatus.received,
      ),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      channel: data['channel'] ?? {},
    );
  }

  Order copyWith({
    OrderStatus? status,
    Map<String, dynamic>? channel,
  }) {
    return Order(
      oid: oid,
      rid: rid,
      table: table,
      items: items,
      total: total,
      currency: currency,
      status: status ?? this.status,
      createdAt: createdAt,
      channel: channel ?? this.channel,
    );
  }
}
