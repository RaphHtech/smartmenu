import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../../core/design/client_tokens.dart';
import '../../state/currency_scope.dart';

class CartFloatingWidget extends StatefulWidget {
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
  State<CartFloatingWidget> createState() => _CartFloatingWidgetState();
}

class _CartFloatingWidgetState extends State<CartFloatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ClientTokens.durationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(CartFloatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animation d'apparition quand panier passe de 0→1
    if (oldWidget.cartItemCount == 0 && widget.cartItemCount > 0) {
      _animationController.forward();
      HapticFeedback.selectionClick();
    }

    // Animation de disparition quand panier devient vide
    if (oldWidget.cartItemCount > 0 && widget.cartItemCount == 0) {
      _animationController.reverse();
    }

    // Micro-animation + annonce SR quand quantité change
    if (oldWidget.cartItemCount != widget.cartItemCount &&
        widget.cartItemCount > 0) {
      _animationController.forward(from: 0.98);

      // Annonce screen reader non-verbeuse
      SemanticsService.announce(
        'Commande ${widget.cartItemCount}, total ${context.money(widget.cartTotal)}',
        Directionality.of(context),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cartItemCount <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Semantics(
            button: true,
            label: 'Finaliser ma commande, ${widget.cartItemCount} '
                '${widget.cartItemCount > 1 ? 'articles' : 'article'}, '
                'total ${context.money(widget.cartTotal)}',
            child: Tooltip(
              message:
                  'Finaliser ma commande • ${context.money(widget.cartTotal)}',
              child: Material(
                color: colorScheme.primary,
                elevation: ClientTokens.elevationFab,
                borderRadius: BorderRadius.circular(ClientTokens.radius20),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onViewOrder();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ClientTokens.space24,
                      vertical: ClientTokens.space16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          size: 24,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: ClientTokens.space12),
                        Expanded(
                          child: Text(
                            widget.cartItemCount > 1
                                ? 'Commande (${widget.cartItemCount})'
                                : 'Commande (1)',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                              letterSpacing: 0.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: ClientTokens.space16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ClientTokens.space12,
                            vertical: ClientTokens.space4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(ClientTokens.radius12),
                          ),
                          child: Text(
                            context.money(widget.cartTotal),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: ClientTokens.space8),
                        Icon(
                          isRTL
                              ? Icons.arrow_back_rounded
                              : Icons.arrow_forward_rounded,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
