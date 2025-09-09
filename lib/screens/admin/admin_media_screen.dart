// lib/screens/admin/admin_media_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class AdminMediaScreen extends StatelessWidget {
  final String restaurantId;

  const AdminMediaScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Médias',
      restaurantId: restaurantId,
      activeRoute: '/media',
      breadcrumbs: const ['Dashboard', 'Médias'],
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AdminTokens.neutral100,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: AdminTokens.neutral400,
                ),
              ),
              const SizedBox(height: AdminTokens.space24),
              const Text(
                'Gestion des médias',
                style: AdminTypography.displaySmall,
              ),
              const SizedBox(height: AdminTokens.space8),
              Text(
                'Gérez vos images, logos et fichiers média',
                style: AdminTypography.bodyMedium.copyWith(
                  color: AdminTokens.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AdminTokens.space32),
              Container(
                padding: const EdgeInsets.all(AdminTokens.space20),
                decoration: BoxDecoration(
                  color: AdminTokens.primary50,
                  borderRadius: BorderRadius.circular(AdminTokens.radius12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.construction_outlined,
                      color: AdminTokens.primary600,
                      size: 32,
                    ),
                    const SizedBox(height: AdminTokens.space12),
                    Text(
                      'Fonctionnalité en développement',
                      style: AdminTypography.headlineSmall.copyWith(
                        color: AdminTokens.primary600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
