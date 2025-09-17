import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import 'menu_item_form_screen.dart';
import 'admin_media_screen.dart';
import 'admin_restaurant_info_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardOverviewScreen extends StatelessWidget {
  final String restaurantId;
  const AdminDashboardOverviewScreen({super.key, required this.restaurantId});

  Future<void> _previewMenu(BuildContext context) async {
    final uri = Uri.base;
    final url =
        '${uri.scheme}://${uri.host}:${uri.port}/r/$restaurantId?admin=true';
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Dashboard',
      restaurantId: restaurantId,
      activeRoute: '/dashboard',
      breadcrumbs: const ['Dashboard'],
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .collection('menus')
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erreur: ${snap.error}'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];
          // ---- métriques
          final total = docs.length;
          final categories = <String>{};
          int withImage = 0;
          int signatures = 0;

          for (final d in docs) {
            final m = d.data() as Map<String, dynamic>;
            final cat = (m['category'] ?? '').toString().trim();
            if (cat.isNotEmpty) categories.add(cat);

            final img =
                ((m['imageUrl'] ?? m['image'] ?? m['photoUrl'] ?? '') as String)
                    .trim();
            if (img.isNotEmpty) withImage++;

            if (m['signature'] == true || m['hasSignature'] == true) {
              signatures++;
            }
          }

          final catsCount = categories.length;
          final noImage = total - withImage;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AdminTokens.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- métriques
                Wrap(
                  spacing: AdminTokens.space16,
                  runSpacing: AdminTokens.space16,
                  children: [
                    _MetricCard(
                        label: 'Plats',
                        value: '$total',
                        icon: Icons.restaurant),
                    _MetricCard(
                        label: 'Catégories',
                        value: '$catsCount',
                        icon: Icons.category_outlined),
                    _MetricCard(
                        label: 'Avec image',
                        value: '$withImage',
                        icon: Icons.image_outlined),
                    _MetricCard(
                        label: 'Signature',
                        value: '$signatures',
                        icon: Icons.star_rate_rounded),
                    if (noImage > 0)
                      _MetricCard(
                        label: 'Sans image',
                        value: '$noImage',
                        icon: Icons.image_not_supported_outlined,
                        tone: _MetricTone.warning,
                      ),
                  ],
                ),

                const SizedBox(height: AdminTokens.space24),

                // --- actions rapides
                const Text('Actions rapides',
                    style: AdminTypography.headlineLarge),
                const SizedBox(height: AdminTokens.space12),
                LayoutBuilder(
                  builder: (context, c) {
                    final isWide = c.maxWidth >= 900; // desktop
                    final crossAxisCount = isWide ? 4 : 2;
                    final tileHeight =
                        isWide ? 64.0 : 72.0; // assez haut pour 2 lignes

                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AdminTokens.space16,
                        mainAxisSpacing: AdminTokens.space16,
                        mainAxisExtent:
                            tileHeight, // ✅ hauteur fixe, fini les textes coupés
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _QuickAction(
                          icon: Icons.add,
                          label: 'Ajouter un plat',
                          onTap: () => context.pushAdminScreen(
                            MenuItemFormScreen(restaurantId: restaurantId),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.photo_library_outlined,
                          label: 'Gérer les médias',
                          onTap: () => context.pushAdminScreen(
                            AdminMediaScreen(restaurantId: restaurantId),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.info_outline,
                          label: 'Modifier les infos',
                          onTap: () => context.pushAdminScreen(
                            AdminRestaurantInfoScreen(
                                restaurantId: restaurantId, showBack: true),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.visibility_outlined,
                          label: 'Prévisualiser le menu',
                          onTap: () => _previewMenu(context),
                        ),
                      ],
                    );
                  },
                ),

                // (optionnel) Derniers plats / anomalies à venir en Phase 4+
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _MetricTone { normal, warning }

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final _MetricTone tone;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.tone = _MetricTone.normal,
  });

  @override
  Widget build(BuildContext context) {
    final isWarn = tone == _MetricTone.warning;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarn ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        border: Border.all(
            color: isWarn ? Colors.orange.shade200 : AdminTokens.neutral200),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isWarn ? Colors.orange.shade600 : AdminTokens.primary600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AdminTypography.displaySmall),
                const SizedBox(height: 2),
                Text(label,
                    style: AdminTypography.bodyMedium
                        .copyWith(color: AdminTokens.neutral600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AdminTokens.neutral200),
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 56, // garantit une ligne
            maxHeight: 88, // laisse respirer si 2 lignes
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: AdminTokens.primary600, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2, // 2 lignes possibles
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: AdminTypography.bodyLarge
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
