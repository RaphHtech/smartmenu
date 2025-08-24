import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/menu/menu_screen.dart';

class AppRouter {
  static const String menu = '/';

  static final GoRouter router = GoRouter(
    initialLocation: menu,
    routes: [
      // Route unique du menu (web app)
      GoRoute(
        path: menu,
        name: 'menu',
        builder: (context, state) {
          final restaurantId =
              state.uri.queryParameters['restaurant'] ?? 'pizza_power_tlv';
          final tableNumber = state.uri.queryParameters['table'] ?? '1';
          return MenuScreen(
            restaurantId: restaurantId,
            tableNumber: tableNumber,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFFF97316), Color(0xFFFCD34D)],
          ),
        ),
        child: const Center(
          child: Text(
            'Page non trouvée',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
