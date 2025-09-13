import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CartFloatingWidget extends StatelessWidget {
  final int cartItemCount;
  final double cartTotal;
  final VoidCallback onViewOrder;

  const CartFloatingWidget({
    super.key,
    required this.cartItemCount,
    required this.cartTotal,
    required this.onViewOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItemCount == 0) return const SizedBox.shrink();

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16, right: 16),
      child: Align(
        alignment: Alignment.bottomRight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: FloatingActionButton.extended(
            key: ValueKey('$cartItemCount-$cartTotal'),
            heroTag: 'cartFab',
            onPressed: onViewOrder,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 10,
            icon: const Icon(Icons.shopping_cart, size: 20),
            label: Text(
              '$cartItemCount • ₪${cartTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
