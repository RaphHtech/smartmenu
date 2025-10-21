import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartmenu_app/core/constants/colors.dart';
import 'package:smartmenu_app/services/translation_helper.dart';
import '../../state/currency_scope.dart';
import '../../l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

// petit helper robuste
double _parsePrice(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final s = value
      .toString()
      .replaceAll(RegExp(r'[^\d,.\-]'), '')
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

  const MenuItem({
    super.key,
    required this.pizza,
    required this.quantity,
    required this.onAddToCart,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    this.onSetQuantity,
  });

  AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;
  void _openDetails(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    final String name = TranslationHelper.getTranslatedField(
      pizza,
      locale,
      'name',
      restaurantDefaultLocale: 'he',
    );
    final String description = TranslationHelper.getTranslatedField(
      pizza,
      locale,
      'description',
      restaurantDefaultLocale: 'he',
    );
    final double unitPrice = _parsePrice(pizza['price']);
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
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Material(
              elevation: 0,
              color: AppColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Photo + texte
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      // Photo avec gradient et texte OPTIMISÉ
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Photo
                            Hero(
                              tag: 'dish-${pizza['id'] ?? pizza['name']}',
                              child: img.isEmpty
                                  ? _categoryPlaceholder(
                                      (pizza['category'] ?? '').toString())
                                  : Image.network(
                                      img,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _categoryPlaceholder(
                                              (pizza['category'] ?? '')
                                                  .toString()),
                                    ),
                            ),

                            // Gradient SUBTIL pour lisibilité
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.75),
                                    ],
                                    stops: const [
                                      0.4,
                                      1.0
                                    ], // Commence plus haut
                                  ),
                                ),
                              ),
                            ),

                            // Texte COMPACT en bas
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: quantity == 0 ? 90 : 180, // ✅ DYNAMIQUE !
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                      alpha: 0.4), // Scrim additionnel
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Titre COMPACT
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.2,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                            color: Colors.black87,
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // Description COMPACTE
                                    if (description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white
                                              .withValues(alpha: 0.95),
                                          height: 1.3,
                                          shadows: const [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 3,
                                              color: Colors.black87,
                                            ),
                                          ],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bouton fixe en bas
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildQuantitySelector(
                              unitPrice, context, name, quantity),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuantitySelector(double unitPrice, BuildContext context,
      String name, int currentQuantity) {
    if (currentQuantity == 0) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
            if (onSetQuantity != null) {
              onSetQuantity!(name, unitPrice, 1);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          child: Text(
            _l10n(context).add,
          ),
        ),
      );
    }

    return _QuantityStepperWidget(
      initialQuantity: currentQuantity,
      unitPrice: unitPrice,
      itemName: name,
      currency: CurrencyScope.of(context).code,
      onSetQuantity: onSetQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).languageCode;
    final String name = TranslationHelper.getTranslatedField(
      pizza,
      locale,
      'name',
      restaurantDefaultLocale: 'he',
    );
    final String description = TranslationHelper.getTranslatedField(
      pizza,
      locale,
      'description',
      restaurantDefaultLocale: 'he',
    );
    final double unitPrice = _parsePrice(pizza['price']);
    final String priceText = context.money(unitPrice);

    final String img = () {
      final candidates = [pizza['imageUrl'], pizza['image'], pizza['photoUrl']];
      for (final candidate in candidates) {
        final s = (candidate?.toString() ?? '').trim();
        if (s.isNotEmpty && s.toLowerCase() != 'null') return s;
      }
      return '';
    }();

    return _buildCompactBand(
      context,
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

  Widget _buildCompactBand(
    BuildContext context,
    String name,
    String description,
    String priceText,
    double unitPrice, {
    String? imageUrl,
    String? category,
    VoidCallback? onTap,
    VoidCallback? onAdd,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'dish-${pizza['id'] ?? pizza['name']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: (imageUrl == null || imageUrl.isEmpty)
                          ? _categoryPlaceholder(category)
                          : Image.network(imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _categoryPlaceholder(category)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          ..._buildBadges(context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            priceText,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 0.5,
                                    ),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              onAdd?.call();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnColor,
                              minimumSize: const Size(96, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: const StadiumBorder(),
                              elevation: 0,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            child: Text(_l10n(context).add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryPlaceholder(String? category) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBadges(BuildContext context) {
    final List<String> badges = List<String>.from(pizza['badges'] ?? []);
    if (badges.isEmpty) return [];

    final displayBadge = badges.first;
    return [
      _badgePill(context, _getBadgeText(context, displayBadge),
          tone: displayBadge == 'populaire' ? 'tertiary' : 'primary')
    ];
  }

  Widget _badgePill(BuildContext context, String label,
      {required String tone}) {
    // Détermine les couleurs selon le type de badge
    final Color bg;
    final Color fg;
    final IconData icon;

    final l10n = _l10n(context);

    if (label == l10n.badgePopular) {
      bg = AppColors.badgePopularBg;
      fg = AppColors.badgePopular;
      icon = Icons.star_rounded;
    } else if (label == l10n.badgeNew) {
      bg = AppColors.badgeNewBg;
      fg = AppColors.badgeNew;
      icon = Icons.fiber_new_rounded;
    } else if (label == l10n.badgeSpecialty) {
      bg = AppColors.badgeSpecialtyBg;
      fg = AppColors.badgeSpecialty;
      icon = Icons.restaurant_rounded;
    } else if (label == l10n.badgeChef) {
      bg = AppColors.badgeChefBg;
      fg = AppColors.badgeChef;
      icon = Icons.star_rounded;
    } else if (label == l10n.badgeSeasonal) {
      bg = AppColors.badgeSeasonalBg;
      fg = AppColors.badgeSeasonal;
      icon = Icons.eco_rounded;
    } else {
      // Fallback
      bg = AppColors.grey200;
      fg = AppColors.grey700;
      icon = Icons.label_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }

  String _getBadgeText(BuildContext context, String badge) {
    final l10n = _l10n(context);
    switch (badge) {
      case 'populaire':
        return l10n.badgePopular;
      case 'nouveau':
        return l10n.badgeNew;
      case 'spécialité':
        return l10n.badgeSpecialty;
      case 'chef':
        return l10n.badgeChef;
      case 'saisonnier':
        return l10n.badgeSeasonal;
      case 'signature':
        return l10n.badgeSignature;
      default:
        return badge;
    }
  }
}

class _QuantityStepperWidget extends StatefulWidget {
  final int initialQuantity;
  final double unitPrice;
  final String itemName;
  final String currency;
  final Function(String itemName, double price, int quantity)? onSetQuantity;

  const _QuantityStepperWidget({
    required this.initialQuantity,
    required this.unitPrice,
    required this.itemName,
    required this.currency,
    this.onSetQuantity,
  });

  @override
  State<_QuantityStepperWidget> createState() => _QuantityStepperWidgetState();
}

class _QuantityStepperWidgetState extends State<_QuantityStepperWidget> {
  late int localQuantity;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    localQuantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.initialQuantity > 0;
    final isInDeleteMode = localQuantity == 0;

    return Column(
      children: [
        // Stepper ULTRA COMPACT sur une seule ligne tendue
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _qtyButtonUltraCompact(context, Icons.remove_rounded,
                  onTap: () => setState(() {
                        if (localQuantity > 1) {
                          localQuantity--;
                        } else if (localQuantity == 1) {
                          localQuantity = 0;
                        }
                      })),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '$localQuantity',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _qtyButtonUltraCompact(context, Icons.add_rounded,
                  onTap: localQuantity < 20
                      ? () => setState(() => localQuantity++)
                      : null),
            ],
          ),
        ),

        // Message suppression - COMPACT
        if (isInDeleteMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Text(
              _l10n.removeThisItem,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          const SizedBox(height: 8),

        // Bouton principal - MOINS DE PADDING
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              if (widget.onSetQuantity != null) {
                widget.onSetQuantity!(
                    widget.itemName, widget.unitPrice, localQuantity);
              }
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  isInDeleteMode ? AppColors.error : AppColors.primary,
              foregroundColor: AppColors.textOnColor,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            child: Text(
              isInDeleteMode
                  ? _l10n.removeFromCart
                  : isUpdate
                      ? _l10n.update
                      : _l10n.add,
            ),
          ),
        ),
      ],
    );
  }

// Bouton ULTRA compact - 32x32px
  Widget _qtyButtonUltraCompact(BuildContext context, IconData icon,
      {VoidCallback? onTap}) {
    final isAdd = icon == Icons.add_rounded;
    return Semantics(
      button: true,
      label: isAdd ? _l10n.increaseQuantity : _l10n.decreaseQuantity,
      child: Material(
        color: AppColors.grey100,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              icon,
              size: 16,
              color: onTap == null ? AppColors.grey400 : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
