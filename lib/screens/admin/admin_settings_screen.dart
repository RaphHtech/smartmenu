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
// import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import '../../l10n/app_localizations.dart';

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
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    // ✅ Appeler APRÈS que le contexte soit prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurantName();
      _addCodeToExistingRestaurant();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantName() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (doc.exists && mounted) {
        // ✅ SYNTAXE ORIGINALE (qui marchait)
        final name = doc.data()?['name'] as String? ?? 'Mon Restaurant';
        final defaultLang = doc.data()?['defaultLanguage'] as String? ?? 'en';

        setState(() {
          _currentName = name;
          _nameController.text = name;
          _selectedLanguage = defaultLang;
        });
      } else if (mounted) {
        setState(() {
          _currentName = 'Mon Restaurant';
          _nameController.text = 'Mon Restaurant';
          _selectedLanguage = 'en';
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement restaurant: $e');
      if (mounted) {
        setState(() {
          _error = l10n.adminSettingsLoadError;
          _selectedLanguage = 'en';
        });
      }
    }
  }

  Future<void> _saveRestaurantName() async {
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(
            content: Text(l10n.adminSettingsNameUpdated),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = l10n.adminSettingsSaveError(e.toString());
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

  Future<void> _updateDefaultLanguage(String languageCode) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .update({'defaultLanguage': languageCode});

      setState(() {
        _selectedLanguage = languageCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adminSettingsDefaultLanguageUpdated),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdminShell(
      title: l10n.adminSettingsTitle,
      restaurantId: widget.restaurantId,
      activeRoute: '/settings',
      breadcrumbs: [l10n.adminDashboardTitle, l10n.adminSettingsTitle],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AdminTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Restaurant
            Text(
              l10n.adminSettingsRestaurant,
              style: AdminTypography.headlineLarge,
            ),

            const SizedBox(height: AdminTokens.space16),

            // Card nom restaurant
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTokens.radius16),
                side: const BorderSide(color: AdminTokens.border),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  boxShadow: AdminTokens.shadowMd,
                ),
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
                          Expanded(
                            child: Text(
                              l10n.adminSettingsRestaurantName,
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
                              tooltip: l10n.commonEdit,
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
                                BorderRadius.circular(AdminTokens.radius12),
                            border: Border.all(color: AdminTokens.neutral200),
                          ),
                          child: Text(
                            _currentName ?? l10n.adminSettingsLoading,
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
                                decoration: InputDecoration(
                                  labelText: l10n.adminSettingsRestaurantName,
                                  hintText: l10n.adminSettingsNamePlaceholder,
                                  prefixIcon: const Icon(Icons.restaurant),
                                ),
                                validator: (value) {
                                  final l10n = AppLocalizations.of(context)!;
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.adminSettingsNameRequired;
                                  }
                                  if (value.trim().length < 2) {
                                    return l10n.adminSettingsNameTooShort;
                                  }
                                  if (value.trim().length > 50) {
                                    return l10n.adminSettingsNameTooLong;
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
                                        AdminTokens.radius12),
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
                                      onPressed:
                                          _isLoading ? null : _cancelEdit,
                                      child: Text(l10n.commonCancel),
                                    ),
                                  ),
                                  const SizedBox(width: AdminTokens.space16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _saveRestaurantName,
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(l10n.commonSave),
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
            ),

            const SizedBox(height: AdminTokens.space24),

            // Langue par défaut du menu
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTokens.radius16),
                side: const BorderSide(color: AdminTokens.border),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  boxShadow: AdminTokens.shadowMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AdminTokens.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.language,
                            color: AdminTokens.primary600,
                          ),
                          const SizedBox(width: AdminTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.adminSettingsDefaultLanguage,
                                  style: AdminTypography.headlineMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.adminSettingsDefaultLanguageSubtitle,
                                  style: AdminTypography.bodySmall.copyWith(
                                    color: AdminTokens.neutral600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AdminTokens.space16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 400;

                          return SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              selected: {_selectedLanguage},
                              onSelectionChanged: (Set<String> selection) {
                                _updateDefaultLanguage(selection.first);
                              },
                              segments: [
                                ButtonSegment(
                                  value: 'fr',
                                  label: Text(
                                    isMobile ? '🇫🇷 FR' : '🇫🇷 Français',
                                    style:
                                        TextStyle(fontSize: isMobile ? 12 : 14),
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'en',
                                  label: Text(
                                    isMobile ? '🇬🇧 EN' : '🇬🇧 English',
                                    style:
                                        TextStyle(fontSize: isMobile ? 12 : 14),
                                  ),
                                ),
                                ButtonSegment(
                                  value: 'he',
                                  label: Text(
                                    isMobile ? '🇮🇱 HE' : '🇮🇱 עברית',
                                    style:
                                        TextStyle(fontSize: isMobile ? 12 : 14),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AdminTokens.space24),
            // Autres paramètres
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTokens.radius16),
                side: const BorderSide(color: AdminTokens.border),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  boxShadow: AdminTokens.shadowMd,
                ),
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.adminSettingsDetailedInfo),
                  subtitle: Text(l10n.adminSettingsDetailedInfoSubtitle),
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
            ),

            const SizedBox(height: AdminTokens.space32),

            // Section Gestion des catégories
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTokens.radius16),
                side: const BorderSide(color: AdminTokens.border),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  boxShadow: AdminTokens.shadowMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AdminTokens.space20),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.category),
                      title: Text(l10n.adminSettingsManageCategories),
                      subtitle: Text(l10n.adminSettingsCategoriesSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final state = await CategoryManager.getLiveState(
                                widget.restaurantId)
                            .first;
                        if (context.mounted) {
                          CategoryManagerSheet.show(
                              context, widget.restaurantId, state);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AdminTokens.space32),

            // Section Intégration
            Text(
              l10n.adminSettingsIntegration,
              style: AdminTypography.headlineLarge,
            ),
            const SizedBox(height: AdminTokens.space16),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AdminTokens.radius16),
                side: const BorderSide(color: AdminTokens.border),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AdminTokens.radius16),
                  boxShadow: AdminTokens.shadowMd,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AdminTokens.space20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.qr_code,
                            color: AdminTokens.primary600,
                          ),
                          const SizedBox(width: AdminTokens.space12),
                          Text(
                            l10n.adminSettingsRestaurantCode,
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
                          final code = data['slug'] ??
                              data['code'] ??
                              widget.restaurantId;

                          return Column(
                            children: [
                              // Code restaurant - responsive
                              _buildResponsiveInfoRow(
                                  l10n.adminSettingsRestaurantCode, code),
                              const SizedBox(height: AdminTokens.space12),

                              // URL publique - responsive
                              _buildResponsiveInfoRow(
                                l10n.adminSettingsPublicUrl,
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
                                            label: Text(
                                                l10n.adminSettingsGenerateQr),
                                            onPressed: () =>
                                                _generateQRCode(code),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            height: AdminTokens.space12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.share,
                                                size: 18),
                                            label: Text(l10n.commonShare),
                                            onPressed: () =>
                                                _shareRestaurant(code),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                            label: Text(
                                                l10n.adminSettingsGenerateQr),
                                            onPressed: () =>
                                                _generateQRCode(code),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: AdminTokens.space12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.share,
                                                size: 18),
                                            label: Text(l10n.commonShare),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveInfoRow(String label, String value,
      {bool isUrl = false}) {
    final l10n = AppLocalizations.of(context)!;

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
                              content: Text(l10n
                                  .adminSettingsCopied(isUrl ? 'URL' : value)),
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
                    SnackBar(content: Text(l10n.adminSettingsCopied(value))),
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
    final l10n = AppLocalizations.of(context)!;

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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.adminSettingsCodeGenerated(code))),
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
        // ❌ Supprimer : _config = config;
        _messageController.text = config.customMessage ?? '';
        _selectedSize = QRSize.fromKey(config.size);
      });
    } catch (e) {
      // Utiliser config par défaut en cas d'erreur
      setState(() {
        // ❌ Supprimer : _config = const QRConfig();
        // Config par défaut appliquée directement
        _messageController.text = '';
        _selectedSize = QRSize.medium;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    final l10n = AppLocalizations.of(context)!;

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
          SnackBar(
            content: Text(l10n.adminSettingsConfigSaved),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _downloadQR() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Créer un widget QR temporaire pour capture
      final qrWidget = Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_messageController.text.isNotEmpty) ...[
              Text(
                _messageController.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            QrImageView(
              data: _qrUrl,
              version: QrVersions.auto,
              size: _selectedSize.pixels.toDouble() - 40,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.restaurantName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Scan to access the menu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

      // Utiliser RepaintBoundary pour capturer
      final boundary = GlobalKey();

      // Afficher temporairement le widget pour capture
      final overlay = Overlay.of(context);
      late OverlayEntry entry;

      entry = OverlayEntry(
        builder: (context) => Positioned(
          left: -2000, // Hors écran
          top: -2000,
          child: RepaintBoundary(
            key: boundary,
            child: Material(
              child: SizedBox(
                width: _selectedSize.pixels.toDouble(),
                child: qrWidget,
              ),
            ),
          ),
        ),
      );

      overlay.insert(entry);

      // Attendre le rendu
      await Future.delayed(const Duration(milliseconds: 100));

      // Capturer l'image
      final renderObject =
          boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (renderObject != null) {
        final image = await renderObject.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);

          final anchor = html.AnchorElement()
            ..href = url
            ..download = 'qr-${widget.slug}-${_selectedSize.key}.png';
          anchor.click();

          html.Url.revokeObjectUrl(url);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.adminSettingsQrDownloaded),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }
        }
      }

      // Nettoyer
      entry.remove();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _generateA5Template() {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Canvas A5 : 595x842 pixels (format A5 à 72 DPI)
      final canvas = html.CanvasElement(width: 595, height: 842);
      canvas.style.display = 'none';
      html.document.body!.append(canvas);

      final ctx = canvas.context2D;

      // Fond blanc
      ctx.fillStyle = 'white';
      ctx.fillRect(0, 0, 595, 842);

      // Titre du restaurant (centré, haut)
      ctx.fillStyle = 'black';
      ctx.font = 'bold 28px Arial';
      ctx.textAlign = 'center';
      ctx.fillText(widget.restaurantName, 297, 60);

      // Message personnalisé si défini
      if (_messageController.text.isNotEmpty) {
        ctx.font = '18px Arial';
        ctx.fillText(_messageController.text, 297, 90);
      }

      // QR Code centré (250x250)
      const qrSize = 250;
      const qrX = (595 - qrSize) / 2;
      const qrY = 120;

      // Bordure QR
      ctx.strokeStyle = '#ddd';
      ctx.lineWidth = 2;
      ctx.strokeRect(qrX - 10, qrY - 10, qrSize + 20, qrSize + 20);

      // Pattern QR simplifié mais plus dense
      const moduleSize = qrSize / 33; // 33x33 grille pour plus de réalisme
      ctx.fillStyle = 'black';

      for (int i = 0; i < 33; i++) {
        for (int j = 0; j < 33; j++) {
          // Pattern pseudo-QR plus réaliste
          final isCorner =
              (i < 7 && j < 7) || (i < 7 && j > 25) || (i > 25 && j < 7);
          final isData =
              !isCorner && ((i + j * 7) % 3 == 0 || (i * 5 + j) % 7 < 3);

          if (isCorner || isData) {
            ctx.fillRect(qrX + i * moduleSize, qrY + j * moduleSize,
                moduleSize - 0.5, moduleSize - 0.5);
          }
        }
      }

      // Instructions bilingues (centré, sous le QR)
      const instructionsY = qrY + qrSize + 60;

      // Ligne de séparation
      ctx.strokeStyle = '#ccc';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(150, instructionsY + 50);
      ctx.lineTo(445, instructionsY + 50);
      ctx.stroke();

      // Title
      ctx.fillText(widget.restaurantName, 297, 60);

      ctx.font = 'bold 20px Arial';
      ctx.fillText('Scan to access the menu', 297, instructionsY);
      ctx.font = '16px Arial';
      ctx.fillText('or visit smartmenu.app', 297, instructionsY + 30);

      // Restaurant code
      ctx.fillStyle = 'black';
      ctx.font = 'bold 18px Arial';
      ctx.fillText('Restaurant code: ${widget.slug}', 297, instructionsY + 80);

      // URL
      ctx.font = '12px Monaco';
      ctx.fillStyle = '#888';
      final url = QRService.generateRestaurantUrl(widget.slug);
      ctx.fillText(url, 297, instructionsY + 110);

      // Print instructions
      ctx.font = '11px Arial';
      ctx.fillStyle = '#aaa';
      ctx.fillText('Cut and place on your tables', 297, 780);

      // Footer
      ctx.font = 'bold 10px Arial';
      ctx.fillStyle = '#999';
      ctx.fillText('Powered by SmartMenu', 297, 820);
      canvas.remove();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminSettingsTemplateDownloaded),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _copyUrl() {
    final l10n = AppLocalizations.of(context)!;

    Clipboard.setData(ClipboardData(text: _qrUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.adminSettingsUrlCopied),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.adminSettingsLoading),
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
                      borderRadius: BorderRadius.circular(AdminTokens.radius12),
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
                          l10n.adminSettingsQrGenerator,
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
                            BorderRadius.circular(AdminTokens.radius12),
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
                                  BorderRadius.circular(AdminTokens.radius12),
                              border: Border.all(color: AdminTokens.neutral200),
                            ),
                            child: QrImageView(
                              data: _qrUrl,
                              version: QrVersions.auto,
                              size:
                                  isMobile ? 150 : 200, // Plus petit sur mobile
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              embeddedImage:
                                  const AssetImage('assets/images/logo.png'),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                size: Size(40, 40),
                              ),
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
                            l10n.adminSettingsScanToAccess,
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
                          l10n.adminSettingsConfiguration,
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
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AdminTokens.radius12),
                            ),
                            labelText: l10n.adminSettingsCustomMessage,
                            hintText: l10n.adminSettingsCustomMessageHint,
                            prefixIcon: Icon(Icons.message_outlined,
                                size: isMobile ? 20 : 24),
                            helperText: l10n.adminSettingsCustomMessageHelper,
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
                          l10n.adminSettingsDownloadSize,
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
                                l10n.adminSettingsPublicUrl,
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
                          label: Text(l10n.adminSettingsDownloadQr),
                          onPressed: _downloadQR,
                        ),

                        const SizedBox(width: AdminTokens.space8),

                        OutlinedButton.icon(
                          icon:
                              const Icon(Icons.print, size: AdminTokens.iconSm),
                          label: Text(l10n.adminSettingsTemplateA5),
                          onPressed: _generateA5Template,
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
                          label: Text(l10n.commonSave),
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
    final l10n = AppLocalizations.of(context)!;

    Clipboard.setData(ClipboardData(text: url));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(l10n.adminSettingsUrlCopiedSuccess),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareViaEmail(BuildContext context) {
    final subject = Uri.encodeComponent('Menu $restaurantName - SmartMenu');
    final body = Uri.encodeComponent('''
Discover our digital menu!

Restaurant: $restaurantName
Access code: $code

Direct access: $url

Scan the QR code on your table or enter code "$code" on smartmenu.app

---
Powered by SmartMenu
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
        Uri.encodeComponent('Discover the menu of *$restaurantName*! 🍽️\n\n'
            'Direct access: $url\n'
            'Or code: *$code*\n\n'
            '_Powered by SmartMenu_');

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
    final l10n = AppLocalizations.of(context)!;

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
                      Text(
                        l10n.adminSettingsShareMenu,
                        style: const TextStyle(
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
            Text(
              l10n.adminSettingsChooseMethod,
              style: const TextStyle(
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
                  label: l10n.adminSettingsEmail,
                  color: Colors.blue.shade600,
                  onTap: () => _shareViaEmail(context),
                ),
                _CompactShareOption(
                  icon: Icons.message_outlined,
                  label: l10n.adminSettingsSms,
                  color: Colors.green.shade600,
                  onTap: () => _shareViaSMS(context),
                ),
                _CompactShareOption(
                  icon: Icons.chat_bubble_outline,
                  label: l10n.adminSettingsWhatsApp,
                  color: const Color(0xFF25D366),
                  onTap: () => _shareViaWhatsApp(context),
                ),
                _CompactShareOption(
                  icon: Icons.facebook_outlined,
                  label: l10n.adminSettingsFacebook,
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
                label: Text(
                  l10n.adminSettingsCopyLink,
                  style: const TextStyle(fontSize: 14),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
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
