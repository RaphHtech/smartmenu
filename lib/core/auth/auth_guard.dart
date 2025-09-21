import 'package:firebase_auth/firebase_auth.dart';

class AuthGuard {
  static const List<String> _protectedPrefixes = [
    '/admin/dashboard',
    '/admin/menu',
    '/admin/settings'
  ];

  static const List<String> _authOnlyRoutes = [
    '/admin/login',
    '/admin/signup',
    '/admin/reset'
  ];

  static String? getRedirectRoute(String requestedPath) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthed = user != null;
    final normalizedPath = _normalizePath(requestedPath);

    if (!isAuthed && _isProtectedRoute(normalizedPath)) {
      return '/admin/login?returnUrl=${Uri.encodeComponent(normalizedPath)}';
    }

    if (isAuthed && _authOnlyRoutes.contains(normalizedPath)) {
      return '/admin/dashboard';
    }

    return null;
  }

  static String _normalizePath(String path) {
    return path.split('?')[0].replaceAll(RegExp(r'/+$'), '');
  }

  static bool _isProtectedRoute(String path) {
    return _protectedPrefixes.any((prefix) => path.startsWith(prefix));
  }

  static String validateReturnUrl(String? returnUrl) {
    if (returnUrl == null || returnUrl.isEmpty) return '/admin/dashboard';

    final decoded = Uri.decodeComponent(returnUrl);
    final normalized = _normalizePath(decoded);

    // Sécurité : uniquement URLs internes admin
    if (!normalized.startsWith('/admin/')) return '/admin/dashboard';

    // Éviter boucles sur auth routes
    if (_authOnlyRoutes.contains(normalized)) return '/admin/dashboard';

    return normalized;
  }
}
