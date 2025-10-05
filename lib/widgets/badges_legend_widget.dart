import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class BadgesLegendWidget extends StatelessWidget {
  const BadgesLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(maxWidth: 640),
      padding: const EdgeInsets.all(AdminTokens.space24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminTokens.radius24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AdminTokens.neutral300,
                borderRadius: BorderRadius.circular(AdminTokens.radius4),
              ),
            ),
          ),
          const SizedBox(height: AdminTokens.space20),

          // Titre
          Text(
            l10n.badgesGuide,
            style: AdminTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AdminTokens.neutral900,
            ),
          ),
          const SizedBox(height: AdminTokens.space8),

          Text(
            l10n.badgesGuideSubtitle,
            style: AdminTypography.bodyMedium.copyWith(
              color: AdminTokens.neutral600,
            ),
          ),

          const SizedBox(height: AdminTokens.space24),

          // Grid badges (responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              return isWide
                  ? _buildGridLayout(context)
                  : _buildListLayout(context);
            },
          ),

          const SizedBox(height: AdminTokens.space24),

          // Bouton fermer
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTokens.primary600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTokens.radius12),
                ),
              ),
              child: Text(
                l10n.understood,
                style: AdminTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final items = _getBadgeItems(context);

    return Wrap(
      spacing: AdminTokens.space12,
      runSpacing: AdminTokens.space12,
      children:
          items.map((item) => _buildBadgeCard(item, isCompact: true)).toList(),
    );
  }

  Widget _buildListLayout(BuildContext context) {
    final items = _getBadgeItems(context);

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AdminTokens.space12),
                child: _buildBadgeCard(item, isCompact: false),
              ))
          .toList(),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> item, {required bool isCompact}) {
    return Container(
      width: isCompact ? 300 : double.infinity,
      padding: const EdgeInsets.all(AdminTokens.space16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        border: Border.all(color: AdminTokens.neutral200),
        boxShadow: AdminTokens.shadowMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container avec gradient
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item['color'] as Color,
                  (item['color'] as Color).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AdminTokens.radius8),
              boxShadow: [
                BoxShadow(
                  color: (item['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AdminTokens.space12),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: AdminTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AdminTokens.neutral900,
                  ),
                ),
                const SizedBox(height: AdminTokens.space4),
                Text(
                  item['desc'] as String,
                  style: AdminTypography.bodySmall.copyWith(
                    color: AdminTokens.neutral600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getBadgeItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      {
        'badge': 'populaire',
        'title': l10n.badgePopular,
        'desc': l10n.badgeDescPopular,
        'color': const Color(0xFFFF8C00),
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'badge': 'nouveau',
        'title': l10n.badgeNew,
        'desc': l10n.badgeDescNew,
        'color': const Color(0xFF4F46E5),
        'icon': Icons.fiber_new_rounded,
      },
      {
        'badge': 'spécialité',
        'title': l10n.badgeSpecialty,
        'desc': l10n.badgeDescSpecialty,
        'color': const Color(0xFF7C3AED),
        'icon': Icons.restaurant_rounded,
      },
      {
        'badge': 'chef',
        'title': l10n.badgeChef,
        'desc': l10n.badgeDescChef,
        'color': const Color(0xFF0891B2),
        'icon': Icons.star_rounded,
      },
      {
        'badge': 'saisonnier',
        'title': l10n.badgeSeasonal,
        'desc': l10n.badgeDescSeasonal,
        'color': const Color(0xFF059669),
        'icon': Icons.eco_rounded,
      },
    ];
  }
}
