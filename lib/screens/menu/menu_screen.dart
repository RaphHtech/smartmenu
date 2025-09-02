import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/firebase_menu_service.dart';
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
  Map<String, List<Map<String, dynamic>>> _menuData = {};

  @override
  void initState() {
    super.initState();
    _loadMenuFromFirebase();
  }

  void _loadMenuFromFirebase() async {
    setState(() => _isLoading = true);

    final items = await FirebaseMenuService.getMenuItems(widget.restaurantId);
    final organized = FirebaseMenuService.organizeByCategory(items);

    setState(() {
      _menuData = organized;
      _isLoading = false; // Chargement terminé
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
                                  ShaderMask(
                                    shaderCallback: (r) => const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFF5F5F5),
                                        Color(0xFFE3D7A3)
                                      ], // doré clair
                                    ).createShader(r),
                                    child: Transform.scale(
                                      scaleX: -1, // pointe vers la gauche
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        size: 64, // ajuste à 68–72 si tu veux
                                        color: Colors
                                            .white, // remplacé par le gradient via ShaderMask
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Titre HÉRO en dégradé — 1 LIGNE
                                  const GradientText(
                                    'PIZZA POWER',
                                    gradient: AppColors
                                        .titleGradient, // tu peux passer à un gradient plus doré si tu veux
                                    style: TextStyle(
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
                            const Text(
                              'La vraie pizza italienne à Tel Aviv',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20, // ≈ 1.3rem
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
                SliverToBoxAdapter(
                  child: Container(
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
                    child: const Text(
                      '✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

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
                            CategoryPill(
                              label: '🍕 Pizzas',
                              isActive: _selectedCategory == 'Pizzas',
                              onTap: () => _selectCategory('Pizzas'),
                            ),
                            const SizedBox(width: 12),
                            CategoryPill(
                                label: '🥗 Entrées',
                                isActive: _selectedCategory == 'Entrées',
                                onTap: () => _selectCategory('Entrées')),
                            const SizedBox(width: 12),
                            CategoryPill(
                                label: '🍝 Pâtes',
                                isActive: _selectedCategory == 'Pâtes',
                                onTap: () => _selectCategory('Pâtes')),
                            const SizedBox(width: 12),
                            CategoryPill(
                                label: '🍰 Desserts',
                                isActive: _selectedCategory == 'Desserts',
                                onTap: () => _selectCategory('Desserts')),
                            const SizedBox(width: 12),
                            CategoryPill(
                                label: '🍹 Boissons',
                                isActive: _selectedCategory == 'Boissons',
                                onTap: () => _selectCategory('Boissons')),
                            const SizedBox(
                                width:
                                    20), // ← AJOUTE l'espacement final à la fin
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
                _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final currentItems =
                                  _menuData[_selectedCategory] ?? [];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: MenuItem(
                                  pizza: currentItems[index],
                                  quantity: itemQuantities[currentItems[index]
                                          ['name']] ??
                                      0,
                                  onAddToCart: addToCart,
                                  onIncreaseQuantity: increaseQuantity,
                                  onDecreaseQuantity: decreaseQuantity,
                                ),
                              );
                            },
                            childCount:
                                _menuData[_selectedCategory]?.length ?? 0,
                          ),
                        ),
                      ),

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
