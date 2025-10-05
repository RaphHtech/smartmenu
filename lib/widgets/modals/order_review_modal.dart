import 'package:flutter/material.dart';
import '../../state/currency_scope.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../core/design/client_tokens.dart';
import '../../l10n/app_localizations.dart';

class OrderReviewModal extends StatelessWidget {
  final Map<String, int> itemQuantities;
  final Map<String, dynamic> menuData;
  final double cartTotal;
  final String currency;
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

  AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: _l10n(context).orderReview,
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
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsetsDirectional.all(ClientTokens.space24),
                    child: Column(
                      children: [
                        _buildOrderItems(context),
                        const SizedBox(height: ClientTokens.space24),
                        _buildTotalSection(context),
                      ],
                    ),
                  ),
                ),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              _l10n(context).yourOrderReview,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: _l10n(context).close,
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

  Widget _buildTotalSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalItems = itemQuantities.values.fold(0, (sum, qty) => sum + qty);
    final l10n = _l10n(context);

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
                l10n.total,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: ClientTokens.space4),
              Text(
                '$totalItems ${totalItems > 1 ? l10n.items : l10n.item}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
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

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = _l10n(context);

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
              Expanded(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: onClose,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons
                            .arrow_back_rounded // RTL : flèche gauche (retour = sortir vers la gauche)
                        : Icons
                            .arrow_forward_rounded, // LTR : flèche droite (retour = sortir vers la droite)
                    size: 18,
                  ),
                  label: Text(
                    l10n.back,
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
                    child: Text(l10n.confirm),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOrder(BuildContext context) {
    HapticFeedback.lightImpact();

    SemanticsService.announce(
      _l10n(context).orderConfirmedAnnouncement,
      Directionality.of(context),
    );

    onConfirmOrder();
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      children: itemQuantities.entries.map((entry) {
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
