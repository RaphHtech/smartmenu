import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../providers/cart_provider.dart';

class CartFloatingButton extends StatelessWidget {
  final CartProvider cartProvider;
  final VoidCallback onShowOrder;

  const CartFloatingButton({
    super.key,
    required this.cartProvider,
    required this.onShowOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (cartProvider.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.1)),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.4),
              blurRadius: 30,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: _buildCartContent(context),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur mobile, affichage en colonne
        if (constraints.maxWidth < 400) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCartSummary(),
              const SizedBox(height: 15),
              _buildCheckoutButton(),
            ],
          );
        }

        // Sur desktop, affichage en ligne
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildCartSummary()),
            const SizedBox(width: 20),
            _buildCheckoutButton(),
          ],
        );
      },
    );
  }

  Widget _buildCartSummary() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(252, 211, 77, 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_cart,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Commandes (${cartProvider.totalItems})',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.accent,
              ),
            ),
            Text(
              cartProvider.formattedTotalPrice,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutButton() {
    return ElevatedButton(
      onPressed: onShowOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.2),
        minimumSize: const Size(0, 48),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(
          const Color.fromRGBO(220, 38, 38, 0.1),
        ),
      ),
      child: const Text(
        'VOIR COMMANDE',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
