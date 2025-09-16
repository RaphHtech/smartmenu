import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumAppHeaderWidget extends StatelessWidget {
  final VoidCallback onServerCall;
  final String restaurantName;
  final String? logoUrl;
  final String? tagline;
  final bool showAdminReturn;
  final VoidCallback? onAdminReturn;

  const PremiumAppHeaderWidget({
    super.key,
    required this.onServerCall,
    required this.restaurantName,
    this.tagline,
    this.showAdminReturn = false,
    this.onAdminReturn,
    this.logoUrl,
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
    final showTagline = ((!isMobile) || (isMobile && screenWidth >= 360)) &&
        (tagline?.isNotEmpty == true);

    return SliverAppBar(
      pinned: true,
      toolbarHeight: showTagline ? 72 : (isMobile ? 64 : 80),
      collapsedHeight: showTagline ? 72 : (isMobile ? 64 : 80),
      backgroundColor: Colors.transparent,
      leadingWidth: isMobile ? 80 : 120,
      leading: showAdminReturn
          ? Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: 44, minHeight: 36, maxHeight: 36),
                child: _buildAdminReturnButton(),
              ),
            )
          : const SizedBox.shrink(),
      centerTitle: true,
      title: _buildRestaurantBranding(showTagline: showTagline),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: isMobile ? 12 : 20),
          child: _buildCallButton(compact: screenWidth < 360),
        ),
      ],
      flexibleSpace: ClipRect(
        child: isMobile
            ? Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF000000).withOpacity(0.75),
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
                    color: const Color(0xFF000000).withOpacity(0.7),
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
    );
  }

  Widget _buildAdminReturnButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 76; // seuil mobile étroit
        return ConstrainedBox(
          constraints:
              const BoxConstraints(minWidth: 44, minHeight: 44), // a11y
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAdminReturn,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 12,
                    vertical: 10,
                  ),
                  child: compact
                      ? const Icon(Icons.arrow_back_ios,
                          size: 12, color: Colors.white)
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_ios,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRestaurantBranding({required bool showTagline}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand lockup
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
                  height: 1.0, // pas d'extra leading
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

        // Tagline conditionnelle
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text(
            tagline!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.70),
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
            color: _generateStableColor(restaurantName).withOpacity(0.3),
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
              color: Colors.black.withOpacity(0.2),
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

  Widget _buildCallButton({bool compact = false}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(compact ? 16 : 6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onServerCall,
          borderRadius: BorderRadius.circular(compact ? 16 : 6),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 10 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.support_agent,
                  size: 14,
                  color: Colors.white,
                ),
                if (!compact) ...[
                  const SizedBox(width: 4),
                  const Text(
                    'Serveur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
