import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_restaurant_info_screen.dart';
import '../../core/constants/colors.dart';
import 'menu_item_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../widgets/ui/admin_shell.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String restaurantId;

  const AdminDashboardScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _currency = 'ILS';

  String _emojiFor(String category) {
    switch (category) {
      case 'Pizzas':
        return '🍕';
      case 'Entrées':
        return '🥗';
      case 'Pâtes':
        return '🍝';
      case 'Desserts':
        return '🍰';
      case 'Boissons':
        return '🹹';
      case 'Spécialités':
        return '⭐';
      default:
        return '🍽️'; // icône par défaut
    }
  }

  String _symbol(String c) {
    switch (c) {
      case 'ILS':
        return '₪';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return c;
    }
  }

  double _parsePrice(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(s) ?? 0;
  }

  String _formatPrice(dynamic v) {
    final p = _parsePrice(v);
    final sym = _symbol(_currency);
    return p % 1 == 0 ? '${p.toInt()} $sym' : '${p.toStringAsFixed(2)} $sym';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (doc.exists && mounted) {
        setState(
            () => _currency = (doc.data()?['currency'] as String?) ?? 'ILS');
      }
    } catch (e) {
      debugPrint('Erreur chargement devise: $e');
    }
  }

  Future<void> _previewMenu() async {
    final uri = Uri.base;
    final previewUrl =
        '${uri.scheme}://${uri.host}:${uri.port}/r/${widget.restaurantId}';

    try {
      await launchUrl(
        Uri.parse(previewUrl),
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Impossible d\'ouvrir la prévisualisation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Gestion du menu',
      restaurantId: widget.restaurantId,
      activeRoute: '/dashboard',
      breadcrumbs: const ['Dashboard', 'Menu'],
      actions: [
        IconButton(
          icon: const Icon(Icons.preview),
          onPressed: _previewMenu,
          tooltip: 'Prévisualiser le menu',
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _addMenuItem,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter'),
        ),
      ],
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menus')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // Tri côté client
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final categoryA = dataA['category'] ?? '';
            final categoryB = dataB['category'] ?? '';
            final nameA = dataA['name'] ?? '';
            final nameB = dataB['name'] ?? '';

            final categoryCompare = categoryA.compareTo(categoryB);
            return categoryCompare != 0
                ? categoryCompare
                : nameA.compareTo(nameB);
          });

          return Column(
            children: [
              // LA TUILE "INFOS DU RESTAURANT"
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  elevation: 1,
                  color: const Color(0xFFFFF5F5),
                  child: ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.redAccent),
                    title: const Text('Infos du restaurant'),
                    subtitle: const Text(
                        'Modifier la description et le bandeau promo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.pushAdminScreen(
                        AdminRestaurantInfoScreen(
                          restaurantId: widget.restaurantId,
                          showBack: true,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Contenu
              Expanded(
                child: docs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun plat au menu',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajoutez votre premier plat pour commencer',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _addMenuItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter un plat'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          final itemId = doc.id;
                          final name = (data['name'] ?? '').toString();
                          final category = (data['category'] ?? '').toString();
                          final desc = (data['description'] ?? '').toString();
                          final isSignature = (data['signature'] == true) ||
                              (data['hasSignature'] == true);

                          final imgUrl = _pickImageUrl(data);
                          final priceText = _formatPrice(data['price']);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading:
                                  _squareThumbAny(imgUrl, category: category),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSignature)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Signature',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        Text(
                                          priceText,
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category.isEmpty
                                      ? 'Sans catégorie'
                                      : category),
                                  if (desc.isNotEmpty)
                                    Text(
                                      desc,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _editMenuItem(itemId, data);
                                      break;
                                    case 'delete':
                                      _deleteMenuItem(itemId, name);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 18, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Supprimer',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

// 1) Pick l'url d'image en tolérant plusieurs noms de clés
  String _pickImageUrl(Map<String, dynamic> data) {
    const candidates = [
      'imageUrl',
      'imageURL',
      'image',
      'image_url',
      'photoUrl',
      'photo_url',
      'thumbnail',
      'thumb',
      'url',
      'picture',
    ];
    for (final k in candidates) {
      final v = (data[k] ?? '').toString().trim();
      if (v.isNotEmpty) return v;
    }
    // Clés exotiques contenant "image" ou "photo"
    for (final e in data.entries) {
      final key = e.key.toLowerCase();
      if (key.contains('image') || key.contains('photo')) {
        final v = (e.value ?? '').toString().trim();
        if (v.isNotEmpty) return v;
      }
    }
    return '';
  }

// 2) Si on reçoit un path Storage ou un gs://, on résout en URL http(s)
  Future<String> _resolveDownloadUrl(String raw) async {
    try {
      if (raw.startsWith('http')) return raw;
      final ref = raw.startsWith('gs://')
          ? FirebaseStorage.instance.refFromURL(raw)
          : FirebaseStorage.instance.ref().child(raw);
      return await ref.getDownloadURL();
    } catch (_) {
      return '';
    }
  }

// Petit placeholder réutilisable
  Widget _thumbPlaceholder({String category = ''}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: const Color(0xFFF5F5F5),
        child: Text(
          _emojiFor(category),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

// Vignette qui gère http(s), gs:// et path Storage
  Widget _squareThumbAny(String? raw, {String category = ''}) {
    final r = (raw ?? '').trim();
    if (r.isEmpty) return _thumbPlaceholder(category: category);

    if (r.startsWith('http')) {
      return _squareThumb(r, category: category);
    }

    return FutureBuilder<String>(
      future: _resolveDownloadUrl(r),
      builder: (context, snap) {
        final url = (snap.data ?? '').trim();
        if (url.isEmpty) return _thumbPlaceholder(category: category);
        return _squareThumb(url, category: category);
      },
    );
  }

// Vignette pour une URL http(s) déjà résolue
  Widget _squareThumb(String url, {String category = ''}) {
    final u = url.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        u,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbPlaceholder(category: category),
      ),
    );
  }

  void _addMenuItem() {
    context.pushAdminScreen(
      MenuItemFormScreen(restaurantId: widget.restaurantId),
    );
  }

  void _editMenuItem(String itemId, Map<String, dynamic> data) {
    context.pushAdminScreen(
      MenuItemFormScreen(
        restaurantId: widget.restaurantId,
        itemId: itemId,
        initialData: data,
      ),
    );
  }

  Future<void> _deleteMenuItem(String itemId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menus')
            .doc(itemId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
