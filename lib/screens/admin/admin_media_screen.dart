// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';

class AdminMediaScreen extends StatefulWidget {
  final String restaurantId;

  const AdminMediaScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminMediaScreen> createState() => _AdminMediaScreenState();
}

class _AdminMediaScreenState extends State<AdminMediaScreen> {
  List<MediaItem> _mediaItems = [];
  bool _isLoading = true;
  String? _uploadError;
  double? _uploadProgress;

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  Future<void> _loadMediaItems() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('restaurants/${widget.restaurantId}/media');
      final result = await storageRef.listAll();
      final items = <MediaItem>[];

      for (final item in result.items) {
        try {
          final url = await item.getDownloadURL();
          final metadata = await item.getMetadata();
          items.add(MediaItem(
            name: item.name,
            url: url,
            path: 'restaurants/${widget.restaurantId}/media/${item.name}',
            size: metadata.size ?? 0,
            uploadDate: metadata.timeCreated ?? DateTime.now(),
          ));
        } catch (e) {
          debugPrint('Erreur chargement item ${item.name}: $e');
        }
      }

      setState(() {
        _mediaItems = items
          ..sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _uploadError = 'Erreur chargement médias: $e';
      });
    }
  }

  Future<void> _handleFileDrop(html.File file) async {
    if (!_isValidImageFile(file)) {
      setState(() =>
          _uploadError = 'Format non supporté. Utilisez PNG, JPG ou WebP.');
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      setState(() => _uploadError = 'Fichier trop volumineux (max 5MB).');
      return;
    }

    setState(() {
      _uploadError = null;
      _uploadProgress = 0;
    });

    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      final data = reader.result as List<int>;
      final uint8List = Uint8List.fromList(data);

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('restaurants/${widget.restaurantId}/media/$fileName');
      final uploadTask = ref.putData(
          uint8List,
          SettableMetadata(
            contentType: file.type,
            customMetadata: {'originalName': file.name},
          ));

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;

      await _loadMediaItems(); // Reload list first
      setState(() => _uploadProgress = null); // Then hide progress
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploadée avec succès!')),
      );
    } catch (e) {
      setState(() {
        _uploadProgress = null;
        _uploadError = 'Erreur upload: $e';
      });
    }
  }

  bool _isValidImageFile(html.File file) {
    final validTypes = ['image/jpeg', 'image/png', 'image/webp'];
    return validTypes.contains(file.type.toLowerCase());
  }

  Future<void> _deleteMedia(MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le média'),
        content: Text('Voulez-vous vraiment supprimer "${item.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseStorage.instance
            .ref()
            .child('restaurants/${widget.restaurantId}/media/${item.name}')
            .delete();

        _loadMediaItems();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Média supprimé avec succès')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur suppression: $e')),
        );
      }
    }
  }

  void _pickFiles() {
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;

    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files != null) {
        for (final file in files) {
          _handleFileDrop(file);
        }
      }
    });
  }

  Future<void> _assignToItem(MediaItem item) async {
    // Récupérer la liste des plats
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menus')
        .get();

    if (!mounted) return;

    final items = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              'name': doc.data()['name'] ?? '',
              'category': doc.data()['category'] ?? '',
            })
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun plat disponible')),
      );
      return;
    }

    // Afficher modal de sélection
    final selectedItem = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _buildItemSelectionDialog(items),
    );

    if (selectedItem != null) {
      await _updateItemImage(selectedItem['id'],
          'restaurants/${widget.restaurantId}/media/${item.name}', item.url);
    }
  }

  Widget _buildItemSelectionDialog(List<Map<String, dynamic>> items) {
    final controller = TextEditingController();
    List<Map<String, dynamic>> filtered = List.of(items);

    void applyFilter(String query) {
      final q = query.trim().toLowerCase();
      filtered = items.where((item) {
        final name = (item['name'] as String).toLowerCase();
        final category = (item['category'] as String).toLowerCase();
        return name.contains(q) || category.contains(q);
      }).toList();
    }

    applyFilter('');

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Assigner à un plat'),
        content: SizedBox(
          width: 360,
          height: 460,
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un plat…',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => applyFilter(value)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(item['category']),
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateItemImage(
      String itemId, String storagePath, String url) async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('menus')
          .doc(itemId)
          .update({
        'image': storagePath, // ✅ Path Storage (source de vérité)
        'imageUrl': url, // ✅ URL pour affichage rapide
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image assignée avec succès')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Médias',
      restaurantId: widget.restaurantId,
      activeRoute: '/media',
      breadcrumbs: const ['Dashboard', 'Médias'],
      actions: [
        ElevatedButton.icon(
          onPressed: _pickFiles,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Ajouter'),
        ),
      ],
      child: Column(
        children: [
          // Zone drag-drop
          _buildDropZone(),

          if (_uploadError != null) _buildErrorAlert(),
          if (_uploadProgress != null) _buildProgressBar(),

          const SizedBox(height: AdminTokens.space16),

          // Liste des médias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _mediaItems.isEmpty
                    ? _buildEmptyState()
                    : _buildMediaGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return Container(
      margin: const EdgeInsets.all(AdminTokens.space8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: AdminTokens.neutral300,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AdminTokens.radius12),
          color: AdminTokens.neutral50,
        ),
        child: InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(AdminTokens.radius12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AdminTokens.neutral400,
                ),
                const SizedBox(height: AdminTokens.space12),
                Text(
                  'cliquez pour sélectionner',
                  style: AdminTypography.bodyLarge.copyWith(
                    color: AdminTokens.neutral600,
                  ),
                ),
                const SizedBox(height: AdminTokens.space8),
                Text(
                  'PNG, JPG, WebP - Max 5MB',
                  style: AdminTypography.bodySmall.copyWith(
                    color: AdminTokens.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AdminTokens.space16),
      padding: const EdgeInsets.all(AdminTokens.space12),
      decoration: BoxDecoration(
        color: AdminTokens.error50,
        borderRadius: BorderRadius.circular(AdminTokens.radius8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AdminTokens.error500),
          const SizedBox(width: AdminTokens.space8),
          Expanded(
            child: Text(
              _uploadError!,
              style: AdminTypography.bodyMedium
                  .copyWith(color: Colors.red.shade800),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _uploadError = null),
            icon: const Icon(Icons.close, color: AdminTokens.error500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AdminTokens.space16),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.upload, color: AdminTokens.primary600),
              const SizedBox(width: AdminTokens.space8),
              const Text('Upload en cours...'),
              const Spacer(),
              Text('${(_uploadProgress! * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: AdminTokens.space8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AdminTokens.neutral200,
            valueColor: const AlwaysStoppedAnimation(AdminTokens.primary500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AdminTokens.space16),
          const Text(
            'Aucun média',
            style: AdminTypography.headlineMedium,
          ),
          const SizedBox(height: AdminTokens.space8),
          Text(
            'Ajoutez vos premières images pour commencer',
            style: AdminTypography.bodyMedium.copyWith(
              color: AdminTokens.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 📱 Détection responsive basée sur la largeur
        final isDesktop = constraints.maxWidth > 800;
        final crossAxisCount = isDesktop ? 4 : 2; // 4 sur desktop, 2 sur mobile
        final childAspectRatio =
            isDesktop ? 0.85 : 0.9; // Ratio légèrement différent

        return GridView.builder(
          padding: EdgeInsets.all(
              isDesktop ? 16.0 : 12.0), // Moins de padding sur mobile
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isDesktop ? 16 : 12, // Espacement adaptatif
            mainAxisSpacing: isDesktop ? 16 : 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _mediaItems.length,
          itemBuilder: (context, index) => _buildMediaCard(_mediaItems[index]),
        );
      },
    );
  }

  Widget _buildMediaCard(MediaItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
        border: Border.all(color: AdminTokens.border),
        boxShadow: AdminTokens.shadowMd,
      ),
      child: Column(
        children: [
          // Image avec ratio 4:3 fixe + overlays
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AdminTokens.radius12),
                ),
                color: AdminTokens.neutral100,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AdminTokens.radius12),
                ),
                child: Stack(
                  children: [
                    // Image principale
                    Positioned.fill(
                      child: Image.network(
                        item.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AdminTokens.neutral100,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: AdminTokens.neutral400,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),

                    // Gradient pour lisibilité des overlays
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Taille en overlay (bas-gauche)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.image,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatFileSize(item.size),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton supprimer (haut-droite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _deleteMedia(item),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🎯 BARRE D'ACTION RESPONSIVE
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8), // Padding réduit
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 📱 Détection de la largeur disponible
                    final isSmall = constraints.maxWidth < 140;

                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AdminTokens.primary500,
                            AdminTokens.primary600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AdminTokens.primary600.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _assignToItem(item),
                          child: Container(
                            height: 36, // Hauteur réduite
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 8 : 12,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.restaurant_menu,
                                  size: 16, // Icône plus petite
                                  color: Colors.white,
                                ),
                                if (!isSmall) ...[
                                  const SizedBox(width: 6),
                                  const Flexible(
                                    child: Text(
                                      'Assigner',
                                      style: TextStyle(
                                        fontSize: 12, // Texte plus petit
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class MediaItem {
  final String name;
  final String url;
  final String path;
  final int size;
  final DateTime uploadDate;

  MediaItem({
    required this.name,
    required this.url,
    required this.path,
    required this.size,
    required this.uploadDate,
  });
}
