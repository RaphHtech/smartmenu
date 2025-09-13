import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

// petit helper robuste
double _parsePrice(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = value
      .toString()
      .replaceAll(RegExp(r'[^\d,.\-]'), '') // enlève ₪ ou autres symboles
      .replaceAll(',', '.');
  return double.tryParse(s) ?? 0.0;
}

// Widget helper pour les items de menu
class MenuItem extends StatelessWidget {
  final Map<String, dynamic> pizza;
  final int quantity;
  final Function(String itemName, double price) onAddToCart;
  final Function(String itemName, double price) onIncreaseQuantity;
  final Function(String itemName, double price) onDecreaseQuantity;

  final String currencySymbol;

  const MenuItem({
    super.key,
    required this.pizza,
    required this.quantity,
    required this.onAddToCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSignature =
        (pizza['hasSignature'] == true) || (pizza['signature'] == true);
    final String name = (pizza['name'] ?? '').toString();
    final String description = (pizza['description'] ?? '').toString();

    // ➜ calcule 1 seule fois le prix "numérique" et la version affichée
    final double unitPrice = _parsePrice(pizza['price']);
    final String priceText = unitPrice % 1 == 0
        ? '$currencySymbol${unitPrice.toInt()}'
        : '$currencySymbol${unitPrice.toStringAsFixed(2)}';
    final String img = () {
      final candidates = [pizza['imageUrl'], pizza['image'], pizza['photoUrl']];
      for (final candidate in candidates) {
        final s = (candidate?.toString() ?? '').trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
      return '';
    }();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // IMAGE SECTION - Version premium + garde-fous
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (img.isNotEmpty)
                        Image.network(
                          img,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (ctx, child, loading) {
                            if (loading == null) return child;
                            return Container(
                              color: const Color(0xFFF3F4F6),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF3F4F6),
                            alignment: Alignment.center,
                            child: const Text('🍕',
                                style: TextStyle(fontSize: 64)),
                          ),
                        )
                      else
                        Container(
                          color: const Color(0xFFF3F4F6),
                          child: const Center(
                            child: Text('🍕', style: TextStyle(fontSize: 64)),
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x29000000)],
                          ),
                        ),
                      ),
                      if (hasSignature)
                        Positioned(
                          top: 15,
                          right: 15,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                'SIGNATURE',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CONTENT SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15.2,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 22.4,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    // LOGIQUE CONDITIONNELLE POUR BOUTON/CONTROLES
                    if (quantity == 0)
                      // Afficher bouton AJOUTER
                      ElevatedButton(
                        onPressed: () => onAddToCart(name, unitPrice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'AJOUTER',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      )
                    else
                      // Afficher contrôles +/-
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // --- bouton moins ---
                            GestureDetector(
                              onTap: () => onDecreaseQuantity(name, unitPrice),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // --- bouton plus ---
                            GestureDetector(
                              onTap: () => onIncreaseQuantity(name, unitPrice),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
