import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../widgets/gradient_text_widget.dart';

class AppHeaderWidget extends StatelessWidget {
  final VoidCallback onServerCall;

  const AppHeaderWidget({
    Key? key,
    required this.onServerCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      toolbarHeight: 96, // hauteur fixe de la bannière (essaie 88—92)
      collapsedHeight: 96, // même hauteur quand "collapsée"
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // blur 10px
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: const BoxDecoration(
              color: AppColors.headerOverlay, // rgba(0,0,0,0.20)
              border: Border(
                bottom:
                    BorderSide(color: AppColors.headerDivider, width: 1), // 10%
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gauche : emoji + "SmartMenu"
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      // évite tout dépassement côté gauche
                      fit: BoxFit.scaleDown,
                      child: Row(
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
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ---- Colonne centre : 2 lignes, centrées ----
                const Expanded(
                  flex: 2,
                  child: Center(
                    child: GradientText(
                      'PIZZA\nPOWER',
                      gradient: AppColors.titleGradient, // blanc → jaune
                      style: TextStyle(
                        fontSize: 24, // 22—24 selon ton goût
                        fontWeight: FontWeight.w800,
                        height: 1.10, // interligne serré
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ),
                // Droite : bouton "Serveur"
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      // rétrécit le bouton si l'espace manque
                      fit: BoxFit.scaleDown,
                      child: ElevatedButton.icon(
                        onPressed: onServerCall,
                        icon: const Icon(Icons.phone_outlined, size: 18),
                        label: const Text('Serveur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.primary,
                          shape: const StadiumBorder(), // pilule
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          minimumSize: const Size(0, 44), // min-height 44px
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.w700),
                        ),
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
}
