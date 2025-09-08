import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/gradient_text_widget.dart';
import '../../widgets/category_pill_widget.dart';
import '../../widgets/menu_item_widget.dart';
import '../../widgets/modals/order_review_modal.dart';
import '../../widgets/notifications/custom_notification.dart';
import '../../widgets/menu/cart_floating_widget.dart';
import '../../widgets/menu/app_header_widget.dart';
import '../../services/cart_service.dart';

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
  String _selectedCategory = 'Pizzas';
  Map<String, int> itemQuantities = {};
  bool _showOrderModal = false;
  bool _promoEnabled = true;
  String _restaurantName = '';
  String _restaurantCurrency = 'ILS'; // <-- règle l'erreur "undefined name"
  String _tagline = ''; // sous-titre (catch phrase)
  String _promoText = ''; // bandeau promo
  Map<String, List<Map<String, dynamic>>> _menuData = {};
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
    });
  }

  void _loadMenuFromFirebase() async {
    setState(() => _isLoading = true);

    // résout l'id effectif
    final String rid = () {
      // si on est sur le web et qu’un rid est fourni en query string
      final q = Uri.base.queryParameters['rid'];
      if (q != null && q.isNotEmpty) return q;
      return widget.restaurantId; // sinon, on garde la prop
    }();

    // Charger le menu (remplace l'appel au service)
    final items = await _fetchMenuItems(rid);
    final organized = _groupByCategory(items);

    setState(() {
      _menuData = organized;
      // si la catégorie sélectionnée n’existe pas, prends la 1ère dispo
      final keys = organized.keys.toList()..sort();
      if (keys.isNotEmpty && !organized.containsKey(_selectedCategory)) {
        _selectedCategory = keys.first;
      }
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
                      '📞 Appel du serveur...\nUn membre de notre équipe arrive à votre table !',
                    );
                  },
                  restaurantName: _restaurantName.toUpperCase(),
                ),

                // ===== SECTION HÉRO (2e “rectangle”) =====
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration:
                            const BoxDecoration(color: AppColors.heroOverlay),
                        child:
                            // Ligne du logo + grand titre (sur 1 ligne)
                            Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Ligne du logo + grand titre (sur 1 ligne)
                            FittedBox(
                              // ← évite tout dépassement horizontal
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Logo "triangle" doré
                                  // Pas d'icône pour le moment

                                  // Titre HÉRO en dégradé — 1 LIGNE
                                  GradientText(
                                    _restaurantName.toUpperCase(),
                                    gradient: AppColors.titleGradient,
                                    style: const TextStyle(
                                      fontSize: 56, // ≈ 3.5rem
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          // léger relief comme sur la maquette
                                          color: Color.fromRGBO(0, 0, 0, 0.25),
                                          blurRadius: 12,
                                          offset: Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 📝 DESCRIPTION
                            if (_tagline.isNotEmpty)
                              Text(
                                _tagline,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22, // ≈ 1.3rem
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 0.9),
                                ),
                              ),
                          ],
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
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color.fromRGBO(255, 255, 255, 0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _promoText,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                              textAlign: TextAlign.center,
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
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20), // Padding seulement sur le contenu
                        child: Row(
                          children: [
                            for (final cat in (_menuData.keys.toList()..sort()))
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CategoryPill(
                                  label: _emojiFor(cat) + ' ' + cat,
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
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      '🍕 SPECIALITÉS',
                      style: TextStyle(
                        fontSize: 32, // ← 2rem du HTML
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        shadows: [
                          Shadow(
                            color: Color.fromRGBO(0, 0, 0, 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: SizedBox(height: 120),
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
