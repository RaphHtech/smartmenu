import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/core/constants/colors.dart';
import 'package:smartmenu_app/l10n/app_localizations.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class AdminBrandingScreen extends StatefulWidget {
  final String restaurantId;

  const AdminBrandingScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  State<AdminBrandingScreen> createState() => _AdminBrandingScreenState();
}

class _AdminBrandingScreenState extends State<AdminBrandingScreen> {
  bool _isLoading = false;
  String? _error;
  String? _logoUrl;
  final _brandColorController = TextEditingController();
  String _restaurantName = '';

  Color _generateStableColor(String name) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];

    int sum = 0;
    for (int i = 0; i < name.length; i++) {
      sum += name.codeUnitAt(i);
    }
    return colors[sum % colors.length];
  }

  Future<void> _uploadLogo() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final input = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..click();

      input.onChange.listen((e) async {
        final file = input.files?.first;
        if (file != null) {
          if (file.size > 2 * 1024 * 1024) {
            setState(() => _error = l10n.adminBrandingErrorSize);
            return;
          }

          if (!file.type.startsWith('image/')) {
            setState(() => _error = l10n.adminBrandingErrorFormat);
            return;
          }

          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) async {
            final bytes = reader.result as Uint8List;
            await _uploadToFirebase(bytes, file.name);
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.adminBrandingErrorSelection(e.toString()));
    }
  }

  Future<void> _uploadToFirebase(Uint8List bytes, String fileName) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_logoUrl != null) {
        try {
          await FirebaseStorage.instance
              .refFromURL(_logoUrl!.split('?')[0])
              .delete();
        } catch (e) {
          // Ignore if old file doesn't exist
        }
      }

      debugPrint('DEBUG - Restaurant ID: ${widget.restaurantId}');
      debugPrint('DEBUG - User UID: ${FirebaseAuth.instance.currentUser?.uid}');

      final version = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref()
          .child('restaurants')
          .child(widget.restaurantId)
          .child('branding')
          .child('logo_$version.png');

      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/png',
          cacheControl: 'public, max-age=31536000, immutable',
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .update({
        'logoUrl': downloadUrl,
        'logoVersion': version,
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() {
        final separator = downloadUrl.contains('?') ? '&' : '?';
        _logoUrl = '$downloadUrl${separator}v=$version';
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminBrandingSuccessUpload),
            backgroundColor: AdminTokens.success500,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.commonError(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('=== BRANDING DEBUG ===');
    debugPrint('Restaurant ID: ${widget.restaurantId}');
    debugPrint('User UID: ${FirebaseAuth.instance.currentUser?.uid}');
    debugPrint('===================');
    _loadBrandingData();
  }

  @override
  void dispose() {
    _brandColorController.dispose();
    super.dispose();
  }

  Future<void> _loadBrandingData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          final baseUrl = data['logoUrl'] as String?;
          final version = data['logoVersion'] as int?;
          if (baseUrl != null && version != null) {
            final separator = baseUrl.contains('?') ? '&' : '?';
            _logoUrl = '$baseUrl${separator}v=$version';
          } else {
            _logoUrl = baseUrl;
          }
          _restaurantName = data['name'] as String? ??
              AppLocalizations.of(context)!.adminBrandingRestaurantDefault;
          _brandColorController.text = data['brandColor'] as String? ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.adminBrandingErrorLoad(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdminShell(
      title: l10n.adminBrandingTitle,
      restaurantId: widget.restaurantId,
      activeRoute: '/branding',
      breadcrumbs: [l10n.adminDashboardTitle, l10n.adminBrandingTitle],
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AdminTokens.primary600),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AdminTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.adminBrandingIdentity,
                    style: AdminTypography.headlineLarge,
                  ),
                  const SizedBox(height: AdminTokens.space16),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(AdminTokens.space12),
                      decoration: BoxDecoration(
                        color: AdminTokens.error50,
                        borderRadius:
                            BorderRadius.circular(AdminTokens.radius8),
                      ),
                      child: Text(
                        _error!,
                        style: AdminTypography.bodySmall.copyWith(
                          color: AdminTokens.error500,
                        ),
                      ),
                    ),
                  const SizedBox(height: AdminTokens.space24),
                  _buildLogoSection(),
                  const SizedBox(height: AdminTokens.space32),
                  _buildPreviewSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildLogoSection() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: AdminTokens.primary600),
                const SizedBox(width: AdminTokens.space12),
                Text(
                  l10n.adminBrandingLogoSection,
                  style: AdminTypography.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: AdminTokens.space16),
            Text(
              l10n.adminBrandingLogoFormat,
              style: AdminTypography.bodySmall.copyWith(
                color: AdminTokens.neutral600,
              ),
            ),
            const SizedBox(height: AdminTokens.space24),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AdminTokens.neutral300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(AdminTokens.radius12),
                color: AdminTokens.neutral50,
              ),
              child:
                  _logoUrl != null ? _buildLogoPreview() : _buildUploadZone(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPreview() {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AdminTokens.radius8),
            child: Image.network(
              _logoUrl!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: AdminTokens.neutral200,
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _uploadLogo,
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AdminTokens.primary600,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _removeLogo,
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AdminTokens.error500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: _uploadLogo,
      borderRadius: BorderRadius.circular(AdminTokens.radius12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: AdminTokens.primary600,
          ),
          const SizedBox(height: AdminTokens.space16),
          Text(
            l10n.adminBrandingUploadClick,
            style: AdminTypography.bodyLarge,
          ),
          const SizedBox(height: AdminTokens.space8),
          Text(
            l10n.adminBrandingLogoFormats,
            style: AdminTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AdminTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.adminBrandingPreviewTitle,
              style: AdminTypography.headlineMedium,
            ),
            const SizedBox(height: AdminTokens.space16),
            Text(
              l10n.adminBrandingPreviewDescription,
              style: AdminTypography.bodySmall.copyWith(
                color: AdminTokens.neutral600,
              ),
            ),
            const SizedBox(height: AdminTokens.space24),
            _buildHeroPreview(),
            const SizedBox(height: AdminTokens.space20),
            _buildStickyPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPreview() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminBrandingPreviewHero,
          style: AdminTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AdminTokens.space12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary, // Bleu ardoise uni
            borderRadius: BorderRadius.circular(AdminTokens.radius12),
            border: Border.all(color: AdminTokens.neutral200),
          ),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoPreviewWidget(36),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _restaurantName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStickyPreview() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.adminBrandingPreviewSticky,
          style: AdminTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AdminTokens.space12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondary, // Bleu ardoise uni
            borderRadius: BorderRadius.circular(AdminTokens.radius12),
            border: Border.all(color: AdminTokens.neutral200),
          ),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoPreviewWidget(28),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _restaurantName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                            ),
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoPreviewWidget(double size) {
    if (_logoUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            _logoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackPreview(size),
          ),
        ),
      );
    }

    return _buildFallbackPreview(size);
  }

  Widget _buildFallbackPreview(double size) {
    String initials = _restaurantName.trim().isEmpty
        ? '🍽'
        : _restaurantName
            .trim()
            .split(RegExp(r'\s+'))
            .map((w) => w[0])
            .take(2)
            .join()
            .toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _generateStableColor(_restaurantName),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }

  Future<void> _removeLogo() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .update({
        'logoUrl': FieldValue.delete(),
        'logoVersion': FieldValue.delete(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      setState(() => _logoUrl = null);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.adminBrandingSuccessDelete),
            backgroundColor: AdminTokens.success500,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.commonError(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
