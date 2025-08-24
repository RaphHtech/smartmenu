import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/menu_item_card.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/cart_floating_button.dart';
import '../../widgets/custom_app_bar.dart';

class MenuScreen extends StatefulWidget {
  final String? restaurantId;
  final String? tableNumber;

  const MenuScreen({
    super.key,
    this.restaurantId,
    this.tableNumber,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showOrderModal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadMockData();
      if (widget.tableNumber != null) {
        context.read<CartProvider>().setTableNumber(widget.tableNumber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Consumer3<MenuProvider, CartProvider, LanguageProvider>(
            builder:
                (context, menuProvider, cartProvider, languageProvider, child) {
              if (menuProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final restaurant = menuProvider.restaurant;
              if (restaurant == null) {
                return const Center(
                  child: Text('Restaurant non trouvé',
                      style: TextStyle(color: Colors.white)),
                );
              }

              return Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      // 1. HEADER SMARTMENU
                      SliverToBoxAdapter(
                        child: CustomAppBar(
                          restaurant: restaurant,
                          languageProvider: languageProvider,
                          onCallServer: _callServer,
                        ),
                      ),

                      // 2. HERO SECTION
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 20),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '🍕 ${restaurant.getLocalizedName(languageProvider.currentLanguageCode)}',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                restaurant.getLocalizedDescription(
                                    languageProvider.currentLanguageCode),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 3. PROMO SECTION
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.2)),
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

                      // 4. NAVIGATION CATÉGORIES
                      SliverToBoxAdapter(
                        child: CategoryChips(
                          categories: menuProvider.availableCategories,
                          selectedCategory: menuProvider.selectedCategory,
                          onCategorySelected: menuProvider.selectCategory,
                          languageProvider: languageProvider,
                          restaurant: restaurant,
                        ),
                      ),

                      // 5. SECTION MENU
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _getSectionTitle(menuProvider.selectedCategory),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // 6. ITEMS DU MENU
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final items = menuProvider.currentCategoryItems;
                              if (index >= items.length) return null;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: MenuItemCard(
                                  item: items[index],
                                  cartProvider: cartProvider,
                                  languageProvider: languageProvider,
                                  onAddToCart: _showNotification,
                                ),
                              );
                            },
                            childCount:
                                menuProvider.currentCategoryItems.length,
                          ),
                        ),
                      ),

                      // 7. FOOTER SMARTMENU
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.only(top: 40),
                          padding: const EdgeInsets.all(30),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            border: Border(
                              top: BorderSide(
                                  color: Color.fromRGBO(255, 255, 255, 0.2),
                                  width: 2),
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                '🍽️ SmartMenu',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Solutions digitales premium pour restaurants',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                '📍 Dizengoff 45, Tel Aviv • 📞 03-1234567 • 🕐 Dim-Jeu 11h-23h, Ven 11h-15h',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromRGBO(255, 255, 255, 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Espace pour le panier flottant
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 140),
                      ),
                    ],
                  ),

                  // Panier flottant
                  CartFloatingButton(
                    cartProvider: cartProvider,
                    onShowOrder: () => setState(() => _showOrderModal = true),
                  ),

                  // Modal de commande
                  if (_showOrderModal)
                    _buildOrderModal(cartProvider, languageProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _callServer() {
    print('📞 Appel du serveur demandé');
    _showNotification(
        '📞 Appel du serveur...\nUn membre de notre équipe arrive à votre table !');
  }

  String _getSectionTitle(String category) {
    switch (category) {
      case 'pizzas':
        return '🍕 PIZZAS SIGNATURE';
      case 'entrees':
        return '🥗 ENTRÉES';
      case 'pates':
        return '🍝 PÂTES FRAÎCHES';
      case 'desserts':
        return '🍰 DESSERTS';
      case 'boissons':
        return '🍹 BOISSONS';
      default:
        return '🍽️ MENU';
    }
  }

  void _showNotification(String message) {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.primaryShadow],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Widget _buildOrderModal(
      CartProvider cartProvider, LanguageProvider languageProvider) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.2), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📋 RÉVISION DE VOTRE COMMANDE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color.fromRGBO(255, 255, 255, 0.2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.menuItem.getLocalizedName(
                                  languageProvider.currentLanguageCode),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => cartProvider
                                    .decreaseQuantity(item.menuItem.id),
                                icon: const Icon(Icons.remove,
                                    color: AppColors.primary),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => cartProvider
                                    .increaseQuantity(item.menuItem.id),
                                icon: const Icon(Icons.add,
                                    color: AppColors.primary),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () =>
                                    cartProvider.removeItem(item.menuItem.id),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item.formattedTotalPrice,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                        color: Color.fromRGBO(255, 255, 255, 0.3), width: 2),
                  ),
                ),
                child: Text(
                  'TOTAL: ${cartProvider.formattedTotalPrice}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showOrderModal = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '← MODIFIER',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CONFIRMER COMMANDE',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOrder() {
    final cartProvider = context.read<CartProvider>();

    _showNotification('🎉 COMMANDE CONFIRMÉE !\n\n'
        'Votre commande a été transmise à la cuisine !\n'
        '⏱️ Temps d\'attente estimé: 15-20 minutes');

    cartProvider.clearCart();
    setState(() => _showOrderModal = false);
  }
}
