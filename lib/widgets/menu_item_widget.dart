import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../screens/menu/menu_screen.dart';

// Widget helper pour les items de menu
class MenuItem extends StatelessWidget {
  final Map<String, dynamic> pizza;

  const MenuItem({required this.pizza, super.key});

  @override
  Widget build(BuildContext context) {
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
          // IMAGE SECTION
          Container(
            height: 200,
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
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    '🍕',
                    style: TextStyle(fontSize: 64),
                  ),
                ),
                if (pizza['hasSignature'])
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SIGNATURE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // CONTENT SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pizza['name'],
                  style: const TextStyle(
                    fontSize: 22.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pizza['description'],
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
                      pizza['price'],
                      style: const TextStyle(
                        fontSize: 22.4,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    // LOGIQUE CONDITIONNELLE POUR BOUTON/CONTROLES
                    Builder(
                      builder: (context) {
                        final screenState = context
                            .findAncestorStateOfType<SimpleMenuScreenState>()!;
                        final quantity =
                            screenState.itemQuantities[pizza['name']] ?? 0;

                        if (quantity == 0) {
                          // Afficher bouton AJOUTER
                          return ElevatedButton(
                            onPressed: () {
                              final priceText =
                                  pizza['price'].toString().replaceAll('₪', '');
                              final price = double.tryParse(priceText) ?? 0.0;
                              screenState.addToCart(pizza['name'], price);
                            },
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
                          );
                        } else {
                          // Afficher contrôles +/-
                          return Container(
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
                                GestureDetector(
                                  onTap: () {
                                    final priceText = pizza['price']
                                        .toString()
                                        .replaceAll('₪', '');
                                    final price =
                                        double.tryParse(priceText) ?? 0.0;
                                    screenState.decreaseQuantity(
                                        pizza['name'], price);
                                  },
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final priceText = pizza['price']
                                        .toString()
                                        .replaceAll('₪', '');
                                    final price =
                                        double.tryParse(priceText) ?? 0.0;
                                    screenState.increaseQuantity(
                                        pizza['name'], price);
                                  },
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
                          );
                        }
                      },
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
