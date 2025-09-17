import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
// import 'dart:typed_data';

class MenuItemFormScreen extends StatefulWidget {
  final String restaurantId;
  final String? itemId; // null pour création, id pour modification
  final Map<String, dynamic>? initialData;

  const MenuItemFormScreen({
    super.key,
    required this.restaurantId,
    this.itemId,
    this.initialData,
  });

  @override
  State<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends State<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Pizzas';
  String _restaurantCurrency = 'ILS';
  bool _isSignature = false;
  bool _isVisible = true;
  bool _isLoading = false;
  bool _removeImage = false;

  // Image (portable Web + Mobile)
  Uint8List? _pickedBytes; // web/mobile-safe
  String? _imageUrl; // current or newly uploaded
  // String? _initialCategory;

  List<String> _categories = [];
  bool _categoriesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadRestaurantCurrency();
    _loadCategories();
  }

  Future<void> _loadRestaurantCurrency() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (doc.exists && mounted) {
        final currency = (doc.data()?['currency'] as String?) ?? 'ILS';
        debugPrint('DEVISE CHARGÉE: $currency'); // DEBUG
        setState(() {
          _restaurantCurrency = currency;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement devise: $e');
    }
  }

  void _loadInitialData() {
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _priceController.text = (data['price'] ?? 0).toString();
      _selectedCategory = data['category'] ?? _categories.first;
      _isSignature = data['signature'] ?? false;
      _isVisible = data['visible'] ?? true;

      // Très important pour préserver l'image existante
      _imageUrl = data['imageUrl'] ?? data['image'] ?? '';
    } else {
      // Nouveau plat - pas de catégorie initiale
    }
  }

  Future<void> _loadCategories() async {
    try {
      // 1. Récupère les catégories configurées du restaurant
      final detailsDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      final detailsData = detailsDoc.data() ?? {};
      final configuredCategories =
          List<String>.from(detailsData['categoriesOrder'] ?? []);

      // 2. Récupère les catégories existantes des plats
      final menuSnapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menus')
          .get();

      final Set<String> existingCategories = {};
      for (final doc in menuSnapshot.docs) {
        final category = (doc.data()['category'] ?? '').toString().trim();
        if (category.isNotEmpty) {
          existingCategories.add(category);
        }
      }

      // 3. Combine et ordonne les catégories
      final allCategories = <String>{};
      allCategories.addAll(configuredCategories);
      allCategories.addAll(existingCategories);

      // 4. Applique l'ordre configuré
      final orderedCategories = <String>[];
      for (final cat in configuredCategories) {
        if (allCategories.contains(cat)) {
          orderedCategories.add(cat);
        }
      }

      // Ajoute les autres catégories par ordre alphabétique
      final remainingCategories = allCategories
          .where((cat) => !configuredCategories.contains(cat))
          .toList()
        ..sort();
      orderedCategories.addAll(remainingCategories);

      if (mounted) {
        setState(() {
          _categories = orderedCategories;
          _categoriesLoaded = true;

          // Si pas de catégorie sélectionnée, prend la première disponible
          if (_selectedCategory.isEmpty && _categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement catégories: $e');
      if (mounted) {
        setState(() {
          _categories = ['Pizzas', 'Entrées', 'Plats', 'Desserts', 'Boissons'];
          _categoriesLoaded = true;
          if (_selectedCategory.isEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final x = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
      if (x == null) return;

      final bytes = await x.readAsBytes(); // ← on attend ici
      if (!mounted) return;
      setState(() => _pickedBytes = bytes); // ← setState synchrone
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de sélectionner la photo')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedBytes == null) return _imageUrl; // pas de nouvelle image

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path =
          'restaurants/${widget.restaurantId}/media/$fileName'; // ⚠️ forcer le bon bucket (firebasestorage.app)
      final storage = FirebaseStorage.instanceFor(
        bucket: 'smartmenu-mvp.firebasestorage.app',
      );
      final ref = storage.ref().child(path);

      // (debug utile)
      debugPrint('UPLOAD → bucket=${ref.bucket} path=${ref.fullPath}');

// Upload d'abord
      final uploadTask = ref.putData(_pickedBytes!);
      final snapshot = await uploadTask;

// Puis récupère l'URL
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('UPLOAD OK → $url');
      return url;
    } on FirebaseException catch (e) {
      final msg = e.code == 'permission-denied'
          ? 'Accès refusé au Storage (membership/règles).'
          : 'Erreur Storage: ${e.code} – ${e.message ?? ''}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
      return null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur upload: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload de l'image si nécessaire
      String? finalImageUrl = _imageUrl; // Garde l'URL existante par défaut

      if (_pickedBytes != null) {
        // Nouvelle image sélectionnée - on upload
        try {
          final newUrl = await _uploadImage();
          if (newUrl != null && newUrl.isNotEmpty) {
            finalImageUrl = newUrl;
            debugPrint('DEBUG: Nouvelle URL uploadée = $newUrl');
          } else {
            debugPrint('DEBUG: Échec upload, on garde l\'ancienne URL');
          }
        } catch (e) {
          debugPrint('DEBUG: Erreur upload = $e');
          // On continue avec l'ancienne URL en cas d'erreur
        }
      }

      // Données du plat
      final itemData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'signature': _isSignature,
        'visible': _isVisible,
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Gestion de l'image
      if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
        itemData['imageUrl'] = finalImageUrl;
        itemData['image'] = finalImageUrl; // Pour compatibilité
        debugPrint('DEBUG: Image sauvegardée avec URL = $finalImageUrl');
      }

      // Cas suppression image en mode édition (aucune nouvelle image choisie)
      if (widget.itemId != null && _removeImage && _pickedBytes == null) {
        itemData['imageUrl'] = FieldValue.delete();
        itemData['image'] = FieldValue.delete();
        debugPrint('DEBUG: Suppression image demandée');
      }

      final menuCollection = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menus');

      if (widget.itemId != null) {
        // Modification
        await menuCollection.doc(widget.itemId).update(itemData);
        debugPrint('DEBUG: Plat modifié avec succès');
      } else {
        // Création
        itemData['created_at'] = FieldValue.serverTimestamp();
        await menuCollection.add(itemData);
        debugPrint('DEBUG: Plat créé avec succès');

        // Mise à jour de categoriesOrder si nouvelle catégorie
        final detailsRef = FirebaseFirestore.instance
            .collection('restaurants')
            .doc(widget.restaurantId)
            .collection('info')
            .doc('details');

        await FirebaseFirestore.instance.runTransaction((tx) async {
          final snap = await tx.get(detailsRef);
          final data = snap.data() ?? {};
          final List<dynamic> order = List.of(data['categoriesOrder'] ?? []);

          if (!order.contains(_selectedCategory)) {
            if (order.isEmpty) {
              order.insert(0, _selectedCategory);
            } else {
              order.add(_selectedCategory);
            }
            tx.set(detailsRef, {'categoriesOrder': order},
                SetOptions(merge: true));
          }
        });
      }

      if (mounted) {
        // Reset du flag de suppression après sauvegarde réussie
        setState(() {
          _removeImage = false;
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.itemId != null
                ? 'Plat modifié avec succès'
                : 'Plat ajouté avec succès'),
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG: Erreur sauvegarde = $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCurrencySymbol() {
    switch (_restaurantCurrency) {
      case 'ILS':
        return '₪';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '€';
    }
  }

  String currencyToSymbol(String code) {
    switch (code) {
      case 'ILS':
        return '₪';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le plat' : 'Ajouter un plat'),
        // backgroundColor: AppColors.primary,
        // foregroundColor: Colors.white,
        // elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- IMAGE + ACTIONS ---
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Aperçu (bytes > url > placeholder)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: () {
                        if (_pickedBytes != null) {
                          return Image.memory(_pickedBytes!, fit: BoxFit.cover);
                        }
                        if (_imageUrl != null && _imageUrl!.isNotEmpty) {
                          return Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImagePlaceholder(),
                          );
                        }
                        return _buildImagePlaceholder();
                      }(),
                    ),
                  ),

                  // Bouton "Retirer" en overlay si on a une image
                  if (_pickedBytes != null || (_imageUrl?.isNotEmpty ?? false))
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        child: IconButton(
                          tooltip: 'Retirer la photo',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _pickedBytes = null;
                              _imageUrl = null;
                              _removeImage =
                                  true; // <- important pour la sauvegarde
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Boutons sous l’image
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await _pickImage();
                    setState(() {
                      _removeImage =
                          false; // on annule la suppression si on met une nouvelle image
                    });
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    _pickedBytes != null || (_imageUrl?.isNotEmpty ?? false)
                        ? 'Changer la photo'
                        : 'Ajouter une photo',
                  ),
                ),
                if (_pickedBytes != null || (_imageUrl?.isNotEmpty ?? false))
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _pickedBytes = null;
                        _imageUrl = null;
                        _removeImage = true;
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Retirer',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Nom
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du plat *',
                prefixIcon: Icon(Icons.restaurant_menu),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Prix et catégorie
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix *',
                      prefixText: '${_getCurrencySymbol()} ',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prix obligatoire';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Prix invalide';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: _categoriesLoaded
                      ? DropdownButtonFormField<String>(
                          value: _categories.contains(_selectedCategory)
                              ? _selectedCategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Catégorie',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            }
                          },
                        )
                      : const CircularProgressIndicator(), // Loading pendant le chargement
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Plat signature'),
                      subtitle: const Text('Mettre en avant ce plat'),
                      value: _isSignature,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _isSignature = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Visible sur le menu'),
                      subtitle: const Text('Les clients peuvent voir ce plat'),
                      value: _isVisible,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _isVisible = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMenuItem,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEditing ? 'Modifier' : 'Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return GestureDetector(
      onTap: () async {
        await _pickImage();
        setState(() {
          _removeImage = false;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Ajouter une photo',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cliquez pour sélectionner',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
