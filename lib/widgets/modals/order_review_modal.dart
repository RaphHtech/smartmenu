import 'package:flutter/material.dart';
// import '../../core/constants/colors.dart';
import '../../state/currency_scope.dart';
// import '../../services/currency_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../core/design/client_tokens.dart';

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
    return Semantics(
      container: true,
      label: 'Révision de commande',
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Material(
            elevation: 12,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ClientTokens.radius20),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. HEADER avec icône, titre, bouton fermer
                _buildHeader(context),

                // 2. CORPS SCROLLABLE
                Flexible(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsetsDirectional.all(ClientTokens.space24),
                    child: Column(
                      children: [
                        // Vos items existants ici
                        _buildOrderItems(context),

                        const SizedBox(height: ClientTokens.space24),

                        // 3. SECTION TOTAL mise en valeur
                        _buildTotalSection(context),
                      ],
                    ),
                  ),
                ),

                // 4. FOOTER STICKY avec boutons
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER complet et accessible
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsetsDirectional.all(ClientTokens.space16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: colorScheme.primary,
            size: 24,
          ),

          const SizedBox(width: ClientTokens.space12),

          Expanded(
            child: Text(
              'Révision de votre commande',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Bouton fermer accessible
          IconButton(
            tooltip: 'Fermer',
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TOTAL en bloc surfaceVariant
  Widget _buildTotalSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalItems = itemQuantities.values.fold(0, (sum, qty) => sum + qty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(ClientTokens.space16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(ClientTokens.radius16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ClientTokens.space4),
              Text(
                '$totalItems ${totalItems > 1 ? 'articles' : 'article'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // Total avec animation fade
          AnimatedSwitcher(
            duration: ClientTokens.durationFast,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              context.money(cartTotal),
              key: ValueKey(cartTotal.toStringAsFixed(2)),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FOOTER avec boutons et séparation
  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(ClientTokens.space16),
          child: Row(
            children: [
              // Bouton RETOUR
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: onClose,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'RETOUR',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(ClientTokens.radius12),
                    ),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: ClientTokens.space16),

              // Bouton CONFIRMER avec shortcuts clavier
              Expanded(
                flex: 7,
                child: FocusableActionDetector(
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
                    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
                  },
                  actions: {
                    ActivateIntent: CallbackAction<ActivateIntent>(
                      onInvoke: (_) {
                        _confirmOrder(context);
                        return null;
                      },
                    ),
                  },
                  child: FilledButton(
                    onPressed: () => _confirmOrder(context),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(160, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ClientTokens.radius12),
                      ),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('CONFIRMER'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fonction confirm avec haptic + annonce
  void _confirmOrder(BuildContext context) {
    HapticFeedback.lightImpact();

    // Annonce accessibilité
    SemanticsService.announce(
      'Commande confirmée',
      Directionality.of(context),
    );

    onConfirmOrder();
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      children: itemQuantities.entries.map((entry) {
        // Trouver le prix de l'article dans les données
        double itemPrice = 0.0;
        for (var category in menuData.values) {
          for (var item in category) {
            if (item['name'] == entry.key) {
              itemPrice = (item['price'] is num)
                  ? (item['price'] as num).toDouble()
                  : double.tryParse(item['price'].toString()) ?? 0.0;
              break;
            }
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: ClientTokens.space12),
          padding: const EdgeInsets.all(ClientTokens.space12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.money(itemPrice * entry.value),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),

              // Contrôles quantité
              Row(
                children: [
                  IconButton(
                    onPressed: () => onDecreaseQuantity(entry.key),
                    icon: const Icon(Icons.remove_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onIncreaseQuantity(entry.key),
                    icon: const Icon(Icons.add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => onRemoveItem(entry.key),
                    icon: const Icon(Icons.delete_outline_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
