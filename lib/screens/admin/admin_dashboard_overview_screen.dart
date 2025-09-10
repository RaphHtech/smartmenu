import 'package:flutter/material.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class AdminDashboardOverviewScreen extends StatelessWidget {
  final String restaurantId;

  const AdminDashboardOverviewScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Dashboard',
      restaurantId: restaurantId,
      activeRoute: '/dashboard',
      breadcrumbs: const ['Dashboard'],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue sur SmartMenu',
              style: AdminTypography.displayMedium,
            ),
            const SizedBox(height: AdminTokens.space24),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Gérer le menu',
                    'Ajouter ou modifier des plats',
                    Icons.restaurant_menu,
                    () => Navigator.of(context).pushNamed('/menu'),
                  ),
                ),
                const SizedBox(width: AdminTokens.space16),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Paramètres',
                    'Configuration restaurant',
                    Icons.settings,
                    () => Navigator.of(context).pushNamed('/settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        child: Padding(
          padding: const EdgeInsets.all(AdminTokens.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: AdminTokens.primary600),
              const SizedBox(height: AdminTokens.space12),
              Text(title, style: AdminTypography.headlineMedium),
              const SizedBox(height: AdminTokens.space8),
              Text(subtitle, style: AdminTypography.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
