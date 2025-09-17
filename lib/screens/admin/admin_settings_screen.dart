// lib/screens/admin/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/widgets/admin/categories_settings_widget.dart';
import '../../widgets/ui/admin_shell.dart';
import '../../core/design/admin_tokens.dart';
import '../../core/design/admin_typography.dart';
import '../../widgets/ui/admin_themed.dart';
import 'admin_restaurant_info_screen.dart';
// import 'package:firebase_core/firebase_core.dart';

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
                child: CategoriesSettings(restaurantId: widget.restaurantId),
              ),
            ),

            const SizedBox(height: AdminTokens.space32),
          ],
        ),
      ),
    );
  }
}
