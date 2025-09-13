import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/gradient_text_widget.dart';

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                Expanded(
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
                                    horizontal: 16, vertical: 10),
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
                              const SizedBox(width: 8),
                              GradientText(
                                restaurantName.isEmpty
                                    ? 'RESTAURANT'
                                    : restaurantName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  height: 1.05,
                                ),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD179),
                                    Color(0xFFFFA45B)
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
                Expanded(
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
                            horizontal: 20, vertical: 12),
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
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback(initials),
        ),
      );
    }
    return fallback(initials);
  }
}
