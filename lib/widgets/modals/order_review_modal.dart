import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../state/currency_scope.dart';
import '../../services/currency_service.dart';

class OrderReviewModal extends StatelessWidget {
  final Map<String, int> itemQuantities;
  final Map<String, dynamic> menuData;
  final double cartTotal;
  final String currency; // ← AJOUTER
  final VoidCallback onClose;
  final Function(String itemName) onIncreaseQuantity;
  final Function(String itemName) onDecreaseQuantity;
  final Function(String itemName) onRemoveItem;
  final VoidCallback onConfirmOrder;

  const OrderReviewModal({
    super.key,
    required this.itemQuantities,
    required this.menuData,
    required this.cartTotal,
    required this.currency,
    required this.onClose,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.onRemoveItem,
    required this.onConfirmOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha((255 * 0.8).round()),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFDC2626), // Rouge (primary)
                  Color(0xFFF97316), // Orange (secondary)
                  Color(0xFFFCD34D), // Jaune (accent)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.2),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                const Text(
                  '📋 RÉVISION DE VOTRE COMMANDE',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Liste des items
                Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: itemQuantities.entries.map((entry) {
                        // Trouver le prix de l'article dans les données
                        double itemPrice = 0.0;
                        for (var category in menuData.values) {
                          for (var item in category) {
                            if (item['name'] == entry.key) {
                              itemPrice = (item['price'] is num)
                                  ? (item['price'] as num).toDouble()
                                  : double.tryParse(item['price'].toString()) ??
                                      0.0;
                              break;
                            }
                          }
                        }

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          // LIGNE DE SÉPARATION EN BAS
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromRGBO(255, 255, 255, 0.2),
                                width: 1,
                              ),
                            ),
                          ),

                          child: LayoutBuilder(builder: (context, c) {
                            // Breakpoint "étroit" pour la modale
                            final isNarrow = c.maxWidth < 360;

                            // Ta taille de contrôles, compacte si étroit
                            final btn = isNarrow ? 28.0 : 32.0;
                            final iconSz = isNarrow ? 16.0 : 18.0;
                            final qtyPad = isNarrow ? 10.0 : 16.0;
                            final gap = isNarrow ? 8.0 : 10.0;

                            // Widgets réutilisables
                            final nameText = Text(
                              entry.key,
                              maxLines:
                                  isNarrow ? 2 : 1, // ← 2 lignes en étroit
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                decoration: TextDecoration.none,
                              ),
                            );

                            final qtyControls = Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(255, 255, 255, 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // --- bouton moins ---
                                  GestureDetector(
                                    onTap: () => onDecreaseQuantity(entry.key),
                                    child: Container(
                                      width: btn,
                                      height: btn,
                                      decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.remove,
                                          color: AppColors.primary,
                                          size: iconSz),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: qtyPad),
                                    child: Text(
                                      '${entry.value}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  // --- bouton plus ---
                                  GestureDetector(
                                    onTap: () => onIncreaseQuantity(entry.key),
                                    child: Container(
                                      width: btn,
                                      height: btn,
                                      decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle),
                                      child: Icon(Icons.add,
                                          color: AppColors.primary,
                                          size: iconSz),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            // --- bouton supprimer ---
                            final deleteBtn = GestureDetector(
                              onTap: () => onRemoveItem(entry.key),
                              child: Container(
                                padding: EdgeInsets.all(isNarrow ? 6 : 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white, size: 18),
                              ),
                            );

                            final priceText = Directionality(
                              textDirection: TextDirection.ltr, // pour '₪'
                              child: Text(
                                CurrencyService.format(
                                    itemPrice * entry.value, currency),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            );

                            // --- Layout responsive ---
                            if (isNarrow) {
                              // 2 LIGNES : (Nom + Prix) / (Qty + Delete)
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: nameText),
                                      const SizedBox(width: 8),
                                      priceText,
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      qtyControls,
                                      SizedBox(width: gap),
                                      deleteBtn,
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              // LARGE : 1 LIGNE compressible à droite
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: nameText),
                                  const SizedBox(width: 12),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        qtyControls,
                                        SizedBox(width: gap),
                                        deleteBtn,
                                        SizedBox(width: gap),
                                        priceText,
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Total
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TOTAL: ${CurrencyService.format(cartTotal, currency)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onClose,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          minimumSize: const Size(double.infinity, 48),
                          fixedSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '← MODIFIER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accent, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onConfirmOrder,
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                'CONFIRMER',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
