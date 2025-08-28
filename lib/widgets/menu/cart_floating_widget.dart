import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class CartFloatingWidget extends StatelessWidget {
  final int cartItemCount;
  final double cartTotal;
  final VoidCallback onViewOrder;

  const CartFloatingWidget({
    Key? key,
    required this.cartItemCount,
    required this.cartTotal,
    required this.onViewOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.9), // rgba(0,0,0,0.9)
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromRGBO(255, 255, 255, 0.1),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.4), // 0 8px 30px rgba(0,0,0,0.4)
              blurRadius: 30,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🛒 Commandes ($cartItemCount) - ₪${cartTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17.6,
                color: AppColors.accent,
                letterSpacing: 0.2,
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 15), // Gap entre texte et bouton

            // Bouton 'voir commande'
            SizedBox(
              width: double.infinity, // Prend toute la largeur
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, // 45deg
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent, // var(--accent) = #FCD34D
                      AppColors.secondary, // var(--secondary) = #F97316
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(
                          0, 0, 0, 0.2), // 0 4px 15px rgba(0,0,0,0.2)
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onViewOrder,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30, // padding: 15px 30px du HTML
                        vertical: 15,
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 48, // min-height: 48px du HTML
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'VOIR COMMANDE',
                        style: TextStyle(
                          color: AppColors.primary, // color: var(--primary)
                          fontWeight: FontWeight.w700,
                          fontSize: 16, // font-size: 1rem du HTML
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
