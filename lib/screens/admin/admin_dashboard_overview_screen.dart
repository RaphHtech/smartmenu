import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/screens/admin/admin_dashboard_screen.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import 'menu_item_form_screen.dart';
import 'admin_media_screen.dart';
import 'admin_restaurant_info_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardOverviewScreen extends StatelessWidget {
  final String restaurantId;
  const AdminDashboardOverviewScreen({super.key, required this.restaurantId});

  Future<void> _previewMenu(BuildContext context) async {
    // 1) Récupère le restaurant principal de l’utilisateur
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final rid = userDoc.data()?['primary_restaurant_id'] as String?;
    if (rid == null || rid.isEmpty) return;

    // 2) (Optionnel mais robuste) Essaie d’utiliser un “code public” s’il existe
    //    dans restaurants/{rid}/info/details (p. ex. code, slug, shortCode).
    final detailsDoc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(rid)
        .collection('info')
        .doc('details')
        .get();

    final data = detailsDoc.data() ?? {};
    final code = (data['slug'] ?? data['code'] ?? data['shortCode'] ?? '')
        .toString()
        .trim();

    // 3) Construis l’URL /r/<identifiant> (par défaut on utilise le docId = rid)
    final base = Uri.base;
    final host = base.host;
    final port = base.hasPort ? base.port : null;

    // Utilise le "code" si présent, sinon l'id Firestore (rid)
    final path = '/r/${code.isNotEmpty ? code : rid}';
    final url = Uri(
      scheme: base.scheme,
      host: host,
      port: port,
      path: path,
      queryParameters: const {
        // facultatif: garde le flag si tu en as besoin côté MenuScreen
        'admin': 'true',
      },
    );

    // 4) Ouvre dans un nouvel onglet
    await launchUrl(url, webOnlyWindowName: '_blank');
  }

  Map<String, int> _calculateMetrics(List<QueryDocumentSnapshot> docs) {
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

    return {
      'total': total,
      'categories': categories.length,
      'withImage': withImage,
      'noImage': total - withImage,
      'signatures': signatures,
    };
  }

  Widget _buildMobileLayout(
      BuildContext context, Map<String, int> metrics, bool isTiny) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isTiny ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header contextuel
          _buildMobileHeader(context),
          const SizedBox(height: 20),

          // CTA principal
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context.pushAdminScreen(
                MenuItemFormScreen(restaurantId: restaurantId),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter un plat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTokens.primary500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Chips actions rapides
          _buildActionChips(context),
          const SizedBox(height: 24),

          // Micro-cartes 2x2
          _buildMicroCards(context, metrics),

          // Alerte conditionnelle
          if (metrics['noImage']! > 0) ...[
            const SizedBox(height: 20),
            _buildNoImageAlert(context, metrics['noImage']!, isTiny),
          ],

          const SizedBox(height: 20),
          // Aperçu client
          _buildClientPreview(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Map<String, int> metrics) {
    // Ton code actuel desktop
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Métriques desktop (ton code actuel)
          Wrap(
            spacing: AdminTokens.space16,
            runSpacing: AdminTokens.space16,
            children: [
              _MetricCard(
                  label: 'Plats',
                  value: '${metrics['total']}',
                  icon: Icons.restaurant),
              _MetricCard(
                  label: 'Catégories',
                  value: '${metrics['categories']}',
                  icon: Icons.category_outlined),
              _MetricCard(
                  label: 'Avec image',
                  value: '${metrics['withImage']}',
                  icon: Icons.image_outlined),
              _MetricCard(
                  label: 'Signature',
                  value: '${metrics['signatures']}',
                  icon: Icons.star_rate_rounded),
              if (metrics['noImage']! > 0)
                _MetricCard(
                  label: 'Sans image',
                  value: '${metrics['noImage']}',
                  icon: Icons.image_not_supported_outlined,
                  tone: _MetricTone.warning,
                ),
            ],
          ),
          const SizedBox(height: AdminTokens.space24),

          // Actions rapides desktop (ton code actuel)
          const Text('Actions rapides', style: AdminTypography.headlineLarge),
          const SizedBox(height: AdminTokens.space12),
          LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;
              return GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: AdminTokens.space16,
                  mainAxisSpacing: AdminTokens.space16,
                  mainAxisExtent: isWide ? 72.0 : 92.0, // ← Hauteur augmentée
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickAction(
                    icon: Icons.add,
                    label: 'Ajouter un plat',
                    onTap: () => context.pushAdminScreen(
                        MenuItemFormScreen(restaurantId: restaurantId)),
                  ),
                  _QuickAction(
                    icon: Icons.photo_library_outlined,
                    label: 'Gérer les médias',
                    onTap: () => context.pushAdminScreen(
                        AdminMediaScreen(restaurantId: restaurantId)),
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
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('info')
          .doc('details')
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final restaurantName = data['name'] as String? ?? 'Mon Restaurant';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AdminTokens.primary500, AdminTokens.primary600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tableau de bord',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                restaurantName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionChips(BuildContext context) {
    final actions = [
      {'icon': Icons.photo_library_outlined, 'label': 'Médias'},
      {'icon': Icons.info_outline, 'label': 'Infos resto'},
      {'icon': Icons.visibility_outlined, 'label': 'Prévisualiser'},
      {'icon': Icons.settings_outlined, 'label': 'Paramètres'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                switch (index) {
                  case 0: // Médias
                    context.pushAdminScreen(
                        AdminMediaScreen(restaurantId: restaurantId));
                    break;
                  case 1: // Infos resto
                    context.pushAdminScreen(AdminRestaurantInfoScreen(
                        restaurantId: restaurantId, showBack: true));
                    break;
                  case 2: // Prévisualiser
                    _previewMenu(context);
                    break;
                  case 3: // Paramètres
                    // TODO: navigation paramètres
                    break;
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(action['icon'] as IconData,
                        size: 20, color: AdminTokens.primary600),
                    const SizedBox(width: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMicroCards(BuildContext context, Map<String, int> metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MicroCard(
                icon: Icons.restaurant,
                value: '${metrics['total']}',
                label: 'Plats',
                color: AdminTokens.primary600,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroCard(
                icon: Icons.category_outlined,
                value: '${metrics['categories']}',
                label: 'Catégories',
                color: AdminTokens.primary600,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MicroCard(
                icon: Icons.image_outlined,
                value: '${metrics['withImage']}',
                label: 'Avec image',
                color: Colors.green.shade600,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroCard(
                icon: Icons.image_not_supported_outlined,
                value: '${metrics['noImage']}',
                label: 'Sans image',
                color: metrics['noImage']! > 0
                    ? Colors.orange.shade600
                    : AdminTokens.neutral400,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoImageAlert(
      BuildContext context, int noImageCount, bool isTiny) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
                '$noImageCount éléments sans image - ajoutez des visuels.'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigation vers l'écran menu via AdminShell
              context.pushAdminScreen(
                AdminDashboardScreen(restaurantId: restaurantId),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600),
            child:
                const Text('Corriger', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildClientPreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTokens.neutral200),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_outlined,
              color: AdminTokens.primary600, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Voir votre menu côté client'),
          ),
          ElevatedButton(
            onPressed: () => _previewMenu(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AdminTokens.primary500),
            child: const Text('Ouvrir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
          final metrics = _calculateMetrics(docs);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 481;
              final isTiny = constraints.maxWidth < 361;

              return isMobile
                  ? _buildMobileLayout(context, metrics, isTiny)
                  : _buildDesktopLayout(context, metrics);
            },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AdminTokens.primary600, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AdminTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MicroCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MicroCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminTokens.neutral200),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 12, color: AdminTokens.neutral600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
