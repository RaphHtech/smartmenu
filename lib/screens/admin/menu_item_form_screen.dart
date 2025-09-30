import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// import '../../core/constants/colors.dart';
// import '../../models/menu_item.dart';
import '../../core/design/admin_tokens.dart';

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
  final _priceController = TextEditingController();

  String _selectedCategory = 'Pizzas';
  String _restaurantCurrency = 'ILS';
  bool _isVisible = true;
  bool _isLoading = false;
  bool _removeImage = false;

  // Image (portable Web + Mobile)
  Uint8List? _pickedBytes; // web/mobile-safe
  String? _imageUrl; // current or newly uploaded
  // String? _initialCategory;

  List<String> _categories = [];
  bool _categoriesLoaded = false;
  bool _featured = false;
  List<String> _badges = [];
// NOUVEAU : Gestion multilingue
  final Map<String, TextEditingController> _nameControllers = {
    'he': TextEditingController(),
    'en': TextEditingController(),
    'fr': TextEditingController(),
  };

  final Map<String, TextEditingController> _descriptionControllers = {
    'he': TextEditingController(),
    'en': TextEditingController(),
    'fr': TextEditingController(),
  };

  String _currentLang = 'he'; // Tab actif par défaut

  Future<void> ensureCategoryInOrder(
      String restaurantId, String newCategoryLabel) async {
    final category = newCategoryLabel.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (category.isEmpty) return;

    final detailsRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('info')
        .doc('details');

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(detailsRef);
      final data = snap.data() ?? {};

      final List<String> order =
          List<String>.from(data['categoriesOrder'] ?? []);
      final Set<String> hidden =
          Set<String>.from(data['categoriesHidden'] ?? []);

      // Cherche en insensible à la casse
      final existsIndex = order.indexWhere(
          (existing) => existing.toLowerCase() == category.toLowerCase());

      if (existsIndex == -1) {
        // Nouvelle catégorie : ajouter à la fin
        order.add(category);
      }

      // Rendre visible par défaut (retirer du set caché)
      hidden.removeWhere((h) => h.toLowerCase() == category.toLowerCase());

      tx.set(
          detailsRef,
          {
            'categoriesOrder': order,
            'categoriesHidden': hidden.toList(),
          },
          SetOptions(merge: true));
    });
  }

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

      // Charger les traductions
      final translations = data['translations'] as Map<String, dynamic>?;

      if (translations != null) {
        // Charger chaque langue
        for (final lang in ['he', 'en', 'fr']) {
          final trans = translations[lang] as Map<String, dynamic>?;
          if (trans != null) {
            _nameControllers[lang]?.text = trans['name']?.toString() ?? '';
            _descriptionControllers[lang]?.text =
                trans['description']?.toString() ?? '';
          }
        }
      } else {
        // Fallback ancien format
        _nameControllers['fr']?.text = data['name']?.toString() ?? '';
        _descriptionControllers['fr']?.text =
            data['description']?.toString() ?? '';
      }

      _priceController.text = data['price']?.toString() ?? '';
      _selectedCategory = data['category']?.toString() ?? 'Pizzas';
      _isVisible = data['visible'] ?? true;
      _featured = data['featured'] ?? false;
      _badges = List<String>.from(data['badges'] ?? []);
      _imageUrl = data['imageUrl'] ?? data['image'];
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
    _nameControllers[_currentLang]!.dispose();
    _descriptionControllers[_currentLang]!.dispose();
    _priceController.dispose();

    // NOUVEAU : Dispose des controllers multilingues
    for (final controller in _nameControllers.values) {
      controller.dispose();
    }
    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }

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
      String? finalImageUrl = _imageUrl;

      if (_pickedBytes != null) {
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
        }
      }

      // NOUVEAU : Construire l'objet translations
      final translations = <String, dynamic>{};
      final translationStatus = <String, String>{};

      for (final lang in ['he', 'en', 'fr']) {
        final name = _nameControllers[lang]!.text.trim();
        final description = _descriptionControllers[lang]!.text.trim();

        if (name.isNotEmpty || description.isNotEmpty) {
          translations[lang] = {
            'name': name,
            'description': description,
          };

          // Statut : complete si nom ET description, partial si seulement l'un des deux
          if (name.isNotEmpty && description.isNotEmpty) {
            translationStatus[lang] = 'complete';
          } else if (name.isNotEmpty || description.isNotEmpty) {
            translationStatus[lang] = 'partial';
          } else {
            translationStatus[lang] = 'missing';
          }
        } else {
          translationStatus[lang] = 'missing';
        }
      }

      // Données du plat avec traductions
      final itemData = <String, dynamic>{
        'translations': translations,
        'translationStatus': translationStatus,
        'price': double.parse(_priceController.text),
        'category': _selectedCategory,
        'signature': false,
        'featured': _featured,
        'badges': _badges,
        'visible': _isVisible,
        'updated_at': FieldValue.serverTimestamp(),

        // Cache legacy pour compatibilité (langue principale = hébreu)
        'name': _nameControllers['he']!.text.trim(),
        'description': _descriptionControllers['he']!.text.trim(),
      };

      // Gestion de l'image
      if (finalImageUrl != null && finalImageUrl.isNotEmpty) {
        itemData['imageUrl'] = finalImageUrl;
        itemData['image'] = finalImageUrl;
        debugPrint('DEBUG: Image sauvegardée avec URL = $finalImageUrl');
      }

      // Suppression image
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

        await ensureCategoryInOrder(widget.restaurantId, _selectedCategory);
      }

      if (mounted) {
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
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 768;

            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sidebar image (gauche)
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.all(AdminTokens.space24),
                      child: _buildImageSection(),
                    ),
                  ),
                  // Formulaire (droite)
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AdminTokens.space24),
                      children: _buildFormFields(),
                    ),
                  ),
                ],
              );
            } else {
              // Mobile - layout vertical existant
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 24),
                  ..._buildFormFields(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // NOUVEAU : Tabs langues avec indicateurs de statut
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminTokens.radius12),
          border: Border.all(color: AdminTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Row(
              children: [
                _buildLanguageTab('he', '🇮🇱 עברית'),
                _buildLanguageTab('en', '🇬🇧 English'),
                _buildLanguageTab('fr', '🇫🇷 Français'),
              ],
            ),
            const Divider(height: 1),

            // Contenu du tab actif
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Nom
                  TextFormField(
                    controller: _nameControllers[_currentLang]!,
                    decoration: InputDecoration(
                      labelText: 'Nom du plat *',
                      prefixIcon: const Icon(Icons.restaurant_menu),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius12),
                      ),
                    ),
                    validator: (value) {
                      if (_currentLang == 'he' &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Le nom en hébreu est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionControllers[_currentLang]!,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 12),

                  // Bouton copier depuis autre langue
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentLang != 'fr' &&
                          _nameControllers['fr']!.text.trim().isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _copyFromLanguage('fr'),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copier depuis français'),
                          style: TextButton.styleFrom(
                            foregroundColor: AdminTokens.primary600,
                          ),
                        ),
                      if (_currentLang != 'he' &&
                          _nameControllers['he']!.text.trim().isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _copyFromLanguage('he'),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copier depuis hébreu'),
                          style: TextButton.styleFrom(
                            foregroundColor: AdminTokens.primary600,
                          ),
                        ),
                      if (_currentLang != 'en' &&
                          _nameControllers['en']!.text.trim().isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _copyFromLanguage('en'),
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copier depuis anglais'),
                          style: TextButton.styleFrom(
                            foregroundColor: AdminTokens.primary600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Prix et catégorie (reste identique)
      Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Prix *',
                prefixText: '${_getCurrencySymbol()} ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AdminTokens.radius12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
                    decoration: InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius12),
                      ),
                    ),
                    elevation: 12,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AdminTokens.neutral700,
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
                : const CircularProgressIndicator(),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // Options (reste identique)
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminTokens.radius16),
          boxShadow: AdminTokens.shadowMd,
          border: Border.all(color: AdminTokens.border),
        ),
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
                title: const Text('Mettre en avant'),
                subtitle: const Text('Épingler en haut de la catégorie'),
                value: _featured,
                onChanged: (value) => setState(() => _featured = value),
              ),
              const SizedBox(height: 16),
              Text('Badges', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    ['populaire', 'nouveau', 'spécialité', 'chef', 'saisonnier']
                        .map((badge) => FilterChip(
                              label: Text(badge),
                              selected: _badges.contains(badge),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _badges.add(badge);
                                  } else {
                                    _badges.remove(badge);
                                  }
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AdminTokens.primary50,
                              checkmarkColor: AdminTokens.primary600,
                              labelStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _badges.contains(badge)
                                    ? AdminTokens.primary600
                                    : AdminTokens.neutral700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AdminTokens.radius12),
                                side: BorderSide(
                                  color: _badges.contains(badge)
                                      ? AdminTokens.primary600
                                      : AdminTokens.border,
                                ),
                              ),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Visible sur le menu'),
                subtitle: const Text('Les clients peuvent voir ce plat'),
                value: _isVisible,
                activeColor: AdminTokens.primary600,
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

      // Boutons (reste identique)
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                  : Text(widget.itemId != null ? 'Modifier' : 'Ajouter'),
            ),
          ),
        ],
      ),
    ];
  }

// Construit un tab de langue avec indicateur de statut
  Widget _buildLanguageTab(String langCode, String label) {
    final isActive = _currentLang == langCode;
    final hasContent = _nameControllers[langCode]!.text.trim().isNotEmpty;

    Color statusColor;
    if (hasContent) {
      statusColor = Colors.green;
    } else if (langCode == 'he') {
      statusColor = Colors.orange; // Obligatoire mais vide
    } else {
      statusColor = Colors.grey.shade300; // Optionnel et vide
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentLang = langCode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? AdminTokens.primary50 : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? AdminTokens.primary600 : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AdminTokens.primary600
                        : AdminTokens.neutral700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Copie le contenu depuis une autre langue
  void _copyFromLanguage(String sourceLang) {
    setState(() {
      _nameControllers[_currentLang]!.text = _nameControllers[sourceLang]!.text;
      _descriptionControllers[_currentLang]!.text =
          _descriptionControllers[sourceLang]!.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Contenu copié depuis ${sourceLang == 'he' ? 'hébreu' : sourceLang == 'en' ? 'anglais' : 'français'}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AdminTokens.radius16),
            boxShadow: AdminTokens.shadowMd,
            border: Border.all(color: AdminTokens.border),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  child: () {
                    if (_pickedBytes != null) {
                      return Image.memory(_pickedBytes!, fit: BoxFit.cover);
                    }
                    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
                      return Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      );
                    }
                    return _buildImagePlaceholder();
                  }(),
                ),
              ),
              // Bouton supprimer si image présente
              if (_pickedBytes != null || (_imageUrl?.isNotEmpty ?? false))
                Positioned(
                  top: AdminTokens.space8,
                  right: AdminTokens.space8,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    child: IconButton(
                      tooltip: 'Retirer la photo',
                      icon:
                          const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _pickedBytes = null;
                          _imageUrl = null;
                          _removeImage = true;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AdminTokens.space16),
        // Boutons d'action image
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await _pickImage();
                  setState(() => _removeImage = false);
                },
                icon: const Icon(Icons.camera_alt, size: 18),
                label: Text(
                  _pickedBytes != null || (_imageUrl?.isNotEmpty ?? false)
                      ? 'Changer'
                      : 'Ajouter',
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminTokens.radius12),
                  ),
                  side: const BorderSide(color: AdminTokens.border),
                ),
              ),
            ),
            if (_pickedBytes != null || (_imageUrl?.isNotEmpty ?? false)) ...[
              const SizedBox(width: AdminTokens.space8),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _pickedBytes = null;
                    _imageUrl = null;
                    _removeImage = true;
                  });
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label:
                    const Text('Retirer', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AdminTokens.radius12),
                  ),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ],
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
