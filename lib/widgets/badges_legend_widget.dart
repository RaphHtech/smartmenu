import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class BadgesLegendWidget extends StatelessWidget {
  const BadgesLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : 420, // ← Plus compact
        maxHeight: MediaQuery.of(context).size.height * 0.75, // ← Max 75%
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AdminTokens.radius16),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Titre compact
          Text(
            l10n.badgesGuide,
            style: AdminTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AdminTokens.neutral900,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            l10n.badgesGuideSubtitle,
            style: AdminTypography.labelSmall.copyWith(
              color: AdminTokens.neutral600,
            ),
          ),

          const SizedBox(height: 16),

          // Liste badges - scrollable si nécessaire
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: _getBadgeItems(context)
                    .map((item) => _buildBadgeRow(item))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bouton fermer compact
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTokens.primary600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTokens.radius8),
                ),
              ),
              child: Text(
                l10n.understood,
                style: AdminTypography.bodySmall.copyWith(
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

  Widget _buildBadgeRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon mini
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 14,
              color: item['color'] as Color,
            ),
          ),
          const SizedBox(width: 10),

          // Texte ultra-compact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: AdminTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AdminTokens.neutral900,
                  ),
                ),
                Text(
                  item['desc'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminTokens.neutral600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
        'title': l10n.badgePopular,
        'desc': l10n.badgeDescPopular,
        'color': const Color(0xFFFF8C00),
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'title': l10n.badgeNew,
        'desc': l10n.badgeDescNew,
        'color': const Color(0xFF4F46E5),
        'icon': Icons.fiber_new_rounded,
      },
      {
        'title': l10n.badgeSpecialty,
        'desc': l10n.badgeDescSpecialty,
        'color': const Color(0xFF7C3AED),
        'icon': Icons.restaurant_rounded,
      },
      {
        'title': l10n.badgeChef,
        'desc': l10n.badgeDescChef,
        'color': const Color(0xFF0891B2),
        'icon': Icons.star_rounded,
      },
      {
        'title': l10n.badgeSeasonal,
        'desc': l10n.badgeDescSeasonal,
        'color': const Color(0xFF059669),
        'icon': Icons.eco_rounded,
      },
    ];
  }
}
