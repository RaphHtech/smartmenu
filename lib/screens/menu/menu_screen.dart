import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmenu_app/core/design/client_tokens.dart';
import 'package:smartmenu_app/services/analytics_service.dart';
import 'package:smartmenu_app/services/table_service.dart';
import 'package:smartmenu_app/widgets/badges_legend_widget.dart';
import '../../core/constants/colors.dart';
import '../../widgets/category_pill_widget.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/modals/order_review_modal.dart';
import '../../widgets/notifications/custom_notification.dart';
import '../../widgets/menu/cart_floating_widget.dart';
import '../../services/cart_service.dart';
import '../../widgets/premium_app_header_widget.dart';
import '../../services/server_call_service.dart';
import '../../state/currency_scope.dart';
import '../../widgets/common/top_toast.dart';
import '../../l10n/app_localizations.dart';

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
  bool _isLoading = true;
  int _cartItemCount = 0;
  double _cartTotal = 0.0;
  bool _isAdminPreview = false;
  String _selectedCategory = '';
  final ScrollController _categoryScrollController = ScrollController();
  Map<String, int> itemQuantities = {};
  bool _promoEnabled = true;
  String _restaurantName = '';
  String _logoUrl = '';
  String _restaurantCurrency = 'ILS';
  String _tagline = '';
  String _promoText = '';
  Map<String, List<Map<String, dynamic>>> _menuData = {};
  List<String> _orderedCategories = [];
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  // Helper pour accéder facilement aux traductions
  AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;
  String _emojiFor(String cat) {
    final c = cat.toLowerCase();

    // Détection intelligente par mots-clés
    if (c.contains('pizza')) {
      return '🍕';
    }
    if (c.contains('pâte') || c.contains('pasta')) {
      return '🍝';
    }
    if (c.contains('salade') || c.contains('entrée') || c.contains('entree')) {
      return '🥗';
    }
    if (c.contains('dessert') ||
        c.contains('sucré') ||
        c.contains('sucre') ||
        c.contains('gâteau') ||
        c.contains('gateau')) {
      return '🍰';
    }
    if (c.contains('boisson') ||
        c.contains('drink') ||
        c.contains('beverage')) {
      return '🥤';
    }
    if (c.contains('burger') || c.contains('sandwich')) {
      return '🍔';
    }
    if (c.contains('sushi') || c.contains('japonais')) {
      return '🍣';
    }
    if (c.contains('café') || c.contains('cafe') || c.contains('coffee')) {
      return '☕';
    }
    if (c.contains('vin') || c.contains('wine') || c.contains('alcool')) {
      return '🍷';
    }
    if (c.contains('petit déj') || c.contains('breakfast')) {
      return '🥐';
    }
    if (c.contains('viande') || c.contains('meat') || c.contains('steak')) {
      return '🥩';
    }
    if (c.contains('poisson') || c.contains('fish')) {
      return '🐟';
    }
    if (c.contains('végé') || c.contains('vegan') || c.contains('vege')) {
      return '🥬';
    }
    if (c.contains('soupe') || c.contains('soup')) {
      return '🍲';
    }
    if (c.contains('taco') || c.contains('mexica')) {
      return '🌮';
    }
    if (c.contains('glace') || c.contains('ice cream')) {
      return '🍨';
    }

    // Fallback élégant et professionnel
    return '🍽️';
  } // Traduit les catégories selon la langue active

  String _translateCategory(BuildContext context, String category) {
    final l10n = _l10n(context);
    switch (category) {
      case 'Pizzas':
        return l10n.categoryPizzas;
      case 'Entrées':
        return l10n.categoryStarters;
      case 'Pâtes':
        return l10n.categoryPasta;
      case 'Desserts':
        return l10n.categoryDesserts;
      case 'Boissons':
        return l10n.categoryDrinks;
      case 'Autres':
        return l10n.categoryOther;
      default:
        return category;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMenuItems(String rid) async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(rid)
        .collection('menus')
        .where('visible', isEqualTo: true)
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      data['id'] = d.id;
      return data;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> out = {};
    for (final it in items) {
      final cat = (it['category'] ?? 'Autres').toString();
      (out[cat] ??= []).add(it);
    }

    for (final v in out.values) {
      v.sort((a, b) {
        final aFeatured = a['featured'] as bool? ?? false;
        final bFeatured = b['featured'] as bool? ?? false;

        debugPrint(
            'Tri: ${a['name']} (featured=$aFeatured) vs ${b['name']} (featured=$bFeatured)');

        if (aFeatured != bFeatured) {
          final result = aFeatured ? -1 : 1;
          debugPrint('  → Featured différent, résultat: $result');
          return result;
        }

        final aPosition = (a['position'] as num?)?.toDouble() ?? 999999.0;
        final bPosition = (b['position'] as num?)?.toDouble() ?? 999999.0;
        final positionCompare = aPosition.compareTo(bPosition);
        if (positionCompare != 0) return positionCompare;

        return (a['name'] ?? '')
            .toString()
            .compareTo((b['name'] ?? '').toString());
      });
    }

    return out;
  }

  Future<void> _hydrate() async {
    setState(() => _isLoading = true);

    final String resolvedRid = () {
      final q = Uri.base.queryParameters['rid'];
      if (q != null && q.isNotEmpty) return q;
      return widget.restaurantId;
    }();

    final futures = await Future.wait([
      _fetchMenuItems(resolvedRid),
      _loadRestaurantDetailsData(resolvedRid),
    ]);

    final items = futures[0] as List<Map<String, dynamic>>;
    final restaurantData = futures[1] as Map<String, dynamic>;

    final organized = _groupByCategory(items);
    final categoriesOrder =
        List<String>.from(restaurantData['categoriesOrder'] ?? []);
    final categoriesHidden =
        Set<String>.from(restaurantData['categoriesHidden'] ?? []);

    final allCats =
        organized.keys.where((c) => !categoriesHidden.contains(c)).toSet();
    final orderedCategories = [
      ...categoriesOrder.where(allCats.contains),
      ...allCats.difference(categoriesOrder.toSet()).toList()..sort(),
    ];

    if (mounted) {
      setState(() {
        _menuData = organized;
        _orderedCategories = orderedCategories;
        _selectedCategory =
            orderedCategories.isNotEmpty ? orderedCategories.first : '';
        _restaurantName = (restaurantData['name'] ?? '').toString();
        _restaurantCurrency = (restaurantData['currency'] ?? 'ILS').toString();
        _tagline = (restaurantData['tagline'] ?? '').toString().trim();
        _promoText = (restaurantData['promo_text'] ?? '').toString().trim();
        _promoEnabled = (restaurantData['promo_enabled'] as bool?) ?? true;
        _logoUrl = (restaurantData['logoUrl'] ?? '').toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final qp = Uri.base.queryParameters;
    _isAdminPreview = qp.containsKey('preview') || qp.containsKey('admin');
    String? tableId = qp['t'] ?? qp['table'];
    if (tableId != null) {
      tableId = tableId.replaceFirst(RegExp(r'^table'), '');
      TableService.setTableId(tableId);
    }

    _hydrate();
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

  Future<Map<String, dynamic>> _loadRestaurantDetailsData(String rid) async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(rid)
        .collection('info')
        .doc('details')
        .get();

    return snap.data() ?? {};
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

    AnalyticsService.logAddToCart(widget.restaurantId, itemName,
        tableId: TableService.getTableId());

    TopToast.show(
      context,
      message: _l10n(context).itemAddedToCart(itemName),
      variant: ToastVariant.success,
    );
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

    final currentQuantity = itemQuantities[itemName] ?? 0;
    if (newQuantity > currentQuantity) {
      _showCustomNotification('✅ ${_l10n(context).itemAddedToCart(itemName)}');
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
              setState(() {});
            }
          : null,
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_categoryScrollController.hasClients && mounted) {
        final selectedIndex = _orderedCategories.indexOf(category);
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
      TopToast.show(
        context,
        message: _l10n(context).cartEmpty,
        variant: ToastVariant.info,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: OrderReviewModal(
          itemQuantities: itemQuantities,
          menuData: _menuData,
          cartTotal: _cartTotal,
          currency: _restaurantCurrency,
          onClose: () => Navigator.of(context).pop(),
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
                  Navigator.of(context).pop();
                }
              }
            });
          },
          onRemoveItem: (itemName) {
            setState(() {
              _cartItemCount -= itemQuantities[itemName]!;
              _cartTotal -= _getItemPrice(itemName) * itemQuantities[itemName]!;
              itemQuantities.remove(itemName);
              if (itemQuantities.isEmpty) {
                Navigator.of(context).pop();
              }
            });
          },
          onConfirmOrder: () {
            Navigator.of(context).pop();
            _confirmOrder();
          },
        ),
      ),
    );
  }

  void _confirmOrder() async {
    try {
      setState(() {
        itemQuantities.clear();
        _cartItemCount = 0;
        _cartTotal = 0.0;
      });

      TopToast.show(
        context,
        message: _l10n(context).orderCreated,
        subtitle: _l10n(context).restaurantNotified,
        variant: ToastVariant.success,
      );
    } catch (e) {
      TopToast.show(
        context,
        message: _l10n(context).orderError,
        subtitle: e.toString(),
        variant: ToastVariant.error,
        duration: const Duration(seconds: 4),
      );
    }
  }

  double _getItemPrice(String itemName) {
    return CartService.getItemPrice(itemName, _menuData);
  }

  void _handleAdminReturn(BuildContext context) {
    debugPrint('🔴 ADMIN BUTTON CLICKED');

    if (Navigator.of(context).canPop()) {
      debugPrint('🟢 Popping navigator');
      Navigator.of(context).pop();
    } else {
      debugPrint('🔵 Cannot pop, using pushNamed');
      Navigator.of(context, rootNavigator: true).pushReplacementNamed(
          '/admin/dashboard?restaurantId=${widget.restaurantId}');
    }
  }

  void _handleScroll() {
    final offset = _mainScrollController.offset;
    final shouldCollapse = _isHeaderCollapsed ? offset > 32 : offset > 40;

    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = shouldCollapse;
      });
    }
  }

  Widget _buildPromoBanner() {
    if (!_promoEnabled || _promoText.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: ClientTokens.space16, vertical: ClientTokens.space8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(ClientTokens.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ClientTokens.space16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded,
                  size: 14, color: Colors.white),
            ),
            const SizedBox(width: ClientTokens.space12),
            Expanded(
              child: Text(
                _promoText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = _restaurantCurrency.toUpperCase();
    final l10n = _l10n(context);

    return CurrencyScope(
      code: code,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.bgGradientWarm,
              ),
            ),
          ),
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
                  PremiumAppHeaderWidget(
                    tagline: _tagline,
                    restaurantName: _restaurantName,
                    showAdminReturn: _isAdminPreview,
                    onAdminReturn: _isAdminPreview
                        ? () => _handleAdminReturn(context)
                        : null,
                    logoUrl: _logoUrl,
                    onBadgesInfo: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const BadgesLegendWidget(),
                      );
                    },
                  ),
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
                        child: _buildPromoBanner(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final cat in _orderedCategories)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: CategoryPill(
                                      label:
                                          '${_emojiFor(cat)} ${_translateCategory(context, cat)}',
                                      isActive: _selectedCategory == cat,
                                      onTap: () => _selectCategory(cat),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
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
                      final currentItems = _selectedCategory.isEmpty
                          ? _menuData.values.expand((v) => v).toList()
                          : (_menuData[_selectedCategory] ??
                              const <Map<String, dynamic>>[]);
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20)
                            .copyWith(bottom: 96),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = currentItems[index];

                              final adapted = {
                                ...item,
                                'image': (item['imageUrl'] ?? item['image'])
                                        as String? ??
                                    '',
                                'imageUrl': (item['imageUrl'] ?? item['image'])
                                        as String? ??
                                    '',
                              };

                              final nameKey = (item['name'] ?? '') as String;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: MenuItem(
                                  pizza: adapted,
                                  quantity: itemQuantities[nameKey] ?? 0,
                                  onAddToCart: addToCart,
                                  onSetQuantity: setItemQuantity,
                                  onIncreaseQuantity: increaseQuantity,
                                  onDecreaseQuantity: decreaseQuantity,
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
                            l10n.poweredBy,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 96),
                  ),
                ],
              ),
            ),
          ),
          // MODIFICATION 1 : Panier tout en bas (bottom: 16)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CartFloatingWidget(
                cartItemCount: _cartItemCount,
                cartTotal: _cartTotal,
                onViewOrder: _showOrderReview,
              ),
            ),
          ),
          // MODIFICATION 2 : Bouton Serveur juste au-dessus (bottom: 88) avec adaptation RTL
          if (!_isAdminPreview)
            Positioned(
              // Adaptation RTL automatique
              left: Directionality.of(context) == TextDirection.rtl ? 16 : null,
              right:
                  Directionality.of(context) == TextDirection.ltr ? 16 : null,
              // Position au-dessus de la barre Commande
              bottom: 88 + MediaQuery.of(context).padding.bottom,
              child: FloatingActionButton.extended(
                onPressed: _isLoading
                    ? null
                    : () {
                        final tableId = TableService.getTableId();
                        if (tableId == null) {
                          TopToast.show(
                            context,
                            message: _l10n(context).tableNotIdentified,
                            variant: ToastVariant.warning,
                          );
                          return;
                        }

                        setState(() => _isLoading = true);

                        ServerCallService.callServer(
                          rid: widget.restaurantId,
                          table: 'table$tableId',
                        ).then((_) {
                          if (context.mounted) {
                            TopToast.show(
                              context,
                              message: _l10n(context).waiterCalled,
                              subtitle: _l10n(context).staffComing,
                              variant: ToastVariant.info,
                            );
                          }
                        }).catchError((e) {
                          if (context.mounted) {
                            final error = e.toString();
                            if (error.contains('COOLDOWN_ACTIVE:')) {
                              final seconds = error.split(':')[1];
                              TopToast.show(
                                context,
                                message: _l10n(context).cooldownWait(seconds),
                                variant: ToastVariant.warning,
                              );
                            } else {
                              TopToast.show(
                                context,
                                message: _l10n(context).error(e.toString()),
                                variant: ToastVariant.error,
                              );
                            }
                          }
                        }).whenComplete(() {
                          if (mounted) setState(() => _isLoading = false);
                        });
                      },
                icon: const Icon(Icons.room_service, size: 20),
                label: Text(_l10n(context).waiter),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 6,
              ),
            ),
        ],
      ),
    );
  }
}
