import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartmenu_app/services/language_service.dart';
import 'package:smartmenu_app/state/language_provider.dart';
import '../l10n/app_localizations.dart';

class PremiumAppHeaderWidget extends StatelessWidget {
  final String restaurantName;
  final String? logoUrl;
  final String? tagline;
  final bool showAdminReturn;
  final VoidCallback? onAdminReturn;
  final VoidCallback? onBadgesInfo;

  const PremiumAppHeaderWidget({
    super.key,
    required this.restaurantName,
    this.tagline,
    this.showAdminReturn = false,
    this.onAdminReturn,
    this.logoUrl,
    this.onBadgesInfo,
  });

  Color _generateStableColor(String name) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      sum += name.codeUnitAt(i);
    }
    return colors[sum % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final showTagline = !isMobile && (tagline?.isNotEmpty == true);

    // LARGEURS FIXES pour centrage parfait
    final double sideWidth = showAdminReturn ? 100.0 : 56.0;

    return SliverAppBar(
      pinned: true,
      toolbarHeight: showTagline ? 72 : (isMobile ? 64 : 80),
      collapsedHeight: showTagline ? 72 : (isMobile ? 64 : 80),
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: sideWidth,
      leading: Container(
        width: sideWidth,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: showAdminReturn
            ? _buildAdminButton()
            : _buildLanguageButton(context),
      ),
      centerTitle: true,
      title: _buildRestaurantBranding(showTagline: showTagline),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          onPressed: onBadgesInfo,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: IgnorePointer(
        ignoring: true,
        child: ClipRect(
          child: isMobile
              ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000).withValues(alpha: 0.75),
                    border: const Border(
                      bottom: BorderSide(
                        color: Color(0x20FFFFFF),
                        width: 0.5,
                      ),
                    ),
                  ),
                )
              : BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000).withValues(alpha: 0.7),
                      border: const Border(
                        bottom: BorderSide(
                          color: Color(0x20FFFFFF),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.white, size: 24),
      tooltip: AppLocalizations.of(context)!.commonLanguage,
      offset: const Offset(0, 50),
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      itemBuilder: (BuildContext context) {
        return LanguageService.supportedLocales.map((Locale locale) {
          final isSelected = locale == currentLocale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(
                  LanguageService.getFlag(locale.languageCode),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  LanguageService.getNativeName(locale.languageCode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (Locale locale) {
        languageProvider.setLocale(locale);
      },
    );
  }

  Widget _buildAdminButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAdminReturn,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text('Admin',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantBranding({required bool showTagline}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (context) =>
                  _buildLogo(MediaQuery.of(context).size.width),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                restaurantName.isEmpty ? 'Restaurant' : restaurantName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                strutStyle: const StrutStyle(height: 1.0, leading: 0),
              ),
            ),
          ],
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            tagline!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            strutStyle: const StrutStyle(height: 1.0, leading: 0),
          ),
        ],
      ],
    );
  }

  Widget _buildLogo(double screenWidth) {
    String initials = restaurantName.trim().isEmpty
        ? 'R'
        : restaurantName
            .trim()
            .split(RegExp(r'\s+'))
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    Widget fallback = Container(
      width: (screenWidth < 360) ? 32 : 36,
      height: (screenWidth < 360) ? 32 : 36,
      decoration: BoxDecoration(
        color: _generateStableColor(restaurantName),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _generateStableColor(restaurantName).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );

    if (logoUrl != null &&
        logoUrl!.trim().isNotEmpty &&
        logoUrl!.toLowerCase() != 'null') {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            logoUrl!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          ),
        ),
      );
    }
    return fallback;
  }
}
