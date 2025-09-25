import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smartmenu_app/core/design/client_tokens.dart';
import '../../core/constants/colors.dart';

class AppHeaderWidget extends StatelessWidget {
  final VoidCallback onServerCall;
  final String restaurantName;
  final String? logoUrl;
  final bool showAdminReturn;
  final VoidCallback? onAdminReturn;

  const AppHeaderWidget({
    super.key,
    required this.onServerCall,
    required this.restaurantName,
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
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 96,
      collapsedHeight: 96,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
                ClientTokens.space24,
                ClientTokens.space16,
                ClientTokens.space24,
                ClientTokens.space16),
            decoration: const BoxDecoration(
              color: AppColors.headerOverlay,
              border: Border(
                bottom: BorderSide(color: AppColors.headerDivider, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gauche : logo OU bouton retour admin
                SizedBox(
                  width: 80,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: showAdminReturn
                        ? Tooltip(
                            message: 'Retour admin',
                            child: ElevatedButton.icon(
                              onPressed: onAdminReturn,
                              icon: const Icon(Icons.arrow_back, size: 16),
                              label: const Text('Admin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ClientTokens.space16,
                                    vertical: 10),
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🍽️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 8),
                              Text(
                                'SmartMenu',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Centre : nom restaurant
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _brandAvatar(restaurantName, logoUrl),
                              const SizedBox(width: ClientTokens.space8),
                              Text(
                                restaurantName.isEmpty
                                    ? 'RESTAURANT'
                                    : restaurantName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3, // ← Réduit
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Color.fromRGBO(
                                          0, 0, 0, 0.15), // ← Plus subtil
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Droite : bouton Serveur
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: onServerCall,
                      icon: const Icon(Icons.phone_outlined, size: 18),
                      label: const Text('Serveur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: ClientTokens.space24,
                            vertical: ClientTokens.space12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandAvatar(String name, String? url) {
    Widget fallback(String initials) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _generateStableColor(name),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        );

    String initials = name.trim().isEmpty
        ? '🍽'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    if (url != null && url.trim().isNotEmpty && url.toLowerCase() != 'null') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            url,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback(initials),
          ),
        ),
      );
    }
    return fallback(initials);
  }
}
