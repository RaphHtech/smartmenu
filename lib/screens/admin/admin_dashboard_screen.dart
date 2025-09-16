import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import 'menu_item_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/ui/admin_themed.dart';
import '../../widgets/ui/admin_shell.dart';

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
  String _currency = 'ILS';
  String _sortBy = 'category';
  String? _selectedCategory;
  List<String> _categoriesOrder = [];
  Set<String> _categoriesHidden = {};
  StreamSubscription? _infoSub;

// 🔎 source de vérité unique pour la recherche (affichée et filtrée)
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

// catégories dérivées du flux, stockées en état pour les chips
  List<String> _categories = [];

  Timer? _debounceTimer;

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
    _listenRestaurantInfo();
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

  void _listenRestaurantInfo() {
    _infoSub = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .snapshots()
        .listen((snap) {
      final data = snap.data() ?? {};
      if (!mounted) return;
      setState(() {
        _currency = (data['currency'] as String?) ?? 'ILS';
        _categoriesOrder = List<String>.from(data['categoriesOrder'] ?? []);
        _categoriesHidden = Set<String>.from(data['categoriesHidden'] ?? []);
      });
    }, onError: (e) => debugPrint('Erreur info/details: $e'));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    _infoSub?.cancel();
    super.dispose();
  }

  Future<void> _previewMenu() async {
    final origin = Uri.base;
    final previewUri = Uri(
      scheme: origin.scheme,
      host: origin.host,
      port: origin.hasPort ? origin.port : null,
      path: '/r/${widget.restaurantId}',
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

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Menu',
      restaurantId: widget.restaurantId,
      activeRoute: '/menu',
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
      child: Column(
        children: [
          // 1) Tuile infos + UI de recherche/tri/chips HORS StreamBuilder
          _buildSearchInterface(),

          // 2) Seule la LISTE dépend du flux
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(widget.restaurantId)
                  .collection('menus')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
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

                // --- Met à jour les catégories en état local (hors builder UI) ---
                final newCategories = _computeCategories(docs);
                if (!listEquals(newCategories, _categories)) {
                  // évite setState pendant le build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _categories = newCategories);
                    }
                  });
                }

                // --- Filtrage + tri (sur l’état _searchText / _selectedCategory / _sortBy) ---
                final visibleDocs = _filterDocs(docs);

                // Log debug optionnel
                // debugPrint('SEARCH q="${_searchText.trim()}" cat=${_selectedCategory ?? "Toutes"} sort=$_sortBy -> docs=${docs.length} filtered=${visibleDocs.length}');

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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  padding: const EdgeInsets.all(16),
                  itemCount: visibleDocs.length,
                  itemBuilder: (context, index) {
                    final doc = visibleDocs[index];
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
                        leading: _squareThumbAny(imgUrl, category: category),
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
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Signature',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12)),
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
                            Text(
                                category.isEmpty ? 'Sans catégorie' : category),
                            if (desc.isNotEmpty)
                              Text(
                                desc,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54),
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
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F0F0), Color(0xFFE8E8E8)],
          ),
          border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 22,
          color: Color(0xFF757575),
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
        ));
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

// 1) UI hors StreamBuilder : tuile Infos + barre recherche + tri + chips
  Widget _buildSearchInterface() {
    return Column(
      children: [
        // Recherche + tri + chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  // Champ recherche
                  Expanded(
                    flex: 3,
                    child: TextField(
                      key: const ValueKey('menu_search_field'),
                      controller: _searchController,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController
                                      .clear(); // listener mettra _searchText à ''
                                  _searchFocus.requestFocus();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                      ),
                      onChanged: (_) {
                        // Rien d’autre : le listener du controller fait le setState
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Tri compact
                  SizedBox(
                    width: 130,
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                      ),
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
              const SizedBox(height: 12),

              // Chips catégories (depuis _categories)
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Toutes'),
                        selected: _selectedCategory == null,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = null),
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppColors.primary.withAlpha(51),
                        checkmarkColor: AppColors.primary,
                      ),
                    ),
                    ..._categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() =>
                                _selectedCategory = selected ? category : null);
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppColors.primary.withAlpha(51),
                          checkmarkColor: AppColors.primary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// 2) Utilitaires pour catégories et filtrage
  List<String> _computeCategories(List<QueryDocumentSnapshot> docs) {
    final set = <String>{};
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final c = (data['category'] ?? '').toString().trim();
      if (c.isNotEmpty) set.add(c);
    }
    // Inclure aussi les catégories déclarées par le restaurateur
    set.addAll(_categoriesOrder);

    final categories =
        applyOrderAndHide(set, _categoriesOrder, _categoriesHidden);

    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedCategory = null);
      });
    }

    return categories;
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
          final c = ca.compareTo(cb);
          if (c != 0) return c;
          return (dataA?['name'] ?? '')
              .toString()
              .compareTo((dataB?['name'] ?? '').toString());
        });
    }
    return visible;
  }

  // Future<void> _showReorderDialog() async {
  //   final docs = await FirebaseFirestore.instance
  //       .collection('restaurants')
  //       .doc(widget.restaurantId)
  //       .collection('menus')
  //       .get(); // Sans orderBy pour l'instant

  //   final items = docs.docs.map((doc) {
  //     final data = doc.data();
  //     return {
  //       'id': doc.id,
  //       'name': data['name'] ?? '',
  //       'category': data['category'] ?? '',
  //       'order': data['order'] ?? 0,
  //     };
  //   }).toList();

  //   items.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

  //   final reorderedItems = await showDialog<List<Map<String, dynamic>>>(
  //     context: context,
  //     builder: (context) => _buildReorderDialog(items),
  //   );

  //   if (reorderedItems != null) {
  //     await _updateItemsOrder(reorderedItems);
  //   }
  // }

  // Widget _buildReorderDialog(List<Map<String, dynamic>> items) {
  //   return StatefulBuilder(
  //     builder: (context, setState) => AlertDialog(
  //       title: const Text('Réorganiser les plats'),
  //       content: SizedBox(
  //         width: 400,
  //         height: 500,
  //         child: ReorderableListView.builder(
  //           itemCount: items.length,
  //           onReorder: (oldIndex, newIndex) {
  //             setState(() {
  //               if (newIndex > oldIndex) newIndex--;
  //               final item = items.removeAt(oldIndex);
  //               items.insert(newIndex, item);
  //             });
  //           },
  //           itemBuilder: (context, index) {
  //             final item = items[index];
  //             return ListTile(
  //               key: ValueKey(item['id']),
  //               leading: const Icon(Icons.drag_handle),
  //               title: Text(item['name']),
  //               subtitle: Text(item['category']),
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Annuler'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, items),
  //           child: const Text('Sauvegarder'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _updateItemsOrder(List<Map<String, dynamic>> items) async {
  //   final batch = FirebaseFirestore.instance.batch();

  //   for (int i = 0; i < items.length; i++) {
  //     final ref = FirebaseFirestore.instance
  //         .collection('restaurants')
  //         .doc(widget.restaurantId)
  //         .collection('menus')
  //         .doc(items[i]['id']);

  //     batch.update(ref, {'order': (i + 1) * 100});
  //   }

  //   await batch.commit();

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Ordre des plats mis à jour')),
  //     );
  //   }
  // }
}
