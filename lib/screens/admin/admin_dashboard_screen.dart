import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/core/design/admin_tokens.dart';
import 'package:smartmenu_app/screens/admin/admin_menu_reorder_screen.dart';
import 'menu_item_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../services/category_repository.dart';
import '../../models/category.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../screens/admin/category_manager_sheet.dart';

List<String> applyOrderAndHide(
  Set<String> allCats,
  List<String> order,
  Set<String> hidden,
) {
  final visible = allCats.where((c) => !hidden.contains(c)).toSet();
  final rest = visible.where((c) => !order.contains(c)).toList()..sort();
  return [...order.where(visible.contains), ...rest];
}

int weightFor(String cat, List<String> order) {
  final i = order.indexOf(cat);
  return i >= 0 ? i : 1000;
}

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
  String _sortBy = 'category';
  String? _selectedCategory;
  String _searchText = '';
  bool _filterFeatured = false;
  bool _filterWithBadges = false;
  bool _filterNoImage = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

// catégories dérivées du flux, stockées en état pour les chips
  Timer? _debounceTimer;

  double _parsePrice(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(RegExp(r'[^0-9\.\-]'), '');
    return double.tryParse(s) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (!mounted) return;
      // Met à jour _searchText et rafraîchit l’UI (sans toucher au focus)
      final t = _searchController.text;
      if (t != _searchText) {
        setState(() {
          _searchText = t;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _previewMenu() async {
    // Récupérer le slug/code du restaurant
    final detailsSnap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = detailsSnap.data() ?? {};
    final code = (data['slug'] ?? data['code'] ?? '').toString().trim();
    final publicId = code.isNotEmpty ? code : widget.restaurantId;

    final origin = Uri.base;
    final previewUri = Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: '/r/$publicId', // Utilise le slug au lieu de l'ID
      queryParameters: {
        'preview': '1',
        'return': '/admin',
      },
    );

    try {
      await launchUrl(previewUri, webOnlyWindowName: '_blank');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Impossible d'ouvrir la prévisualisation: $e")),
        );
      }
    }
  }

  Widget _buildEditableCategoryBar(CategoryLiveState state) {
    final categoriesOrder = state.order;
    final categoriesHidden = state.hidden;
    final allCategories = {...state.counts.keys, ...categoriesOrder};

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // AJOUTER: Chip "Toutes" en premier
            _buildAllCategoriesChip(state),

            // Catégories ordonnées
            ...categoriesOrder
                .where((cat) => allCategories.contains(cat))
                .map((cat) => _buildChip(cat, categoriesHidden, state)),

            // Nouvelles catégories non encore ordonnées
            ...allCategories
                .where((cat) => !categoriesOrder.contains(cat))
                .map((cat) => _buildChip(cat, categoriesHidden, state)),

            // Bouton ajouter
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: ActionChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Catégorie')
                  ],
                ),
                onPressed: _showAddCategoryDialog,
                backgroundColor: AdminTokens.primary50,
                labelStyle: const TextStyle(
                  color: AdminTokens.primary600,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTokens.radius12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategoriesChip(CategoryLiveState state) {
    final totalCount = state.counts.values.fold(0, (sum, count) => sum + count);
    final isSelected = _selectedCategory == null;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('Toutes ($totalCount)'),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedCategory = null),
        backgroundColor: Colors.white,
        selectedColor: AdminTokens.primary50,
        checkmarkColor: AdminTokens.primary600,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? AdminTokens.primary600 : AdminTokens.neutral700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AdminTokens.radius12),
          side: BorderSide(
            color: isSelected ? AdminTokens.primary600 : AdminTokens.border,
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
      String category, Set<String> categoriesHidden, CategoryLiveState state) {
    final itemCount = state.counts[category] ?? 0;
    final isHidden = categoriesHidden.contains(category);
    final isSelected = _selectedCategory == category;
    final isMobile = MediaQuery.of(context).size.width < 375;

    return Padding(
      padding: const EdgeInsets.only(right: AdminTokens.space8),
      child: Opacity(
        opacity: isHidden ? 0.4 : 1.0,
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isHidden) ...[
                Icon(Icons.visibility_off,
                    size: 12, color: AdminTokens.neutral600),
                const SizedBox(width: 4),
              ],
              Text(isMobile ? category : '$category ($itemCount)'),
            ],
          ),
          selected: isSelected,
          onSelected: isHidden
              ? (_) => _quickToggleVisibility(category)
              : (selected) => setState(
                  () => _selectedCategory = selected ? category : null),
          backgroundColor: isHidden ? AdminTokens.neutral300 : Colors.white,
          selectedColor: AdminTokens.primary50,
          checkmarkColor: AdminTokens.primary600,
          labelStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AdminTokens.primary600 : AdminTokens.neutral700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdminTokens.radius12),
            side: BorderSide(
              color: isSelected ? AdminTokens.primary600 : AdminTokens.border,
            ),
          ),
        ),
      ),
    );
  }

  void _openReorderScreen() {
    context.pushAdminScreen(
      AdminMenuReorderScreen(restaurantId: widget.restaurantId),
    );
  }

  Future<void> _quickToggleVisibility(String category) async {
    try {
      await CategoryManager.toggleCategoryVisibility(
          widget.restaurantId, category);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégorie mise à jour.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom de la catégorie',
            hintText: 'Ex: Desserts',
            border: OutlineInputBorder(),
          ),
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              Navigator.pop(context);
              await CategoryManager.addCategory(widget.restaurantId, name);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _handleAppBarAction(String action, CategoryLiveState state) {
    switch (action) {
      case 'manage_categories':
        _showManageCategoriesSheet(state);
        break;
      case 'reorder':
        _openReorderScreen();
        break;
      case 'preview':
        _previewMenu();
        break;
    }
  }

  void _showManageCategoriesSheet(CategoryLiveState state) {
    CategoryManagerSheet.show(context, widget.restaurantId, state);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CategoryLiveState>(
      stream: CategoryManager.getLiveState(widget.restaurantId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final state = snapshot.data!;

        return AdminShell(
          title: 'Menu',
          restaurantId: widget.restaurantId,
          activeRoute: '/menu',
          breadcrumbs: const ['Dashboard', 'Menu'],
          actions: [
            if (MediaQuery.of(context).size.width >= 768) ...[
              IconButton(
                  icon: const Icon(Icons.preview), onPressed: _previewMenu),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showManageCategoriesSheet(state),
                tooltip: 'Gérer catégories',
              ),
              const SizedBox(width: 8), // AJOUTER cette ligne
              OutlinedButton.icon(
                  onPressed: _openReorderScreen,
                  icon: const Icon(Icons.reorder),
                  label: const Text('Réorganiser')),
              const SizedBox(width: 8), // AJOUTER cette ligne
              FilledButton.icon(
                  onPressed: _addMenuItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter')),
            ] else ...[
              // Mobile minimaliste
              IconButton(icon: const Icon(Icons.add), onPressed: _addMenuItem),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleAppBarAction(value, state),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AdminTokens.radius12),
                  side: const BorderSide(
                      color: AdminTokens.border, width: 1), // Ajoute ça
                ),
                elevation: 8,
                color: Colors.white,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'manage_categories',
                    child: Row(
                      children: [
                        Icon(Icons.settings,
                            size: 18, color: AdminTokens.neutral600),
                        SizedBox(width: AdminTokens.space12),
                        Text(
                          'Gérer catégories',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AdminTokens.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reorder',
                    child: Row(
                      children: [
                        Icon(Icons.reorder,
                            size: 18, color: AdminTokens.neutral600),
                        SizedBox(width: AdminTokens.space12),
                        Text(
                          'Réorganiser plats',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AdminTokens.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.preview,
                            size: 18, color: AdminTokens.neutral600),
                        SizedBox(width: AdminTokens.space12),
                        Text(
                          'Prévisualiser',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AdminTokens.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
          child: Column(
            children: [
              // 1) Tuile infos + UI de recherche/tri/chips HORS StreamBuilder
              _buildSearchInterface(state),
              _buildEditableCategoryBar(state),

              // 2) Seule la LISTE dépend du flux
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(widget.restaurantId)
                      .collection('menus')
                      .snapshots()
                      .where((snapshot) =>
                          snapshot.metadata.isFromCache ==
                          false), // Ignore cache
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            SizedBox(height: 16),
                            Text('Erreur lors du chargement du menu'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs ?? [];
                    // Calcul des compteurs par catégorie
                    final visibleDocs = _filterDocs(docs);

                    // --- Rendu liste (identique à ton code, mais sur visibleDocs) ---
                    if (visibleDocs.isEmpty) {
                      return Center(
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
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: visibleDocs.length,
                      itemBuilder: (context, index) {
                        final doc = visibleDocs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        final itemId = doc.id;
                        final name = (data['name'] ?? '').toString();
                        final category = (data['category'] ?? '').toString();
                        final desc = (data['description'] ?? '').toString();
                        final imgUrl = _pickImageUrl(data);
                        return Card(
                          margin: EdgeInsets.only(
                            bottom: AdminTokens.space8,
                            left: MediaQuery.of(context).size.width < 600
                                ? 0
                                : AdminTokens.space4,
                            right: MediaQuery.of(context).size.width < 600
                                ? 0
                                : AdminTokens.space4,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AdminTokens.radius16),
                            side: const BorderSide(color: AdminTokens.border),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AdminTokens.radius16),
                              boxShadow: AdminTokens.shadowMd,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isXs = constraints.maxWidth < 360;
                                final thumbnailSize = isXs ? 64.0 : 72.0;
                                final cardPadding =
                                    constraints.maxWidth >= 768 ? 20.0 : 16.0;

                                return Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Thumbnail avec taille responsive
                                      SizedBox(
                                        width: thumbnailSize,
                                        height: thumbnailSize,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: imgUrl.isNotEmpty
                                              ? Image.network(
                                                  imgUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildThumbnailPlaceholder(),
                                                )
                                              : _buildThumbnailPlaceholder(),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Content avec réservation kebab
                                      Expanded(
                                        child: Container(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Ligne 1: Titre + Badge selon breakpoint
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AdminTokens
                                                            .neutral900,
                                                        height: 1.3,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!isXs) ...[
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      '${_formatPriceNumber(data['price'])}\u00A0₪', // Espace insécable
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors
                                                            .indigo.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),

                                              const SizedBox(height: 8),

                                              // Ligne 2: Métas + Badge/Prix mobile
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          category.isEmpty
                                                              ? 'Sans catégorie'
                                                              : category,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AdminTokens
                                                                .neutral600,
                                                          ),
                                                        ),
                                                        if (desc
                                                            .isNotEmpty) ...[
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            desc,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                              color: AdminTokens
                                                                  .neutral700,
                                                              height: 1.4,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  if (isXs) ...[
                                                    const SizedBox(width: 12),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          '${_formatPriceNumber(data['price'])}\u00A0₪',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AdminTokens
                                                                .primary600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Kebab menu avec touch target 44px
                                      SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AdminTokens.radius12),
                                            side: const BorderSide(
                                                color: AdminTokens.border,
                                                width: 1), // Ajoute ça
                                          ),
                                          elevation: 12,
                                          color: Colors.white,
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
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      size: 18,
                                                      color: AdminTokens
                                                          .neutral600),
                                                  SizedBox(
                                                      width:
                                                          AdminTokens.space8),
                                                  Text(
                                                    'Modifier',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AdminTokens
                                                          .neutral700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 18,
                                                      color: Colors.red),
                                                  SizedBox(
                                                      width:
                                                          AdminTokens.space8),
                                                  Text(
                                                    'Supprimer',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// 1) Pick l'url d'image en tolérant plusieurs noms de clés
  String _pickImageUrl(Map<String, dynamic> data) {
    const candidates = [
      'imageUrl', // Première priorité
      'image',
      'imageURL',
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

  Widget _buildThumbnailPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        size: 20,
        color: Colors.grey.shade400,
      ),
    );
  }

  String _formatPriceNumber(dynamic price) {
    final p = _parsePrice(price);
    return p % 1 == 0 ? '${p.toInt()}' : p.toStringAsFixed(2);
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

  String _normalize(String s) {
    final lower = s.toLowerCase();
    const from = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
    const to =
        'aaaaaaceeeeiiiinooooouuuuyy'; // 27 caractères, correspondance 1:1
    final out = StringBuffer();
    for (final ch in lower.runes) {
      final charStr = String.fromCharCode(ch);
      final idx = from.indexOf(charStr);
      out.write(idx >= 0 ? to[idx] : charStr);
    }
    return out.toString();
  }

  Widget _buildSearchInterface(CategoryLiveState state) {
    return Column(
      children: [
        // Barre de recherche + dropdown
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchFocus.requestFocus();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminTokens.radius12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 130,
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AdminTokens.radius12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                  elevation: 12,
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                        value: 'category', child: Text('Catégorie')),
                    DropdownMenuItem(value: 'name', child: Text('Nom')),
                    DropdownMenuItem(value: 'price', child: Text('Prix')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortBy = value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Filtres en ligne horizontale
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AdminTokens.space16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Mis en avant', _filterFeatured,
                    (selected) => setState(() => _filterFeatured = selected)),
                const SizedBox(width: AdminTokens.space8),
                _buildFilterChip('Avec badges', _filterWithBadges,
                    (selected) => setState(() => _filterWithBadges = selected)),
                const SizedBox(width: AdminTokens.space8),
                _buildFilterChip('Sans image', _filterNoImage,
                    (selected) => setState(() => _filterNoImage = selected)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AdminTokens.space8), // Espacement après filtres
      ],
    );
  }

  Widget _buildFilterChip(
      String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: AdminTokens.primary50,
      checkmarkColor: AdminTokens.primary600,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: selected ? AdminTokens.primary600 : AdminTokens.neutral700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        side: BorderSide(
          color: selected ? AdminTokens.primary600 : AdminTokens.border,
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) {
    final visible = List<QueryDocumentSnapshot>.of(docs);

    // Catégorie
    if (_selectedCategory != null) {
      visible.retainWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['category'] ?? '').toString().trim() == _selectedCategory;
      });
    }

    // Recherche (accent-insensible)
    final q = _normalize(_searchText.trim());
    if (q.isNotEmpty) {
      visible.retainWhere((doc) {
        final d = doc.data() as Map<String, dynamic>;
        final name = _normalize((d['name'] ?? '').toString());
        final desc = _normalize((d['description'] ?? '').toString());
        final cat = _normalize((d['category'] ?? '').toString());
        return name.contains(q) || desc.contains(q) || cat.contains(q);
      });
    }

// AJOUTER CES LIGNES APRÈS LA RECHERCHE :
// Filtre "Mis en avant"
    if (_filterFeatured) {
      visible.retainWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['featured'] == true;
      });
    }

// Filtre "Avec badges"
    if (_filterWithBadges) {
      visible.retainWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final badges = data['badges'] as List?;
        return badges != null && badges.isNotEmpty;
      });
    }

// Filtre "Sans image"
    if (_filterNoImage) {
      visible.retainWhere((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = _pickImageUrl(data);
        return imageUrl.isEmpty;
      });
    }

// Tri
    switch (_sortBy) {
      case 'name':
        visible.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>?;
          final dataB = b.data() as Map<String, dynamic>?;
          return (dataA?['name'] ?? '')
              .toString()
              .compareTo((dataB?['name'] ?? '').toString());
        });
        break;
      case 'price':
        visible.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>?;
          final dataB = b.data() as Map<String, dynamic>?;
          return _parsePrice(dataA?['price'])
              .compareTo(_parsePrice(dataB?['price']));
        });
        break;
      case 'category':
      default:
        visible.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>?;
          final dataB = b.data() as Map<String, dynamic>?;
          final ca = (dataA?['category'] ?? '').toString();
          final cb = (dataB?['category'] ?? '').toString();

          // Tri par catégorie d'abord
          int catCompare = ca.compareTo(cb);
          if (catCompare != 0) return catCompare;

          // Puis par position dans la catégorie
          final posA = (dataA?['position'] as num?)?.toDouble() ?? 999999.0;
          final posB = (dataB?['position'] as num?)?.toDouble() ?? 999999.0;

          if (posA == 0 && posB == 0) {
            return (dataA?['name'] ?? '')
                .toString()
                .compareTo((dataB?['name'] ?? '').toString());
          }
          if (posA == 0) return 1;
          if (posB == 0) return -1;

          int posCompare = posA.compareTo(posB);
          if (posCompare != 0) return posCompare;

          // Enfin par nom si même position
          return (dataA?['name'] ?? '')
              .toString()
              .compareTo((dataB?['name'] ?? '').toString());
        });
    }
    return visible;
  }
}
