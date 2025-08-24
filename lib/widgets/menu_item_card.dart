import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final CartProvider cartProvider;
  final LanguageProvider languageProvider;
  final Function(String) onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.cartProvider,
    required this.languageProvider,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = cartProvider.getItemQuantity(item.id);
    final isInCart = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(255, 255, 255, 0.15),
            Color.fromRGBO(255, 255, 255, 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
        boxShadow: [AppColors.primaryShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec badge signature
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                  ),

                  // Badge signature
                  if (item.isSignature)
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'SIGNATURE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du plat
                    Text(
                      item.getLocalizedName(
                          languageProvider.currentLanguageCode),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      item.getLocalizedDescription(
                          languageProvider.currentLanguageCode),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(255, 255, 255, 0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Footer avec prix et boutons
                    _buildFooter(isInCart, quantity),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isInCart, int quantity) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur mobile, affichage en colonne
        if (constraints.maxWidth < 400) {
          return Column(
            children: [
              // Prix
              Container(
                alignment: Alignment.center,
                child: Text(
                  item.formattedPrice,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Contrôles
              _buildControls(isInCart, quantity),
            ],
          );
        }

        // Sur desktop, affichage en ligne
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.formattedPrice,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            _buildControls(isInCart, quantity),
          ],
        );
      },
    );
  }

  Widget _buildControls(bool isInCart, int quantity) {
    if (!isInCart) {
      return ElevatedButton(
        onPressed: () {
          cartProvider.addItem(item);
          onAddToCart('✅ ${item.name} ajouté au panier !');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: const Color.fromRGBO(0, 0, 0, 0.2),
          minimumSize: const Size(0, 44),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            const Color.fromRGBO(220, 38, 38, 0.1),
          ),
        ),
        child: Text(
          languageProvider.translate('add_to_cart'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.1),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton -
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: () {
              cartProvider.decreaseQuantity(item.id);
              if (quantity == 1) {
                onAddToCart('❌ ${item.name} retiré du panier');
              }
            },
          ),
          const SizedBox(width: 10),

          // Quantité
          Text(
            '$quantity',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),

          // Bouton +
          _buildQuantityButton(
            icon: Icons.add,
            onTap: () => cartProvider.increaseQuantity(item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 18,
          weight: 700,
        ),
      ),
    );
  }
}
