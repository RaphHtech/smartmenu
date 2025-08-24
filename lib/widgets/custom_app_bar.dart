import 'package:flutter/material.dart';
import 'package:smartmenu_app/core/constants/text_styles.dart';
import '../core/constants/colors.dart';
import '../models/restaurant.dart';
import '../providers/language_provider.dart';

class CustomAppBar extends StatelessWidget {
  final Restaurant restaurant;
  final LanguageProvider languageProvider;
  final VoidCallback onCallServer;

  const CustomAppBar({
    super.key,
    required this.restaurant,
    required this.languageProvider,
    required this.onCallServer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Gauche : logo + "SmartMenu"
            const Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant, color: AppColors.textPremium),
                  SizedBox(width: 8),
                  Text('SmartMenu',
                      style: TextStyle(
                        color: AppColors.textPremium,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      )),
                ],
              ),
            ),

            // Centre : Titre restaurant
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    restaurant.name, // "PIZZA POWER"
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles
                        .headerTitle, // défini dans text_styles.dart
                  ),
                ),
              ),
            ),

            // Droite : bouton "Serveur/Waiter"
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onCallServer,
                icon: const Icon(Icons.call),
                label: Text(languageProvider.translate('call_server')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.waiterPillBg,
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  elevation: 4,
                  minimumSize: const Size(0, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
