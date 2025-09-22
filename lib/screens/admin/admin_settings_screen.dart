import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import '../../widgets/ui/admin_themed.dart';
import 'admin_restaurant_info_screen.dart';
import '../../screens/admin/category_manager_sheet.dart';
import '../../services/category_repository.dart';
import 'package:flutter/services.dart';
import '../../services/qr_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:html' as html;

class AdminSettingsScreen extends StatefulWidget {
  final String restaurantId;

  const AdminSettingsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isEditing = false;
  String? _currentName;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRestaurantName();
    _addCodeToExistingRestaurant();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (doc.exists && mounted) {
        final name = doc.data()?['name'] as String? ?? 'Mon Restaurant';
        setState(() {
          _currentName = name;
          _nameController.text = name;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger le nom du restaurant';
      });
    }
  }

  Future<void> _saveRestaurantName() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .update({
        'name': _nameController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _currentName = _nameController.text.trim();
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nom du restaurant mis à jour avec succès'),
            backgroundColor: AdminTokens.success500,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la sauvegarde : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _currentName ?? '';
      _isEditing = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'Paramètres',
      restaurantId: widget.restaurantId,
      activeRoute: '/settings',
      breadcrumbs: const ['Dashboard', 'Paramètres'],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Restaurant
            const Text(
              'Restaurant',
              style: AdminTypography.headlineLarge,
            ),

            const SizedBox(height: AdminTokens.space16),

            // Card nom restaurant
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AdminTokens.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          color: AdminTokens.primary600,
                        ),
                        const SizedBox(width: AdminTokens.space12),
                        const Expanded(
                          child: Text(
                            'Nom du restaurant',
                            style: AdminTypography.headlineMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_isEditing)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                                _error = null;
                              });
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: 'Modifier',
                          ),
                      ],
                    ),
                    const SizedBox(height: AdminTokens.space16),
                    if (!_isEditing) ...[
                      // Mode lecture
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AdminTokens.space16),
                        decoration: BoxDecoration(
                          color: AdminTokens.neutral50,
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          border: Border.all(color: AdminTokens.neutral200),
                        ),
                        child: Text(
                          _currentName ?? 'Chargement...',
                          style: AdminTypography.bodyLarge,
                        ),
                      ),
                    ] else ...[
                      // Mode édition
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom du restaurant',
                                hintText: 'Ex: Pizza Mario',
                                prefixIcon: Icon(Icons.restaurant),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Le nom du restaurant est obligatoire';
                                }
                                if (value.trim().length < 2) {
                                  return 'Le nom doit contenir au moins 2 caractères';
                                }
                                if (value.trim().length > 50) {
                                  return 'Le nom ne peut pas dépasser 50 caractères';
                                }
                                return null;
                              },
                              maxLength: 50,
                            ),
                            const SizedBox(height: AdminTokens.space16),

                            if (_error != null) ...[
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(AdminTokens.space12),
                                decoration: BoxDecoration(
                                  color: AdminTokens.error50,
                                  borderRadius: BorderRadius.circular(
                                      AdminTokens.radius8),
                                ),
                                child: Text(
                                  _error!,
                                  style: AdminTypography.bodySmall.copyWith(
                                    color: AdminTokens.error500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AdminTokens.space16),
                            ],

                            // Boutons d'action
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : _cancelEdit,
                                    child: const Text('Annuler'),
                                  ),
                                ),
                                const SizedBox(width: AdminTokens.space16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _saveRestaurantName,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Text('Enregistrer'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AdminTokens.space24),

            // Autres paramètres
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Informations détaillées'),
                subtitle: const Text('Description, bandeau promo, devise'),
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

            const SizedBox(height: AdminTokens.space32),

            // Section Gestion des catégories
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AdminTokens.space20),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Gérer les catégories'),
                    subtitle: const Text('Réorganiser, masquer et renommer'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final state = await CategoryManager.getLiveState(
                              widget.restaurantId)
                          .first;
                      if (mounted) {
                        CategoryManagerSheet.show(
                            context, widget.restaurantId, state);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: AdminTokens.space32),

            // Section Intégration
            const Text(
              'Intégration',
              style: AdminTypography.headlineLarge,
            ),
            const SizedBox(height: AdminTokens.space16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AdminTokens.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: AdminTokens.primary600,
                        ),
                        SizedBox(width: AdminTokens.space12),
                        Text(
                          'Code restaurant',
                          style: AdminTypography.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AdminTokens.space16),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(widget.restaurantId)
                          .collection('info')
                          .doc('details')
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                                {};
                        final code =
                            data['slug'] ?? data['code'] ?? widget.restaurantId;

                        return Column(
                          children: [
                            // Code restaurant - responsive
                            _buildResponsiveInfoRow('Code restaurant', code),
                            const SizedBox(height: AdminTokens.space12),

                            // URL publique - responsive
                            _buildResponsiveInfoRow(
                              'URL publique',
                              '${Uri.base.origin}/r/${data['slug'] ?? data['code'] ?? widget.restaurantId}',
                              isUrl: true,
                            ),
                            const SizedBox(height: AdminTokens.space20),

                            // Boutons d'action - responsive
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobile = constraints.maxWidth < 400;

                                if (isMobile) {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.qr_code,
                                              size: 18),
                                          label: const Text('Générer QR'),
                                          onPressed: () =>
                                              _generateQRCode(code),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AdminTokens.space12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon:
                                              const Icon(Icons.share, size: 18),
                                          label: const Text('Partager'),
                                          onPressed: () =>
                                              _shareRestaurant(code),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: const Icon(Icons.qr_code,
                                              size: 18),
                                          label: const Text('Générer QR'),
                                          onPressed: () =>
                                              _generateQRCode(code),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: AdminTokens.space12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon:
                                              const Icon(Icons.share, size: 18),
                                          label: const Text('Partager'),
                                          onPressed: () =>
                                              _shareRestaurant(code),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveInfoRow(String label, String value,
      {bool isUrl = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 400;

        if (isMobile) {
          // Layout vertical sur mobile
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AdminTokens.space12),
            decoration: BoxDecoration(
              color: AdminTokens.neutral50,
              borderRadius: BorderRadius.circular(AdminTokens.radius8),
              border: Border.all(color: AdminTokens.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AdminTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AdminTokens.neutral600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: AdminTypography.bodyMedium.copyWith(
                          fontFamily: isUrl ? 'Monaco' : null,
                          fontSize: isUrl ? 12 : 14,
                        ),
                        maxLines: isUrl ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AdminTokens.primary50,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copié : ${isUrl ? 'URL' : value}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: AdminTokens.primary600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          // Layout horizontal sur desktop (version originale)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: AdminTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AdminTokens.neutral600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AdminTypography.bodyLarge.copyWith(
                    fontFamily: isUrl ? 'Monaco' : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copié : $value')),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  void _generateQRCode(String code) {
    showDialog(
      context: context,
      builder: (context) => _QRGeneratorDialog(
        restaurantId: widget.restaurantId,
        restaurantName: _currentName ?? 'Mon Restaurant',
        slug: code,
      ),
    );
  }

  void _shareRestaurant(String code) {
    final url = QRService.generateRestaurantUrl(code);
    final restaurantName = _currentName ?? 'Mon Restaurant';

    showDialog(
      context: context,
      builder: (context) => _ShareDialog(
        url: url,
        restaurantName: restaurantName,
        code: code,
      ),
    );
  }

  Future<void> _addCodeToExistingRestaurant() async {
    final doc = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('info')
        .doc('details')
        .get();

    final data = doc.data() ?? {};
    if (data['code'] != null) return; // Déjà un code

    final name = data['name'] ?? 'restaurant';
    final code = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    await doc.reference.update({'code': code});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code généré : $code')),
    );
  }
}

class _QRGeneratorDialog extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String slug;

  const _QRGeneratorDialog({
    required this.restaurantId,
    required this.restaurantName,
    required this.slug,
  });

  @override
  State<_QRGeneratorDialog> createState() => _QRGeneratorDialogState();
}

class _QRGeneratorDialogState extends State<_QRGeneratorDialog> {
  final _messageController = TextEditingController();
  QRSize _selectedSize = QRSize.medium;
  bool _isLoading = false;
  bool _isSaving = false;
  QRConfig? _config;

  late String _qrUrl;

  @override
  void initState() {
    super.initState();
    _qrUrl = QRService.generateRestaurantUrl(widget.slug);
    _loadConfig();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);

    try {
      final config = await QRService.getQRConfig(widget.restaurantId);
      setState(() {
        _config = config;
        _messageController.text = config.customMessage ?? '';
        _selectedSize = QRSize.fromKey(config.size);
      });
    } catch (e) {
      // Utiliser config par défaut en cas d'erreur
      setState(() {
        _config = const QRConfig();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);

    try {
      await QRService.saveQRConfig(
        widget.restaurantId,
        customMessage: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        showLogo: true,
        size: _selectedSize.key,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée'),
            backgroundColor: AdminTokens.success500,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AdminTokens.error500,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _downloadQR() {
    try {
      // Pour Flutter Web, créer un élément de téléchargement
      // Note: En production, il faudrait générer une vraie image PNG
      final qrData = '''
QR Code Restaurant: ${widget.restaurantName}
URL: $_qrUrl
Taille: ${_selectedSize.label}
${_messageController.text.isNotEmpty ? 'Message: ${_messageController.text}' : ''}
''';

      final blob = html.Blob([qrData], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement()
        ..href = url
        ..download = 'qr-${widget.slug}-${_selectedSize.key}.txt'
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code téléchargé (format texte pour demo)'),
          backgroundColor: AdminTokens.success500,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur téléchargement: $e'),
          backgroundColor: AdminTokens.error500,
        ),
      );
    }
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _qrUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copiée dans le presse-papier'),
        backgroundColor: AdminTokens.success500,
      ),
    );
  }
// Remplacer le build() method de _QRGeneratorDialogState par :

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement...'),
            ],
          ),
        ),
      );
    }

    // Adapter selon la taille d'écran
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final maxHeight = isMobile ? screenHeight * 0.85 : 700.0;
    final maxWidth = isMobile ? screenWidth * 0.95 : 600.0;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - plus compact sur mobile
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : AdminTokens.space20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 6 : AdminTokens.space8),
                    decoration: BoxDecoration(
                      color: AdminTokens.primary50,
                      borderRadius: BorderRadius.circular(AdminTokens.radius8),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: AdminTokens.primary600,
                      size: isMobile ? 20 : AdminTokens.iconLg,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : AdminTokens.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Générateur QR Code',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.restaurantName,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: AdminTokens.neutral600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Content scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : AdminTokens.space20),
                child: Column(
                  children: [
                    // QR Preview - plus compact sur mobile
                    Container(
                      padding:
                          EdgeInsets.all(isMobile ? 16 : AdminTokens.space20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius8),
                        border: Border.all(color: AdminTokens.neutral200),
                      ),
                      child: Column(
                        children: [
                          // Message personnalisé (si défini)
                          if (_messageController.text.isNotEmpty) ...[
                            Text(
                              _messageController.text,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: AdminTokens.neutral900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                                height: isMobile ? 12 : AdminTokens.space16),
                          ],

                          // QR Code - taille adaptée
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AdminTokens.radius8),
                              border: Border.all(color: AdminTokens.neutral200),
                            ),
                            child: QrImageView(
                              data: _qrUrl,
                              version: QrVersions.auto,
                              size:
                                  isMobile ? 150 : 200, // Plus petit sur mobile
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                            ),
                          ),

                          SizedBox(height: isMobile ? 12 : AdminTokens.space16),

                          // Nom du restaurant
                          Text(
                            widget.restaurantName,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: AdminTokens.neutral800,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: isMobile ? 6 : AdminTokens.space8),

                          Text(
                            'Scannez pour accéder au menu',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: AdminTokens.neutral500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isMobile ? 16 : AdminTokens.space24),

                    // Configuration - layout adaptatif
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuration',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: isMobile ? 12 : AdminTokens.space16),

                        // Message personnalisé - plus compact
                        TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Message personnalisé (optionnel)',
                            hintText: 'Ex: Bienvenue chez nous !',
                            prefixIcon: Icon(Icons.message_outlined,
                                size: isMobile ? 20 : 24),
                            helperText: 'Affiché au-dessus du QR code',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: isMobile ? 12 : 16,
                            ),
                          ),
                          maxLength: 80,
                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                          onChanged: (_) => setState(() {}), // Refresh preview
                        ),

                        SizedBox(height: isMobile ? 16 : AdminTokens.space20),

                        // Taille du QR - plus compact sur mobile
                        Text(
                          'Taille de téléchargement',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: isMobile ? 8 : AdminTokens.space8),

                        // Radio buttons plus compacts sur mobile
                        ...QRSize.values.map((size) => RadioListTile<QRSize>(
                              title: Text(
                                size.label,
                                style: TextStyle(fontSize: isMobile ? 14 : 16),
                              ),
                              subtitle: Text(
                                '${size.pixels}x${size.pixels} pixels',
                                style: TextStyle(fontSize: isMobile ? 12 : 14),
                              ),
                              value: size,
                              groupValue: _selectedSize,
                              onChanged: (value) {
                                setState(() => _selectedSize = value!);
                              },
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 4 : 16,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(),

            // Actions - layout adaptatif
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : AdminTokens.space20),
              child: isMobile
                  ? Column(
                      children: [
                        // URL info sur mobile
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AdminTokens.neutral50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AdminTokens.neutral200),
                          ),
                          child: Text(
                            _qrUrl,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AdminTokens.neutral700,
                              fontFamily: 'Monaco',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Boutons empilés verticalement sur mobile
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Télécharger'),
                            onPressed: _downloadQR,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.save, size: 18),
                            label: const Text('Sauvegarder'),
                            onPressed: _isSaving ? null : _saveConfig,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // URL info sur desktop
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'URL publique',
                                style: AdminTypography.bodySmall.copyWith(
                                  color: AdminTokens.neutral500,
                                ),
                              ),
                              GestureDetector(
                                onTap: _copyUrl,
                                child: Text(
                                  _qrUrl,
                                  style: AdminTypography.bodySmall.copyWith(
                                    color: AdminTokens.primary600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: AdminTokens.space16),

                        // Boutons côte à côte sur desktop
                        OutlinedButton.icon(
                          icon: const Icon(Icons.download,
                              size: AdminTokens.iconSm),
                          label: const Text('Télécharger'),
                          onPressed: _downloadQR,
                        ),

                        const SizedBox(width: AdminTokens.space12),

                        ElevatedButton.icon(
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save,
                                  size: AdminTokens.iconSm),
                          label: const Text('Sauvegarder'),
                          onPressed: _isSaving ? null : _saveConfig,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareDialog extends StatelessWidget {
  final String url;
  final String restaurantName;
  final String code;

  const _ShareDialog({
    required this.url,
    required this.restaurantName,
    required this.code,
  });

  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text('URL copiée dans le presse-papier'),
          ],
        ),
        backgroundColor: AdminTokens.success500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareViaEmail(BuildContext context) {
    final subject = Uri.encodeComponent('Menu $restaurantName - SmartMenu');
    final body = Uri.encodeComponent('''
Découvrez notre menu digital !

Restaurant : $restaurantName
Code d'accès : $code

Accès direct : $url

Scannez le QR code sur votre table ou saisissez le code "$code" sur smartmenu.app

---
Propulsé par SmartMenu
''');

    final emailUrl = 'mailto:?subject=$subject&body=$body';

    try {
      html.window.open(emailUrl, '_blank');
      Navigator.of(context).pop();
    } catch (e) {
      _copyUrl(context);
    }
  }

  void _shareViaSMS(BuildContext context) {
    final message =
        Uri.encodeComponent('Menu $restaurantName: $url (Code: $code)');

    final smsUrl = 'sms:?body=$message';

    try {
      html.window.open(smsUrl, '_blank');
      Navigator.of(context).pop();
    } catch (e) {
      _copyUrl(context);
    }
  }

  void _shareViaWhatsApp(BuildContext context) {
    final message =
        Uri.encodeComponent('Découvrez le menu de *$restaurantName* ! 🍽️\n\n'
            'Accès direct: $url\n'
            'Ou code: *$code*\n\n'
            '_Propulsé par SmartMenu_');

    final whatsappUrl = 'https://wa.me/?text=$message';

    try {
      html.window.open(whatsappUrl, '_blank');
      Navigator.of(context).pop();
    } catch (e) {
      _copyUrl(context);
    }
  }

  void _shareViaFacebook(BuildContext context) {
    final facebookUrl =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';

    try {
      html.window.open(facebookUrl, '_blank');
      Navigator.of(context).pop();
    } catch (e) {
      _copyUrl(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radius12),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 380,
          maxHeight: 400, // ✅ Hauteur fixe plus petite
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header compact
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // ✅ Plus petit
                  decoration: BoxDecoration(
                    color: AdminTokens.primary50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.share,
                    color: AdminTokens.primary600,
                    size: 18, // ✅ Plus petit
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Partager votre menu',
                        style: TextStyle(
                          fontSize: 16, // ✅ Plus petit
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminTokens.neutral600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // URL preview très compact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTokens.neutral50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AdminTokens.neutral200),
              ),
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 11,
                  color: AdminTokens.neutral700,
                  fontFamily: 'Monaco',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 16),

            // Méthodes de partage en ligne horizontale
            const Text(
              'Choisir une méthode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Options en rangée horizontale
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CompactShareOption(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: Colors.blue.shade600,
                  onTap: () => _shareViaEmail(context),
                ),
                _CompactShareOption(
                  icon: Icons.message_outlined,
                  label: 'SMS',
                  color: Colors.green.shade600,
                  onTap: () => _shareViaSMS(context),
                ),
                _CompactShareOption(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _shareViaWhatsApp(context),
                ),
                _CompactShareOption(
                  icon: Icons.facebook_outlined,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => _shareViaFacebook(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bouton copier
            SizedBox(
              width: double.infinity,
              height: 36, // ✅ Plus petit
              child: OutlinedButton.icon(
                onPressed: () => _copyUrl(context),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text(
                  'Copier le lien',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 60, // ✅ Largeur fixe
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
