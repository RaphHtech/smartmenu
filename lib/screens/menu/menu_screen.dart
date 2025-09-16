import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmenu_app/services/analytics_service.dart';
import 'package:smartmenu_app/services/table_service.dart';
import '../../core/constants/colors.dart';
import '../../widgets/category_pill_widget.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/modals/order_review_modal.dart';
import '../../widgets/notifications/custom_notification.dart';
import '../../widgets/menu/cart_floating_widget.dart';
import '../../services/cart_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../../widgets/premium_app_header_widget.dart';

List<String> applyOrderAndHide(
  Set<String> allCats,
  List<String> order,
  Set<String> hidden,
) {
  final visible = allCats.where((c) => !hidden.contains(c)).toSet();
  final rest = visible.where((c) => !order.contains(c)).toList()..sort();
  return [...order.where(visible.contains), ...rest];
}

int weightFor(String cat, List<String> order) {
  final i = order.indexOf(cat);
  return i >= 0 ? i : 1000;
}

class MenuScreen extends StatefulWidget {
  final String restaurantId;

  const MenuScreen({super.key, this.restaurantId = 'chez-milano'});

  @override
  State<MenuScreen> createState() => SimpleMenuScreenState();
}

class SimpleMenuScreenState extends State<MenuScreen> {
  bool _isLoading = true; // État initial : en chargement
  int _cartItemCount = 0;
  double _cartTotal = 0.0;
  bool _isAdminPreview = false;
  String _selectedCategory = '';
  final ScrollController _categoryScrollController = ScrollController();
  Map<String, int> itemQuantities = {};
  bool _showOrderModal = false;
  bool _promoEnabled = true;
  String _restaurantName = '';
  String _logoUrl = '';
  String _restaurantCurrency = 'ILS'; // <-- règle l'erreur "undefined name"
  String _tagline = ''; // sous-titre (catch phrase)
  String _promoText = ''; // bandeau promo
  Map<String, List<Map<String, dynamic>>> _menuData = {};
  List<String> _categoriesOrder = [];
  Set<String> _categoriesHidden = {};
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  String _emojiFor(String cat) {
    switch (cat) {
      case 'Pizzas':
        return '🍕';
      case 'Entrées':
        return '🥗';
      case 'Pâtes':
        return '🍝';
      case 'Desserts':
        return '🍰';
      case 'Boissons':
        return '🍹';
      default:
        return '⭐';
    }
  }

  String _symbolFor(String code) {
    switch (code) {
      case 'ILS':
        return '₪';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return code; // fallback: affiche 'GBP', 'CAD', etc.
    }
  }

// --- Fetch direct depuis Firestore ---
  Future<List<Map<String, dynamic>>> _fetchMenuItems(String rid) async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(rid)
        .collection('menus')
        .where('visible', isEqualTo: true)
        .orderBy('order')
        .orderBy('name')
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return data;
    }).toList();
  }

// --- Groupage par catégorie + tri par nom ---
  Map<String, List<Map<String, dynamic>>> _groupByCategory(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> out = {};
    for (final it in items) {
      final cat = (it['category'] ?? 'Autres').toString();
      (out[cat] ??= []).add(it);
    }

    return out;
  }

  @override
  void initState() {
    super.initState();
    final qp = Uri.base.queryParameters;
    _isAdminPreview = qp.containsKey('preview') || qp.containsKey('admin');
    String? tableId = qp['t'] ?? qp['table'];
    if (tableId != null) {
      // Nettoyer le format (accepter "table12" → "12")
      tableId = tableId.replaceFirst(RegExp(r'^table'), '');
      TableService.setTableId(tableId);
    }

    _loadMenuFromFirebase();
    _loadRestaurantDetails();
    // Log menu open
    AnalyticsService.logMenuOpen(widget.restaurantId,
        tableId: TableService.getTableId());
    _mainScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_handleScroll);
    _mainScrollController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantDetails() async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = snap.data() ?? {};
    if (!mounted) return;
    setState(() {
      _restaurantName = (data['name'] ?? '').toString();
      _restaurantCurrency = (data['currency'] ?? 'ILS').toString();
      _tagline = (data['tagline'] ?? '').toString().trim();
      _promoText = (data['promo_text'] ?? '').toString().trim();
      _promoEnabled = (data['promo_enabled'] as bool?) ?? true;
      _logoUrl = (data['logoUrl'] ?? '').toString();
      _categoriesOrder = List<String>.from(data['categoriesOrder'] ?? []);
      _categoriesHidden = Set<String>.from(data['categoriesHidden'] ?? []);

      if (_menuData.isNotEmpty &&
          (_selectedCategory.isEmpty || _selectedCategory == 'Boissons')) {
        final allCats = _menuData.keys.toSet();
        allCats.addAll(_categoriesOrder);
        final orderedCats =
            applyOrderAndHide(allCats, _categoriesOrder, _categoriesHidden);
        if (orderedCats.isNotEmpty) {
          _selectedCategory = orderedCats.first;
        }
      }
    });
  }

  void _loadMenuFromFirebase() async {
    setState(() => _isLoading = true);

    // résout l'id effectif
    final String rid = () {
      final q = Uri.base.queryParameters['rid'];
      if (q != null && q.isNotEmpty) return q;
      return widget.restaurantId;
    }();

    final items = await _fetchMenuItems(rid);
    final organized = _groupByCategory(items);

    setState(() {
      _menuData = organized;
      _isLoading = false;
    });
  }

  void addToCart(String itemName, double price) {
    setState(() {
      if (itemQuantities.containsKey(itemName)) {
        itemQuantities[itemName] = itemQuantities[itemName]! + 1;
      } else {
        itemQuantities[itemName] = 1;
      }
      _cartItemCount++;
      _cartTotal += price;
    });

    // Log add to cart (UNE SEULE LIGNE)
    AnalyticsService.logAddToCart(widget.restaurantId, itemName,
        tableId: TableService.getTableId());

    // Animation visuelle (optionnel)
    _showCustomNotification('✅ $itemName ajouté au panier !');
  }

  void setItemQuantity(String itemName, double price, int newQuantity) {
    setState(() {
      final currentQuantity = itemQuantities[itemName] ?? 0;
      final quantityDiff = newQuantity - currentQuantity;

      if (newQuantity == 0) {
        itemQuantities.remove(itemName);
      } else {
        itemQuantities[itemName] = newQuantity;
      }

      _cartItemCount += quantityDiff;
      _cartTotal += (price * quantityDiff);
    });

    final currentQuantity =
        itemQuantities[itemName] ?? 0; // Redéfini ici pour la comparaison
    if (newQuantity > currentQuantity) {
      _showCustomNotification('✅ $itemName ajouté au panier !');
    }
  }

  void increaseQuantity(String itemName, double price) {
    setState(() {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + 1;
      _cartItemCount++;
      _cartTotal += price;
    });
  }

  void decreaseQuantity(String itemName, double price) {
    setState(() {
      int currentQty = itemQuantities[itemName] ?? 0;
      if (currentQty > 1) {
        itemQuantities[itemName] = currentQty - 1;
        _cartItemCount--;
        _cartTotal -= price;
      } else {
        itemQuantities.remove(itemName);
        _cartItemCount--;
        _cartTotal -= price;
      }
    });
  }

  void _showCustomNotification(String message, {bool persistent = false}) {
    CustomNotificationService.show(
      context,
      message,
      persistent: persistent,
      onClose: persistent
          ? () {
              setState(() {
                _showOrderModal = false;
              });
            }
          : null,
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });

    // Post-frame pour éviter double animateTo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoryScrollController.hasClients && mounted) {
        final allCats = _menuData.keys.toSet();
        allCats.addAll(_categoriesOrder);
        final orderedCategories =
            applyOrderAndHide(allCats, _categoriesOrder, _categoriesHidden);
        final selectedIndex = orderedCategories.indexOf(category);

        if (selectedIndex >= 0) {
          const pillWidth = 120.0;
          final targetPosition = selectedIndex * pillWidth;
          final maxScroll = _categoryScrollController.position.maxScrollExtent;

          _categoryScrollController.animateTo(
            (targetPosition - 60).clamp(0.0, maxScroll),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  void _showOrderReview() {
    if (_cartItemCount == 0) {
      _showCustomNotification('🛒 Votre panier est vide !');
      return;
    }
    setState(() {
      _showOrderModal = true;
    });
  }

  void _closeOrderReview() {
    setState(() {
      _showOrderModal = false;
    });
  }

  void _confirmOrder() {
    String orderSummary =
        CartService.buildOrderSummary(itemQuantities, _menuData);
    _showCustomNotification(orderSummary, persistent: true);
  }

  double _getItemPrice(String itemName) {
    return CartService.getItemPrice(itemName, _menuData);
  }

  void _handleAdminReturn(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }
    if (kIsWeb) {
      try {
        html.window.close();
      } catch (_) {
        final returnUrl = Uri.base.queryParameters['return'] ?? '/admin';
        html.window.location.assign(returnUrl);
      }
    }
  }

  void _handleScroll() {
    final offset = _mainScrollController.offset;
    final shouldCollapse = _isHeaderCollapsed ? offset > 32 : offset > 72;

    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = shouldCollapse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) Fond diagonal (135°)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.bgGradientWarm,
            ),
          ),
        ),

        // 2) Voile global léger
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.pageOverlay),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ===== HEADER (en dur) =====
                PremiumAppHeaderWidget(
                  tagline: _tagline,
                  onServerCall: () {
                    _showCustomNotification(
                      'Appel du serveur...\nUn membre de notre équipe arrive à votre table !',
                    );
                  },
                  restaurantName:
                      _restaurantName, // Pas de .toUpperCase() (fait dans le widget)
                  showAdminReturn: _isAdminPreview,
                  onAdminReturn: _isAdminPreview
                      ? () => _handleAdminReturn(context)
                      : null,
                  logoUrl: _logoUrl,
                ),

                // ===== SECTION PROMO (glassmorphism) =====
                SliverToBoxAdapter(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: (_promoEnabled &&
                            _promoText.isNotEmpty &&
                            !_isHeaderCollapsed)
                        ? null
                        : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _isHeaderCollapsed ? 0 : 1,
                      child: (_promoEnabled && _promoText.isNotEmpty)
                          ? Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0x26F59E0B),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0x33F59E0B)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer,
                                      size: 18, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _promoText,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ===== NAVIGATION CATÉGORIES =====
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      boxShadow: _isHeaderCollapsed
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(88),
                    child: Container(
                      height: 88,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SingleChildScrollView(
                        controller: _categoryScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              for (final cat in () {
                                final allCats = _menuData.keys.toSet();
                                allCats.addAll(_categoriesOrder);
                                return applyOrderAndHide(allCats,
                                    _categoriesOrder, _categoriesHidden);
                              }())
                                Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CategoryPill(
                                    label: '${_emojiFor(cat)} $cat',
                                    isActive: _selectedCategory == cat,
                                    onTap: () => _selectCategory(cat),
                                  ),
                                ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ===== TITRE DE SECTION =====
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ===== ITEMS DU MENU =====
                (() {
                  if (_isLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    );
                  } else {
                    final currentItems = _menuData[_selectedCategory] ??
                        const <Map<String, dynamic>>[];
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(bottom: 96),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = currentItems[index];

                            // make sure MenuItem gets both 'image' and 'imageUrl'
                            final adapted = {
                              ...item,
                              'image': item['image'] ?? item['imageUrl'] ?? '',
                              'imageUrl':
                                  item['imageUrl'] ?? item['image'] ?? '',
                            };

                            final nameKey = (item['name'] ?? '') as String;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: MenuItem(
                                pizza: adapted,
                                quantity: itemQuantities[nameKey] ?? 0,
                                onAddToCart: addToCart,
                                onSetQuantity: setItemQuantity, // ← NOUVEAU
                                onIncreaseQuantity: increaseQuantity,
                                onDecreaseQuantity: decreaseQuantity,
                                currencySymbol: _symbolFor(_restaurantCurrency),
                              ),
                            );
                          },
                          childCount: currentItems.length,
                        ),
                      ),
                    );
                  }
                })(),

                if (!_isAdminPreview)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Powered by SmartMenu',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white..withValues(alpha: 0.65),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 96), // Espace pour le FAB
                ),
              ],
            ),
          ),
        ),

        // ===== PANIER FLOTTANT =====
        CartFloatingWidget(
          cartItemCount: _cartItemCount,
          cartTotal: _cartTotal,
          onViewOrder: _showOrderReview,
        ),

        // Modal de révision de commande
        if (_showOrderModal)
          OrderReviewModal(
            itemQuantities: itemQuantities,
            menuData: _menuData,
            cartTotal: _cartTotal,
            onClose: _closeOrderReview,
            onIncreaseQuantity: (itemName) {
              setState(() {
                itemQuantities[itemName] = itemQuantities[itemName]! + 1;
                _cartItemCount++;
                _cartTotal += _getItemPrice(itemName);
              });
            },
            onDecreaseQuantity: (itemName) {
              setState(() {
                if (itemQuantities[itemName]! > 1) {
                  itemQuantities[itemName] = itemQuantities[itemName]! - 1;
                  _cartItemCount--;
                  _cartTotal -= _getItemPrice(itemName);
                } else {
                  _cartItemCount -= itemQuantities[itemName]!;
                  _cartTotal -=
                      _getItemPrice(itemName) * itemQuantities[itemName]!;
                  itemQuantities.remove(itemName);
                  if (itemQuantities.isEmpty) {
                    _closeOrderReview();
                  }
                }
              });
            },
            onRemoveItem: (itemName) {
              setState(() {
                _cartItemCount -= itemQuantities[itemName]!;
                _cartTotal -=
                    _getItemPrice(itemName) * itemQuantities[itemName]!;
                itemQuantities.remove(itemName);
                if (itemQuantities.isEmpty) {
                  _closeOrderReview();
                }
              });
            },
            onConfirmOrder: _confirmOrder,
          ),
      ],
    );
  }
}
