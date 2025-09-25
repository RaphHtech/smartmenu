import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/currency_service.dart';
import '../../state/currency_scope.dart';

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
      minimum: const EdgeInsets.only(bottom: 100, right: 16),
      child: Align(
        alignment: Alignment.bottomRight,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: FilledButton.tonal(
            onPressed: onViewOrder,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              elevation: 8,
              shape: const StadiumBorder(),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartItemCount',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(context.money(cartTotal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
