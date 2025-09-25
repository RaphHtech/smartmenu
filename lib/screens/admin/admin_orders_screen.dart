import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmenu_app/models/order.dart' as models;
import 'package:smartmenu_app/services/order_service.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/server_call_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  final String restaurantId;

  const AdminOrdersScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<models.OrderStatus> _statusTabs = [
    models.OrderStatus.received,
    models.OrderStatus.preparing,
    models.OrderStatus.ready,
    models.OrderStatus.served,
  ];

  StreamSubscription<QuerySnapshot>? _ordersSub;
  String? _lastSeenOrderId;
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);

    if (kIsWeb) _requestNotificationPermission();

    // Écoute des NOUVELLES commandes reçues
    _ordersSub = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('orders')
        .where('status', isEqualTo: 'received')
        .orderBy('created_at', descending: true)
        .limit(1)
        .snapshots()
        .listen((snap) {
      if (snap.docs.isEmpty) return;

      final doc = snap.docs.first;
      final id = doc.id;

      // Premier passage : mémoriser sans alerter
      if (!_bootstrapped) {
        _bootstrapped = true;
        _lastSeenOrderId = id;
        return;
      }

      // Nouvelle commande détectée
      if (_lastSeenOrderId != id) {
        _lastSeenOrderId = id;

        final data = doc.data() as Map<String, dynamic>;
        final table =
            (data['table'] ?? 'table?').toString().replaceFirst('table', '');
        final items = (data['items'] as List? ?? []).length;
        final total = (data['total'] ?? 0).toString();
        final currency = (data['currency'] ?? '').toString();

        _playDing();
        _notifyDesktop('Nouvelle commande',
            'Table $table · $items item(s) · $total $currency');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ordersSub?.cancel();
    super.dispose();
  }

  String _getStatusLabel(models.OrderStatus status) {
    switch (status) {
      case models.OrderStatus.received:
        return 'Reçues';
      case models.OrderStatus.preparing:
        return 'Préparation';
      case models.OrderStatus.ready:
        return 'Prêtes';
      case models.OrderStatus.served:
        return 'Servies';
    }
  }

  Color _getStatusColor(models.OrderStatus status) {
    switch (status) {
      case models.OrderStatus.received:
        return AdminTokens.warning500;
      case models.OrderStatus.preparing:
        return AdminTokens.primary600;
      case models.OrderStatus.ready:
        return AdminTokens.success500;
      case models.OrderStatus.served:
        return AdminTokens.neutral500;
    }
  }

  Widget _buildServerCallsBanner() {
    return StreamBuilder<List<ServerCall>>(
      stream: ServerCallService.getServerCalls(widget.restaurantId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final openCalls = snapshot.data!
            .where((call) => call.status == 'open' || call.status == 'acked')
            .toList();

        if (openCalls.isEmpty) return const SizedBox.shrink();

        // Jouer le son pour les nouveaux appels
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNewServerCalls(openCalls);
        });

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.support_agent,
                      color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Appels serveur (${openCalls.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...openCalls.map((call) => _buildServerCallCard(call)),
            ],
          ),
        );
      },
    );
  }

// Dans admin_orders_screen.dart, remplacer la méthode _buildServerCallCard par :

  Widget _buildServerCallCard(ServerCall call) {
    final elapsed = DateTime.now().difference(call.createdAt);
    final timeAgo = elapsed.inMinutes > 0
        ? 'il y a ${elapsed.inMinutes}min'
        : 'à l\'instant';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: call.status == 'open' ? Colors.orange : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne infos avec point de statut
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: call.status == 'open' ? Colors.orange : Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${call.table} • $timeAgo',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Boutons d'action sur mobile - stack vertical sur petits écrans
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 400) {
                // Mobile : boutons empilés
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (call.status == 'open')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () => _acknowledgeServerCall(call.id),
                          child: const Text('Pris en compte'),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () => _resolveServerCall(call.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Résolu',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              } else {
                // Desktop : boutons côte à côte
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (call.status == 'open')
                      TextButton(
                        onPressed: () => _acknowledgeServerCall(call.id),
                        child: const Text('Pris en compte',
                            style: TextStyle(fontSize: 12)),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _resolveServerCall(call.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                      child: const Text('Résolu',
                          style: TextStyle(fontSize: 12, color: Colors.white)),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  } // 4. AJOUTER les méthodes d'action

  Future<void> _acknowledgeServerCall(String callId) async {
    try {
      await ServerCallService.acknowledgeCall(widget.restaurantId, callId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resolveServerCall(String callId) async {
    try {
      await ServerCallService.closeCall(widget.restaurantId, callId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

// 5. AJOUTER la gestion des nouveaux appels (son)
  final Set<String> _seenServerCalls = {};

  void _handleNewServerCalls(List<ServerCall> calls) {
    if (!kIsWeb) return;

    for (final call in calls) {
      if (call.status == 'open' && !_seenServerCalls.contains(call.id)) {
        _seenServerCalls.add(call.id);
        _playServerCallSound();
        _notifyServerCall(call.table);
        break; // Un seul son même pour plusieurs appels
      }
    }
  }

  void _playServerCallSound() {
    try {
      // Son différent des commandes
      html.AudioElement('assets/sounds/server_call.mp3')..play();
    } catch (e) {
      debugPrint('Erreur son serveur: $e');
    }
  }

  void _notifyServerCall(String table) {
    if (html.Notification.supported &&
        html.Notification.permission == 'granted') {
      html.Notification(
        'Appel serveur - SmartMenu',
        body: '$table demande de l\'assistance',
        icon: '/favicon.png',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 420;

    return AdminShell(
      title: 'Commandes',
      restaurantId: widget.restaurantId,
      activeRoute: '/orders',
      breadcrumbs: const ['Dashboard', 'Commandes'],
      child: Column(
        children: [
          _buildServerCallsBanner(),
          // Onglets
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: AdminTokens.neutral200),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AdminTokens.primary600,
                unselectedLabelColor: AdminTokens.neutral600,
                indicatorColor: AdminTokens.primary600,
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  _statusTab(isCompact ? 'Reçues' : 'Reçues',
                      models.OrderStatus.received),
                  _statusTab(isCompact ? 'Prépa.' : 'Préparation',
                      models.OrderStatus.preparing),
                  _statusTab(isCompact ? 'Prêtes' : 'Prêtes',
                      models.OrderStatus.ready),
                  _statusTab(isCompact ? 'Servies' : 'Servies',
                      models.OrderStatus.served),
                ],
              ),
            ),
          ),

          const SizedBox(height: AdminTokens.space24),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((status) {
                return _buildOrdersList(status);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(models.OrderStatus status) {
    return StreamBuilder<List<models.Order>>(
      stream: OrderService.getOrdersByStatusStream(widget.restaurantId, status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erreur: ${snapshot.error}',
              style: AdminTypography.bodyMedium.copyWith(
                color: AdminTokens.error500,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;

        if (status == models.OrderStatus.received && orders.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleNewOrders(orders);
          });
        }

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  size: 64,
                  color: AdminTokens.neutral300,
                ),
                const SizedBox(height: AdminTokens.space16),
                Text(
                  'Aucune commande ${_getStatusLabel(status).toLowerCase()}',
                  style: AdminTypography.bodyLarge.copyWith(
                    color: AdminTokens.neutral500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AdminTokens.space16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index]);
          },
        );
      },
    );
  }

  void _handleNewOrders(List<models.Order> orders) async {
    if (!kIsWeb) return;

    // Son d'alerte
    try {
      html.AudioElement('/assets/sounds/new_order.mp3')..play();
    } catch (e) {
      debugPrint('Erreur son: $e');
    }

    // Notification bureau
    if (html.Notification.supported) {
      if (html.Notification.permission != 'granted') {
        await html.Notification.requestPermission();
      }

      if (html.Notification.permission == 'granted') {
        final latestOrder = orders.first;
        html.Notification(
          'Nouvelle commande SmartMenu',
          body:
              '${latestOrder.table} • ${latestOrder.items.length} items • ${latestOrder.total.toStringAsFixed(0)} ₪',
          icon: '/favicon.png',
        );
      }
    }
  }

  Widget _buildOrderCard(models.Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: AdminTokens.space16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radius8),
        side: const BorderSide(color: AdminTokens.neutral200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Commande #${order.oid.substring(0, 8)}',
                  style: AdminTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AdminTokens.space8,
                    vertical: AdminTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AdminTokens.radius4),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: AdminTypography.labelSmall.copyWith(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AdminTokens.space12),

            // Infos commande
            Row(
              children: [
                const Icon(
                  Icons.table_restaurant,
                  size: AdminTokens.iconSm,
                  color: AdminTokens.neutral500,
                ),
                const SizedBox(width: AdminTokens.space4),
                Text(
                  order.table,
                  style: AdminTypography.bodySmall.copyWith(
                    color: AdminTokens.neutral600,
                  ),
                ),
                const SizedBox(width: AdminTokens.space16),
                const Icon(
                  Icons.schedule,
                  size: AdminTokens.iconSm,
                  color: AdminTokens.neutral500,
                ),
                const SizedBox(width: AdminTokens.space4),
                Text(
                  '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                  style: AdminTypography.bodySmall.copyWith(
                    color: AdminTokens.neutral600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${order.total.toStringAsFixed(0)} ₪',
                  style: AdminTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AdminTokens.primary600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AdminTokens.space12),
            ...order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AdminTokens.space4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AdminTokens.neutral100,
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius4),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: AdminTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AdminTokens.space8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: AdminTypography.bodySmall,
                        // ← AJOUTER CES LIGNES POUR FIXER L'OVERFLOW :
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Text(
                      '${(item.price * item.quantity).toStringAsFixed(0)} ₪',
                      style: AdminTypography.bodySmall.copyWith(
                        color: AdminTokens.neutral600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: AdminTokens.space16),

            // Actions
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderActions(models.Order order) {
    final List<models.OrderStatus> nextStatuses = [];

    switch (order.status) {
      case models.OrderStatus.received:
        nextStatuses.add(models.OrderStatus.preparing);
        break;
      case models.OrderStatus.preparing:
        nextStatuses.add(models.OrderStatus.ready);
        break;
      case models.OrderStatus.ready:
        nextStatuses.add(models.OrderStatus.served);
        break;
      case models.OrderStatus.served:
        // Aucune action suivante
        break;
    }

    return Row(
      children: [
        // Actions de changement de statut
        ...nextStatuses.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: AdminTokens.space8),
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(order, status),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(status),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: AdminTokens.space16,
                  vertical: AdminTokens.space8,
                ),
              ),
              child: Text(_getStatusLabel(status)),
            ),
          );
        }).toList(),

        const Spacer(),

        // Action suppression (servies uniquement)
        if (order.status == models.OrderStatus.served)
          IconButton(
            onPressed: () => _deleteOrder(order),
            icon: const Icon(Icons.delete_outline),
            color: AdminTokens.error500,
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  Future<void> _updateOrderStatus(
      models.Order order, models.OrderStatus newStatus) async {
    try {
      await OrderService.updateOrderStatus(
          widget.restaurantId, order.oid, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Commande mise à jour: ${_getStatusLabel(newStatus)}'),
            backgroundColor: AdminTokens.success500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AdminTokens.error500,
          ),
        );
      }
    }
  }

  Future<void> _deleteOrder(models.Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: Text(
            'Voulez-vous vraiment supprimer la commande #${order.oid.substring(0, 8)} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AdminTokens.error500),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await OrderService.deleteOrder(widget.restaurantId, order.oid);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande supprimée'),
              backgroundColor: AdminTokens.success500,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AdminTokens.error500,
            ),
          );
        }
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!kIsWeb) return;
    if (!html.Notification.supported) return;
    if (html.Notification.permission != 'granted') {
      await html.Notification.requestPermission();
    }
  }

  void _playDing() {
    if (!kIsWeb) return;
    try {
      final audio = html.AudioElement('assets/sounds/new_order.mp3');
      audio.play();
    } catch (_) {}
  }

  void _notifyDesktop(String title, String body) {
    if (!kIsWeb) return;
    if (!html.Notification.supported) return;
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }

  Widget _statusTab(String label, models.OrderStatus status) {
    return StreamBuilder<List<models.Order>>(
      stream: OrderService.getOrdersByStatusStream(widget.restaurantId, status),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;

        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, softWrap: false, overflow: TextOverflow.fade),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
