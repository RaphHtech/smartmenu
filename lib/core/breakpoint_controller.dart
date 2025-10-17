import 'package:flutter/foundation.dart';

/// Contrôleur de breakpoint avec hystérésis large pour éviter les tremblotements
class BreakpointController extends ValueNotifier<bool> {
  BreakpointController(super.initial);

  // Marges très larges pour stabilité maximale
  static const double desktopThreshold = 1100; // Active desktop
  static const double mobileThreshold = 950; // Retour mobile

  void update(double width) {
    // Debug optionnel
    // debugPrint('Breakpoint update: width=$width, current=$value');

    if (value && width < mobileThreshold) {
      value = false; // Passage en mobile
    } else if (!value && width >= desktopThreshold) {
      value = true; // Passage en desktop
    }
    // Entre 950 et 1100 : on garde l'état actuel (zone d'hystérésis)
  }
}
