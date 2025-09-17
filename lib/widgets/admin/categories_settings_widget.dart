import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesSettings extends StatefulWidget {
  final String restaurantId;
  const CategoriesSettings({super.key, required this.restaurantId});

  @override
  State<CategoriesSettings> createState() => _CategoriesSettingsState();
}

class _CategoriesSettingsState extends State<CategoriesSettings> {
  List<String> _order = [];
  Set<String> _hidden = {};
  final _newCtrl = TextEditingController();
  bool _loading = true;
  bool _busy = false;

  String _titleCase(String s) =>
      s.trim().isEmpty ? s : s.trim()[0].toUpperCase() + s.trim().substring(1);

  bool _existsCI(List<String> list, String v) =>
      list.any((e) => e.toLowerCase() == v.toLowerCase());

  Future<void> _onDeleteCategory(String cat) async {
    if (_busy) return;
    setState(() => _busy = true);

    final detailsRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details');

    // Sauvegarde pour revert si erreur
    final backupOrder = List<String>.from(_order);
    final backupHidden = Set<String>.from(_hidden);

    try {
      final used = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menus')
          .where('category', isEqualTo: cat)
          .limit(1)
          .get();

      if (used.docs.isNotEmpty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Catégorie utilisée'),
            content: Text('"$cat" est utilisée par des plats.\n'
                'Suppression impossible. La masquer ?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('Annuler')),
              TextButton(
                  onPressed: () => Navigator.pop(context, 'hide'),
                  child: const Text('Masquer')),
            ],
          ),
        );
        if (choice != 'hide') {
          setState(() => _busy = false);
          return;
        }

        // Optimistic UI
        setState(() {
          _order.remove(cat);
          _hidden.add(cat);
        });

        await detailsRef.update({
          'categoriesHidden': FieldValue.arrayUnion([cat]),
          'categoriesOrder': FieldValue.arrayRemove([cat]),
        });
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('"$cat" masquée')));
        }
      } else {
        // Optimistic UI
        setState(() => _order.remove(cat));

        await detailsRef.update({
          'categoriesOrder': FieldValue.arrayRemove([cat]),
          'categoriesHidden': FieldValue.arrayRemove([cat]),
        });
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('"$cat" supprimée')));
        }
      }
    } catch (e) {
      // Revert si erreur
      setState(() {
        _order = backupOrder;
        _hidden = backupHidden;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = snap.data() ?? {};
    if (mounted) {
      setState(() {
        _order = List<String>.from(data['categoriesOrder'] ?? []);
        _hidden = Set<String>.from(data['categoriesHidden'] ?? []);
        _loading = false;
      });
    }
  }

  Future<void> _save() => FirebaseFirestore.instance
      .collection('restaurants')
      .doc(widget.restaurantId)
      .collection('info')
      .doc('details')
      .set({'categoriesOrder': _order, 'categoriesHidden': _hidden.toList()},
          SetOptions(merge: true));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const CircularProgressIndicator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestion des catégories',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            setState(() {
              final item = _order.removeAt(oldIndex);
              _order.insert(newIndex, item);
            });
            await _save();
          },
          children: [
            for (int i = 0; i < _order.length; i++)
              Container(
                key: ValueKey(_order[i]),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final isTiny =
                        c.maxWidth < 380; // iPhone SE ≈ 320, petits écrans

                    final cat = _order[i];
                    final hidden = _hidden.contains(cat);
                    final statusColor =
                        hidden ? Colors.orange.shade700 : Colors.green.shade700;
                    final statusBg =
                        hidden ? Colors.orange.shade50 : Colors.green.shade50;

                    // ---------- MODE 2 LIGNES (petits écrans) ----------
                    if (isTiny) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ligne "nom"
                          Row(
                            children: [
                              // handle drag
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: ReorderableDragStartListener(
                                  index: i,
                                  child: Icon(Icons.drag_indicator,
                                      size: 18, color: Colors.grey.shade500),
                                ),
                              ),
                              // icône
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(6)),
                                child: Icon(Icons.category,
                                    size: 14, color: Colors.indigo.shade600),
                              ),
                              const SizedBox(width: 12),
                              // nom
                              Expanded(
                                child: Text(
                                  cat,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Ligne "actions"
                          Row(
                            children: [
                              // badge Visible/Masquée
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(999)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        hidden
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 14,
                                        color: statusColor),
                                    const SizedBox(width: 6),
                                    Text(hidden ? 'Masquée' : 'Visible',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Transform.scale(
                                scale: 0.82,
                                child: Switch.adaptive(
                                  value: !hidden,
                                  onChanged: (v) async {
                                    setState(() => v
                                        ? _hidden.remove(cat)
                                        : _hidden.add(cat));
                                    await _save();
                                  },
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: Material(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  child: IconButton(
                                    tooltip: 'Supprimer',
                                    icon: Icon(Icons.delete_outline,
                                        size: 16, color: Colors.red.shade600),
                                    onPressed: () => _onDeleteCategory(cat),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    // ---------- MODE 1 LIGNE (tablette/desktop) ----------
                    return Row(
                      children: [
                        // handle drag
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: ReorderableDragStartListener(
                            index: i,
                            child: Icon(Icons.drag_indicator,
                                size: 18, color: Colors.grey.shade500),
                          ),
                        ),
                        // icône
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6)),
                          child: Icon(Icons.category,
                              size: 14, color: Colors.indigo.shade600),
                        ),
                        const SizedBox(width: 12),

                        // nom (priorité de largeur)
                        Expanded(
                          child: Text(
                            cat,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.15),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // actions à droite — compactes
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  hidden
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 12,
                                  color: statusColor),
                              const SizedBox(width: 4),
                              Text(hidden ? 'Masquée' : 'Visible',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.scale(
                          scale: 0.88,
                          child: Switch.adaptive(
                            value: !hidden,
                            onChanged: (v) async {
                              setState(() =>
                                  v ? _hidden.remove(cat) : _hidden.add(cat));
                              await _save();
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Material(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            child: IconButton(
                              tooltip: 'Supprimer',
                              icon: Icon(Icons.delete_outline,
                                  size: 16, color: Colors.red.shade600),
                              onPressed: () => _onDeleteCategory(cat),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nouvelle catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final raw = _newCtrl.text.trim();
                final cat = _titleCase(raw);
                if (cat.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nom requis')));
                  return;
                }
                if (_existsCI(_order, cat)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Catégorie déjà existante')));
                  return;
                }
                setState(() => _order.add(cat));
                _newCtrl.clear();
                await _save();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Catégorie "$cat" ajoutée')));
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _newCtrl.dispose();
    super.dispose();
  }
}
