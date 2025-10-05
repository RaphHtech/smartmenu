import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartmenu_app/core/design/admin_typography.dart';
import 'package:smartmenu_app/l10n/app_localizations.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';

class AdminRestaurantInfoScreen extends StatefulWidget {
  final String restaurantId;
  final bool showBack;

  const AdminRestaurantInfoScreen({
    super.key,
    required this.restaurantId,
    this.showBack = true,
  });

  @override
  State<AdminRestaurantInfoScreen> createState() =>
      _AdminRestaurantInfoScreenState();
}

class _AdminRestaurantInfoScreenState extends State<AdminRestaurantInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taglineController = TextEditingController();
  final _promoController = TextEditingController();
  bool _promoEnabled = true;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  @override
  void dispose() {
    _taglineController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentValues() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .get();

      final data = doc.data() ?? {};
      _taglineController.text = (data['tagline'] ?? '').toString();
      _promoController.text = (data['promo_text'] ?? '').toString();
      _promoEnabled = (data['promo_enabled'] as bool?) ?? true;

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _loading = false;
        _error = l10n.adminRestaurantInfoLoadError(e.toString());
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
          .collection('info')
          .doc('details')
          .set({
        'tagline': _taglineController.text.trim(),
        'promo_text': _promoController.text.trim(),
        'promo_enabled': _promoEnabled,
      }, SetOptions(merge: true));

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminRestaurantInfoSaveSuccess)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.adminRestaurantInfoSaveError(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdminShell(
      title: l10n.adminRestaurantInfoTitle,
      restaurantId: widget.restaurantId,
      activeRoute: '/info',
      breadcrumbs: [l10n.adminDashboardTitle, l10n.adminRestaurantInfoTitle],
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.adminRestaurantInfoTaglineSection,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _taglineController,
                        decoration: InputDecoration(
                          hintText: l10n.adminRestaurantInfoTaglinePlaceholder,
                          prefixIcon: const Icon(Icons.short_text),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AdminTokens.radius12),
                          ),
                        ),
                        maxLength: 120,
                        validator: (v) => (v ?? '').length > 120
                            ? l10n.adminRestaurantInfoTaglineMaxLength
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius12),
                          boxShadow: AdminTokens.shadowMd,
                          border: Border.all(color: AdminTokens.border),
                        ),
                        child: SwitchListTile(
                          title: Text(l10n.adminRestaurantInfoPromoToggleTitle),
                          subtitle:
                              Text(l10n.adminRestaurantInfoPromoToggleSubtitle),
                          value: _promoEnabled,
                          onChanged: (v) => setState(() => _promoEnabled = v),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.adminRestaurantInfoPromoSection,
                        style: AdminTypography.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: l10n.adminRestaurantInfoPromoPlaceholder,
                          prefixIcon: const Icon(Icons.campaign),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AdminTokens.radius12),
                          ),
                        ),
                        maxLength: 140,
                        maxLines: 2,
                        validator: (v) => (v ?? '').length > 140
                            ? l10n.adminRestaurantInfoPromoMaxLength
                            : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AdminTokens.radius12),
                            ),
                          ),
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(l10n.commonSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
