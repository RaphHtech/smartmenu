import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/category_pill_widget.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/modals/order_review_modal.dart';
import '../../widgets/notifications/custom_notification.dart';
import '../../widgets/menu/cart_floating_widget.dart';
import '../../widgets/menu/app_header_widget.dart';
import '../../services/cart_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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
        // pour afficher uniquement les plats visibles, laisser la ligne;
        // sinon, la commenter.
        .where('visible', isEqualTo: true)
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
    // tri par nom dans chaque catégorie
    for (final v in out.values) {
      v.sort((a, b) =>
          (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    final qp = Uri.base.queryParameters;
    _isAdminPreview = qp.containsKey('preview') || qp.containsKey('admin');
    _loadMenuFromFirebase();
    _loadRestaurantDetails();
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

    // Animation visuelle (optionnel)
    _showCustomNotification('✅ $itemName ajouté au panier !');
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

    // Calculer la position pour centrer la catégorie sélectionnée
    if (_categoryScrollController.hasClients) {
      final categories = _menuData.keys.toList()..sort();
      final selectedIndex = categories.indexOf(category);

      if (selectedIndex >= 0) {
        // Largeur estimée d'une pill (padding + texte + espacement)
        const pillWidth = 120.0;
        final scrollPosition = selectedIndex * pillWidth;

        _categoryScrollController.animateTo(
          scrollPosition > 0 ? scrollPosition - 60 : 0, // Offset pour centrer
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
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
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ===== HEADER (en dur) =====
                AppHeaderWidget(
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

                // ===== SECTION HÉRO (2e “rectangle”) =====
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 30, horizontal: 20),
                        decoration:
                            const BoxDecoration(color: AppColors.heroOverlay),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_tagline.isNotEmpty)
                                Text(
                                  _tagline,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(255, 255, 255, 0.9),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== SECTION PROMO (glassmorphism) =====
                (() {
                  if (!_promoEnabled || _promoText.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }
                  return SliverToBoxAdapter(
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
                  );
                })(),

                // ===== NAVIGATION CATÉGORIES =====
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: SingleChildScrollView(
                      controller: _categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20), // Padding seulement sur le contenu
                        child: Row(
                          children: [
                            for (final cat in () {
                              final allCats = _menuData.keys.toSet();
                              allCats.addAll(_categoriesOrder);
                              return applyOrderAndHide(
                                  allCats, _categoriesOrder, _categoriesHidden);
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

                // ===== TITRE DE SECTION =====
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

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
                              padding: const EdgeInsets.only(bottom: 20),
                              child: MenuItem(
                                pizza: adapted,
                                quantity: itemQuantities[nameKey] ?? 0,
                                onAddToCart: addToCart,
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
