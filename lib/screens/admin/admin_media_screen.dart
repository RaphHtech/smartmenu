import 'package:image_picker/image_picker.dart';
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
            path: 'restaurants/${widget.restaurantId}/menu/${item.name}',
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

  void _pickFiles() async {
    try {
      final picker = ImagePicker();
      final XFile? x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (x == null) return;

      final Uint8List bytes = await x.readAsBytes();
      final String name = x.name;
      final String ext = name.split('.').last.toLowerCase();
      final String contentType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';

      setState(() {
        _uploadError = null;
        _uploadProgress = 0;
      });

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$name';
      final ref = FirebaseStorage.instance
          .ref()
          .child('restaurants/${widget.restaurantId}/media/$fileName');

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {'originalName': name},
        ),
      );

      uploadTask.snapshotEvents.listen((s) {
        if (!mounted) return;
        setState(() {
          _uploadProgress =
              s.totalBytes == 0 ? 0 : s.bytesTransferred / s.totalBytes;
        });
      });

      await uploadTask;
      await _loadMediaItems();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import réussi')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadError = 'Erreur upload: $e');
    }
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

          const SizedBox(height: AdminTokens.space24),

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
      margin: const EdgeInsets.all(AdminTokens.space16),
      child: Container(
        height: 180,
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
    return GridView.builder(
      padding: const EdgeInsets.all(AdminTokens.space16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.80,
      ),
      itemCount: _mediaItems.length,
      itemBuilder: (context, index) {
        final item = _mediaItems[index];
        return _buildMediaCard(item);
      },
    );
  }

  Widget _buildMediaCard(MediaItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image 80% de la hauteur
          Expanded(
            flex: 3,
            child: SizedBox(
              width: double.infinity,
              height: 28,
              child: Image.network(
                item.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AdminTokens.neutral100,
                    child: const Icon(Icons.broken_image,
                        color: AdminTokens.neutral400),
                  );
                },
              ),
            ),
          ),

          // Zone info compacte 25%
          // Zone info compacte 25%
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ligne taille + supprimer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _formatFileSize(item.size),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AdminTokens.neutral600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _deleteMedia(item),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Bouton utiliser
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => _assignToItem(item),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        foregroundColor: Colors.blue,
                      ),
                      child: const Text('Utiliser',
                          style: TextStyle(fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
          ), // Zone info compacte 25%
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
