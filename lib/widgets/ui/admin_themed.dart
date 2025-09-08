import 'package:flutter/material.dart';
import '../../core/design/admin_theme.dart';

/// Wrapper pour appliquer le thème admin premium uniquement dans la zone admin
/// Usage: wrap tous les écrans admin avec AdminThemed(child: YourAdminScreen())
class AdminThemed extends StatelessWidget {
  final Widget child;

  const AdminThemed({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AdminTheme.theme,
      child: child,
    );
  }
}

/// Extension utile pour simplifier la navigation admin
extension AdminNavigation on BuildContext {
  /// Navigate vers un écran admin avec thème automatique
  Future<T?> pushAdminScreen<T extends Object?>(Widget screen) {
    return Navigator.of(this).push<T>(
      MaterialPageRoute(
        builder: (_) => AdminThemed(child: screen),
      ),
    );
  }

  /// Replace vers un écran admin avec thème automatique
  Future<T?> pushReplacementAdminScreen<T extends Object?, TO extends Object?>(
      Widget screen) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(
        builder: (_) => AdminThemed(child: screen),
      ),
    );
  }
}
