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
  final Function(String itemName, double price, int quantity)? onSetQuantity;

  final String currencySymbol;
  const MenuItem({
    super.key,
    required this.pizza,
    required this.quantity,
    required this.onAddToCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.currencySymbol,
    this.onSetQuantity,
  });

  void _openDetails(BuildContext context) {
    final String name = (pizza['name'] ?? '').toString();
    final String description = (pizza['description'] ?? '').toString();
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.bgGradientWarm,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: _buildDetailCard(
                    name,
                    description,
                    priceText,
                    unitPrice,
                    img,
                    (pizza['category'] ?? '').toString(),
                    currencySymbol,
                    context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuantitySelector(double unitPrice, String currencySymbol,
      BuildContext context, String name, int currentQuantity) {
    if (currentQuantity == 0) {
      // État 1: Nouveau plat - bouton simple AJOUTER
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (onSetQuantity != null) {
              onSetQuantity!(name, unitPrice, 1);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'AJOUTER • $currencySymbol${unitPrice % 1 == 0 ? unitPrice.toInt() : unitPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      );
    }

    // État 2: Plat au panier - juste les boutons + et - premium
    return _QuantityStepperWidget(
      initialQuantity: currentQuantity,
      unitPrice: unitPrice,
      currencySymbol: currencySymbol,
      itemName: name,
      onSetQuantity: onSetQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = (pizza['name'] ?? '').toString();
    final String description = (pizza['description'] ?? '').toString();
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

    // Force toujours la vue liste compacte
    return _buildCompactBand(
      name,
      description,
      priceText,
      unitPrice,
      imageUrl: img.isEmpty ? null : img,
      category: (pizza['category'] ?? '').toString(),
      onTap: () => _openDetails(context),
      onAdd: () => onAddToCart(name, unitPrice),
    );
  }

// Bande fine premium
  Widget _buildCompactBand(
    String name,
    String description,
    String priceText,
    double unitPrice, {
    String? imageUrl,
    String? category,
    VoidCallback? onTap,
    VoidCallback? onAdd,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 88),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder premium
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? _categoryPlaceholder(category)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _categoryPlaceholder(category),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black26)
                        ]),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xB3FFFFFF)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  priceText,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ]),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () => onAddToCart(name, unitPrice),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('AJOUTER',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryPlaceholder(String? category) {
    final c = (category ?? '').toLowerCase();
    final bg = c.contains('pizza')
        ? const Color(0xFFE63946)
        : c.contains('entrée')
            ? const Color(0xFF2A9D8F)
            : c.contains('pâte')
                ? const Color(0xFFF4A261)
                : c.contains('boisson')
                    ? const Color(0xFF457B9D)
                    : const Color(0xFF6C5CE7);

    return Container(
      color: bg.withOpacity(0.9),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant_menu_rounded,
          size: 18, color: Colors.white),
    );
  }

  Widget _buildDetailCard(
      String name,
      String description,
      String priceText,
      double unitPrice,
      String img,
      String category,
      String currencySymbol,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Image ou placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: img.isEmpty
                  ? _categoryPlaceholder(category)
                  : Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _categoryPlaceholder(category),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Contenu
          Text(
            name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                    offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromRGBO(255, 255, 255, 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Prix et quantité
          Text(
            priceText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              shadows: [
                Shadow(
                    offset: Offset(0, 1), blurRadius: 2, color: Colors.black26)
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stepper quantité
          _buildQuantitySelector(
              unitPrice, currencySymbol, context, name, quantity),
          SizedBox(height: 48 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _QuantityStepperWidget extends StatefulWidget {
  final int initialQuantity;
  final double unitPrice;
  final String currencySymbol;
  final String itemName;
  final Function(String itemName, double price, int quantity)? onSetQuantity;

  const _QuantityStepperWidget({
    required this.initialQuantity,
    required this.unitPrice,
    required this.currencySymbol,
    required this.itemName,
    this.onSetQuantity,
  });

  @override
  State<_QuantityStepperWidget> createState() => _QuantityStepperWidgetState();
}

class _QuantityStepperWidgetState extends State<_QuantityStepperWidget> {
  late int localQuantity;

  @override
  void initState() {
    super.initState();
    localQuantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  @override
  Widget build(BuildContext context) {
    final total = localQuantity * widget.unitPrice;
    final totalText = total % 1 == 0
        ? '${widget.currencySymbol}${total.toInt()}'
        : '${widget.currencySymbol}${total.toStringAsFixed(2)}';

    final isUpdate = widget.initialQuantity > 0;
    final isInDeleteMode = localQuantity == 0;

    String buttonText;
    if (isInDeleteMode) {
      buttonText = 'SUPPRIMER DU PANIER';
    } else if (isUpdate) {
      buttonText = 'METTRE À JOUR • $totalText';
    } else {
      buttonText = 'AJOUTER • $totalText';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (localQuantity > 1) {
                    localQuantity--;
                  } else if (localQuantity == 1) {
                    localQuantity = 0; // Mode suppression armée
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (localQuantity == 1 && widget.initialQuantity > 0)
                        ? Colors.red.shade600
                        : AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade600,
              ),
              child: Icon(
                (localQuantity == 1 && widget.initialQuantity > 0)
                    ? Icons.delete_outline
                    : Icons.remove,
                size: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '$localQuantity',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black26)
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: localQuantity < 20
                  ? () => setState(() => localQuantity++)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey.shade600,
              ),
              child: const Icon(Icons.add, size: 20),
            ),
          ],
        ),

        // Signal mode suppression
        if (isInDeleteMode) ...[
          const SizedBox(height: 12),
          Text(
            'Retirer cet article ?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade300,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (widget.onSetQuantity != null) {
                widget.onSetQuantity!(
                    widget.itemName, widget.unitPrice, localQuantity);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isInDeleteMode ? Colors.red.shade600 : AppColors.accent,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
