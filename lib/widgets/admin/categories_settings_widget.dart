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
          onReorder: (oldIndex, newIndex) async {
            if (newIndex > oldIndex) newIndex--;
            setState(() {
              final item = _order.removeAt(oldIndex);
              _order.insert(newIndex, item);
            });
            await _save();
          },
          children: [
            for (final cat in _order)
              ListTile(
                key: ValueKey(cat),
                title: Text(cat),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_hidden.contains(cat) ? 'Masquée' : 'Visible'),
                    const SizedBox(width: 8),
                    Switch(
                      value: !_hidden.contains(cat),
                      onChanged: (value) async {
                        setState(() {
                          value ? _hidden.remove(cat) : _hidden.add(cat);
                        });
                        await _save();
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _onDeleteCategory(cat),
                    ),
                    const Icon(Icons.drag_handle),
                  ],
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
