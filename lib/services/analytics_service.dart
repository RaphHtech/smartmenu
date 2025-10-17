import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  static final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
    level: kDebugMode ? Level.info : Level.off,
  );

  static void logMenuOpen(String restaurantId, {String? tableId}) {
    _logger.i('menu_open',
        error: {'restaurantId': restaurantId, 'tableId': tableId});
    // TODO: intégration Firebase Analytics
  }

  static void logAddToCart(String restaurantId, String itemName,
      {String? tableId}) {
    _logger.i('add_to_cart', error: {
      'restaurantId': restaurantId,
      'itemName': itemName,
      'tableId': tableId
    });
    // TODO: intégration Firebase Analytics
  }
}
