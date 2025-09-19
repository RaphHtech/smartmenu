import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class AdminMenuReorderScreen extends StatefulWidget {
  final String restaurantId;

  const AdminMenuReorderScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminMenuReorderScreen> createState() => _AdminMenuReorderScreenState();
}

class _AdminMenuReorderScreenState extends State<AdminMenuReorderScreen> {
  // État de l'interface
  String _selectedCategory = '';
  bool _isLoading = true;
  List<String> _categories = [];
  Map<String, List<MenuItemData>> _itemsByCategory = {};

  // État de sauvegarde
  SaveState _saveState = SaveState.saved;
  DateTime? _lastSavedAt;
  Timer? _autoSaveTimer;

  // Sélection multiple
// Dans _AdminMenuReorderScreenState
  final Set<String> _selectedItems = <String>{};
  final Set<String> _dirtyItemIds = {};
  void _recalculatePositions(
      String category, List<MenuItemData> items, int oldIndex, int newIndex) {
    final item = items[newIndex];

    double newPosition;
    if (newIndex == 0) {
      newPosition = items.length > 1 ? items[1].position / 2.0 : 1000.0;
    } else if (newIndex == items.length - 1) {
      newPosition = items[newIndex - 1].position + 1000.0;
    } else {
      newPosition =
          (items[newIndex - 1].position + items[newIndex + 1].position) / 2.0;
    }

    item.position = newPosition;

    if (newIndex > 0 && (newPosition - items[newIndex - 1].position) < 0.1) {
      _renormalizeCategory(category, items);
    }
  }

  bool _isMultiSelectMode = false;

  // Données restaurant
  String _currency = 'ILS';

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG: Restaurant ID = ${widget.restaurantId}');
    _loadMenuItems();
    _listenRestaurantInfo();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _migrateOldItems() async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menus')
        .get(); // ← Tous les docs, pas de where

    int updateCount = 0;
    final itemsByCategory = <String, List<QueryDocumentSnapshot>>{};

    // Grouper par catégorie et identifier ceux sans position valide
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final position = (data['position'] as num?)?.toDouble();

      // Migration nécessaire si position manquante OU non valide
      if (position == null || position <= 0) {
        final category = (data['category'] ?? 'Autres').toString();
        itemsByCategory[category] = itemsByCategory[category] ?? [];
        itemsByCategory[category]!.add(doc);
      }
    }

    // Assigner positions par catégorie
    for (final categoryDocs in itemsByCategory.values) {
      for (int i = 0; i < categoryDocs.length; i++) {
        final position = (i + 1) * 1000.0;
        batch.update(categoryDocs[i].reference, {
          'position': position,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        updateCount++;
      }
    }

    if (updateCount > 0) {
      await batch.commit();
      debugPrint('Migration: $updateCount items mis à jour');
    }
  }

  Future<void> _listenRestaurantInfo() async {
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final data = snap.data() ?? {};
      setState(() {
        _currency = data['currency'] ?? 'ILS';

        // Ne pas écraser _categories si categoriesOrder est vide
        final configuredCategories =
            List<String>.from(data['categoriesOrder'] ?? []);
        if (configuredCategories.isNotEmpty) {
          _categories = configuredCategories;
        }
        // Sinon garder les catégories calculées par _loadMenuItems()

        if (_selectedCategory.isEmpty && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    });
  }

  Future<void> _loadMenuItems() async {
    debugPrint('DEBUG: Début _loadMenuItems');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menus')
          .get();

      debugPrint('DEBUG: Snapshot reçu avec ${snapshot.docs.length} docs');

      final items = <MenuItemData>[];
      final categories = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final item = MenuItemData.fromFirestore(doc.id, data);
        items.add(item);
        if (item.category.isNotEmpty) {
          categories.add(item.category);
        }
      }

      debugPrint('DEBUG: Items parsés, début initialisation positions');

      // Initialiser positions si manquantes
      await _initializePositionsIfNeeded(items);
      await _migrateOldItems();

      debugPrint('DEBUG: Positions initialisées, début groupement');

      // Grouper par catégorie
      final itemsByCategory = <String, List<MenuItemData>>{};
      for (final item in items) {
        final category =
            item.category.isEmpty ? 'Sans catégorie' : item.category;
        itemsByCategory[category] = itemsByCategory[category] ?? [];
        itemsByCategory[category]!.add(item);
      }

      // Trier chaque catégorie par position
      for (final categoryItems in itemsByCategory.values) {
        categoryItems.sort((a, b) => a.position.compareTo(b.position));
      }

      debugPrint('DEBUG: Données prêtes, setState');

      setState(() {
        _itemsByCategory = itemsByCategory;
        if (_categories.isEmpty) {
          _categories = categories.toList()..sort();
        }
        if (_selectedCategory.isEmpty && _categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
        _isLoading = false; // ← AJOUTER
      });

      debugPrint('DEBUG: _loadMenuItems terminé avec succès');
    } catch (e) {
      debugPrint('DEBUG: Erreur dans _loadMenuItems: $e');
      _showErrorSnackBar('Erreur de chargement: $e');
    }
  }

  Future<void> _initializePositionsIfNeeded(List<MenuItemData> items) async {
    final itemsNeedingPosition =
        items.where((item) => item.position == 0).toList();
    if (itemsNeedingPosition.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    final itemsByCategory = <String, List<MenuItemData>>{};

    // Grouper les items sans position par catégorie
    for (final item in itemsNeedingPosition) {
      final category = item.category.isEmpty ? 'Sans catégorie' : item.category;
      itemsByCategory[category] = itemsByCategory[category] ?? [];
      itemsByCategory[category]!.add(item);
    }

    // Assigner des positions par catégorie
    for (final entry in itemsByCategory.entries) {
      final categoryItems = entry.value;
      for (int i = 0; i < categoryItems.length; i++) {
        final position = (i + 1) * 1000.0; // 1000, 2000, 3000...
        final item = categoryItems[i];

        batch.update(
          FirebaseFirestore.instance
              .collection('restaurants')
              .doc(widget.restaurantId)
              .collection('menus')
              .doc(item.id),
          {'position': position, 'updatedAt': FieldValue.serverTimestamp()},
        );

        // Mettre à jour localement
        item.position = position;
      }
    }

    if (itemsNeedingPosition.isNotEmpty) {
      await batch.commit();
    }
  }

  void _onReorder(int oldIndex, int newIndex, String category) {
    setState(() {
      final items = _itemsByCategory[category]!;
      if (newIndex > oldIndex) newIndex--;

      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      // NOUVEAU : marquer seulement l'item déplacé
      _dirtyItemIds.add(item.id);
      _recalculatePositions(
          category, items, oldIndex, newIndex); // ← Nouveaux paramètres

      _saveState = SaveState.unsaved;
    });
    _scheduleAutoSave();
  }

  void _renormalizeCategory(String category, List<MenuItemData> items) {
    for (int i = 0; i < items.length; i++) {
      items[i].position = (i + 1) * 1000.0;
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted && _saveState == SaveState.unsaved) {
        _saveChanges();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_saveState == SaveState.saving || _dirtyItemIds.isEmpty) return;

    setState(() => _saveState = SaveState.saving);

    try {
      final itemsToUpdate = <MenuItemData>[];

      // Collecter seulement les items modifiés
      for (final categoryItems in _itemsByCategory.values) {
        for (final item in categoryItems) {
          if (_dirtyItemIds.contains(item.id)) {
            itemsToUpdate.add(item);
          }
        }
      }

      // Découper en chunks de 500 max
      const chunkSize = 500;
      for (int i = 0; i < itemsToUpdate.length; i += chunkSize) {
        final chunk = itemsToUpdate.skip(i).take(chunkSize);
        final batch = FirebaseFirestore.instance.batch();

        for (final item in chunk) {
          batch.update(
            FirebaseFirestore.instance
                .collection('restaurants')
                .doc(widget.restaurantId)
                .collection('menus')
                .doc(item.id),
            {
              'position': item.position,
              'category':
                  item.category, // Important : aussi sauvegarder category
              'visible': item.visible,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
        }

        await batch.commit();
      }

      if (mounted) {
        setState(() {
          _saveState = SaveState.saved;
          _lastSavedAt = DateTime.now();
          _dirtyItemIds.clear(); // Nettoyer après succès
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saveState = SaveState.error);
        _showErrorSnackBar('Erreur sauvegarde: $e');
      }
    }
  }

  void _moveToCategory(Set<String> itemIds, String targetCategory) async {
    setState(() {
      _saveState = SaveState.unsaved;
    });

    // Calculer la dernière position de la catégorie cible
    final targetItems = _itemsByCategory[targetCategory] ?? [];
    final lastPosition = targetItems.isEmpty ? 0 : targetItems.last.position;

    // Déplacer les items
    int positionIncrement = 1000;
    for (final itemId in itemIds) {
      MenuItemData? item;
      String? sourceCategory;

      // Trouver l'item dans les catégories
      for (final entry in _itemsByCategory.entries) {
        final foundItem = entry.value.firstWhere(
          (i) => i.id == itemId,
          orElse: () => MenuItemData.empty(),
        );
        if (foundItem.id.isNotEmpty) {
          item = foundItem;
          sourceCategory = entry.key;
          break;
        }
      }

      if (item != null && sourceCategory != null) {
        // Retirer de la catégorie source
        _itemsByCategory[sourceCategory]!.remove(item);

        // Mettre à jour l'item
        item.category =
            targetCategory == 'Sans catégorie' ? '' : targetCategory;
        item.position = lastPosition + positionIncrement.toDouble();
        _dirtyItemIds.add(item.id);

        positionIncrement += 1000;

        // Ajouter à la catégorie cible
        _itemsByCategory[targetCategory] =
            _itemsByCategory[targetCategory] ?? [];
        _itemsByCategory[targetCategory]!.add(item);
      }
    }

    _selectedItems.clear();
    _isMultiSelectMode = false;
    _scheduleAutoSave();
  }

  void _toggleItemVisibility(Set<String> itemIds, bool visible) async {
    setState(() {
      _saveState = SaveState.unsaved;
    });

    for (final itemId in itemIds) {
      for (final categoryItems in _itemsByCategory.values) {
        final item = categoryItems.firstWhere(
          (i) => i.id == itemId,
          orElse: () => MenuItemData.empty(),
        );
        if (item.id.isNotEmpty) {
          item.visible = visible;
          _dirtyItemIds.add(itemId);

          break;
        }
      }
    }

    // Sauvegarder immédiatement les changements de visibilité
    final batch = FirebaseFirestore.instance.batch();
    for (final itemId in itemIds) {
      batch.update(
        FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('menus')
            .doc(itemId),
        {
          'visible': visible,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();

    _selectedItems.clear();
    _isMultiSelectMode = false;
    _scheduleAutoSave();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade500,
      ),
    );
  }

  String _getCurrencySymbol() {
    switch (_currency) {
      case 'ILS':
        return '₪';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return '€';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Réorganiser le Menu',
      restaurantId: widget.restaurantId,
      activeRoute: '/menu/reorder',
      breadcrumbs: const ['Dashboard', 'Menu', 'Réorganiser'],
      actions: [
        // Indicateur de sauvegarde
        _buildSaveIndicator(),
        const SizedBox(width: 16),

        // Actions de sélection multiple
        if (_isMultiSelectMode) ...[
          _buildBulkActions(),
          const SizedBox(width: 8),
        ],

        // Preview
        IconButton(
          icon: const Icon(Icons.preview),
          onPressed: _previewMenu,
          tooltip: 'Prévisualiser',
        ),
      ],
      child: _buildContent(),
    );
  }

  Widget _buildSaveIndicator() {
    IconData icon;
    Color color;
    String text;

    switch (_saveState) {
      case SaveState.saving:
        icon = Icons.sync;
        color = AdminTokens.primary500;
        text = 'Enregistrement...';
        break;
      case SaveState.saved:
        icon = Icons.check_circle_outline;
        color = AdminTokens.success500;
        final time = _lastSavedAt;
        if (time != null) {
          final diff = DateTime.now().difference(time);
          if (diff.inSeconds < 60) {
            text = 'Enregistré • il y a ${diff.inSeconds}s';
          } else {
            text = 'Enregistré • il y a ${diff.inMinutes}min';
          }
        } else {
          text = 'Enregistré';
        }
        break;
      case SaveState.error:
        icon = Icons.error_outline;
        color = AdminTokens.error500;
        text = 'Erreur';
        break;
      case SaveState.unsaved:
        icon = Icons.radio_button_unchecked;
        color = AdminTokens.warning500;
        text = 'Non enregistré';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AdminTypography.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildBulkActions() {
    return PopupMenuButton<String>(
      tooltip: 'Actions groupées',
      icon: const Icon(Icons.more_vert, color: AdminTokens.primary600),
      onSelected: (action) {
        switch (action) {
          case 'hide':
            _toggleItemVisibility(_selectedItems, false);
            break;
          case 'show':
            _toggleItemVisibility(_selectedItems, true);
            break;
          case 'move':
            _showMoveDialog();
            break;
          case 'cancel':
            setState(() {
              _selectedItems.clear();
              _isMultiSelectMode = false;
            });
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'move',
          child: Row(
            children: [
              const Icon(Icons.drive_file_move_outline, size: 18),
              const SizedBox(width: 8),
              Text('Déplacer (${_selectedItems.length})'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'hide',
          child: Row(
            children: [
              const Icon(Icons.visibility_off_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Masquer (${_selectedItems.length})'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'show',
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Afficher (${_selectedItems.length})'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: [
              Icon(Icons.clear, size: 18),
              SizedBox(width: 8),
              Text('Annuler sélection'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar catégories
        SizedBox(
          width: 200,
          child: _buildCategoryList(),
        ),
        const SizedBox(width: 24),

        // Liste des plats
        Expanded(
          child: _buildItemsList(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Chips catégories
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Liste des plats
        Expanded(
          child: _buildItemsList(),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégories',
          style: AdminTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              final itemCount = _itemsByCategory[category]?.length ?? 0;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AdminTokens.primary50
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            style: AdminTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? AdminTokens.primary600
                                  : AdminTokens.neutral600,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AdminTokens.primary100
                                : AdminTokens.neutral100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$itemCount',
                            style: AdminTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? AdminTokens.primary600
                                  : AdminTokens.neutral500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    final items = _itemsByCategory[_selectedCategory] ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AdminTokens.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun plat dans cette catégorie',
              style: AdminTypography.bodyLarge.copyWith(
                color: AdminTokens.neutral500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec multi-select toggle
        Row(
          children: [
            Text(
              '${items.length} plat${items.length > 1 ? 's' : ''} • $_selectedCategory',
              style: AdminTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isMultiSelectMode = !_isMultiSelectMode;
                  if (!_isMultiSelectMode) {
                    _selectedItems.clear();
                  }
                });
              },
              icon: Icon(
                _isMultiSelectMode ? Icons.close : Icons.checklist,
                size: 18,
              ),
              label: Text(_isMultiSelectMode ? 'Annuler' : 'Sélectionner'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Liste réorganisable
        Expanded(
          child: ReorderableListView(
            buildDefaultDragHandles: false, // ← Supprime les handles de droite
            onReorder: (oldIndex, newIndex) {
              _onReorder(oldIndex, newIndex, _selectedCategory);
            },
            children: items.asMap().entries.map((entry) {
              return _buildItemCard(entry.value, entry.key);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(MenuItemData item, int index) {
    final isSelected = _selectedItems.contains(item.id);

    return Card(
      key: ValueKey(item.id),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.indigo.shade300 : AdminTokens.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            // Drag handle fonctionnel
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_handle,
                color: AdminTokens.neutral400,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),

            // Checkbox en mode sélection
            if (_isMultiSelectMode)
              Checkbox(
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedItems.add(item.id);
                    } else {
                      _selectedItems.remove(item.id);
                    }
                  });
                },
              )
            else
              // Thumbnail
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AdminTokens.neutral100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_outlined,
                            color: AdminTokens.neutral400,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color: AdminTokens.neutral400,
                      ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: AdminTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: item.visible ? null : TextDecoration.lineThrough,
                  color: item.visible ? null : AdminTokens.neutral400,
                ),
              ),
            ),
            if (item.signature)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Signature',
                  style: AdminTypography.labelSmall.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              '${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)} ${_getCurrencySymbol()}',
              style: AdminTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AdminTokens.primary600,
              ),
            ),
          ],
        ),
        subtitle: item.description.isNotEmpty
            ? Text(
                item.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminTypography.bodySmall.copyWith(
                  color: AdminTokens.neutral500,
                ),
              )
            : null,
        onTap: _isMultiSelectMode
            ? () {
                setState(() {
                  if (isSelected) {
                    _selectedItems.remove(item.id);
                  } else {
                    _selectedItems.add(item.id);
                  }
                });
              }
            : null,
      ),
    );
  }

  void _showMoveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déplacer ${_selectedItems.length} plat(s)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _categories.map((category) {
            return ListTile(
              title: Text(category),
              trailing: category == _selectedCategory
                  ? const Icon(Icons.check, color: AdminTokens.primary600)
                  : null,
              onTap: category == _selectedCategory
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _moveToCategory(_selectedItems, category);
                    },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _previewMenu() async {
    // Même logique que dans admin_dashboard_screen.dart
    final origin = Uri.base;
    final previewUri = Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: '/r/${widget.restaurantId}',
      queryParameters: {'preview': '1', 'return': '/admin'},
    );

    try {
      await launchUrl(previewUri, webOnlyWindowName: '_blank');
    } catch (e) {
      _showErrorSnackBar("Impossible d'ouvrir la prévisualisation: $e");
    }
  }
}

// Classes de données
class MenuItemData {
  final String id;
  String name;
  String description;
  String imageUrl;
  double price;
  String category;
  bool signature;
  bool visible;
  double position;

  MenuItemData({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.signature,
    required this.visible,
    required this.position,
  });

  factory MenuItemData.fromFirestore(String id, Map<String, dynamic> data) {
    return MenuItemData(
      id: id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? data['image']?.toString() ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category']?.toString() ?? '',
      signature: data['signature'] == true || data['hasSignature'] == true,
      visible: data['visible'] != false, // Par défaut visible
      position: (data['position'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory MenuItemData.empty() {
    return MenuItemData(
      id: '',
      name: '',
      description: '',
      imageUrl: '',
      price: 0.0,
      category: '',
      signature: false,
      visible: true,
      position: 0.0,
    );
  }
}

enum SaveState { saved, unsaved, saving, error }
