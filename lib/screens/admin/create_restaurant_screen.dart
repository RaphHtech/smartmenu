import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartmenu_app/screens/admin/admin_dashboard_overview_screen.dart';
import '../../services/slug_service.dart';
import '../../core/design/admin_tokens.dart';

class CreateRestaurantScreen extends StatefulWidget {
  const CreateRestaurantScreen({super.key});

  @override
  State<CreateRestaurantScreen> createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends State<CreateRestaurantScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _taglineController =
      TextEditingController(); // description courte (sous-titre)
  final _promoController = TextEditingController(); // bandeau promo (optionnel)

  String _selectedCurrency = 'ILS';
  bool _isLoading = false;
  String? _errorMessage;
  String _symbol(String c) {
    // map code -> symbole
    switch (c) {
      case 'ILS':
        return '₪';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return c;
    }
  }

  final List<String> _currencies = ['ILS', 'EUR', 'USD', 'MAD', 'CAD', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _taglineController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _createRestaurant() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Utilisateur non connecté');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final restaurantRef =
          FirebaseFirestore.instance.collection('restaurants').doc();
      final rid = restaurantRef.id;

      // 1) Infos du resto dans "restaurants/{rid}/info/details"

      final restaurantName = _nameController.text.trim();
      final desired = SlugService.normalize(restaurantName);
      final slug = await SlugService.claim(desired, rid);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(
            restaurantRef,
            {
              'created_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
        tx.set(
          restaurantRef.collection('info').doc('details'),
          {
            'name': restaurantName,
            'slug': slug,
            'address': _addressController.text.trim(),
            'currency': _selectedCurrency,
            'active': true,
            'owner_uid': user.uid,
            'created_at': FieldValue.serverTimestamp(),
            'tagline': _taglineController.text.trim(),
            'promo_text': _promoController.text.trim(),
            'promo_enabled': true,
            'categoriesOrder': <String>[],
            'categoriesHidden': <String>[],
          },
        );
        // 2) Membres : l’utilisateur devient owner
        tx.set(
          restaurantRef.collection('members').doc(user.uid),
          {
            'role': 'owner',
            'invited_at': FieldValue.serverTimestamp(),
          },
        );

        // 3) Mapping user -> restaurant
        tx.set(
          FirebaseFirestore.instance.collection('users').doc(user.uid),
          {
            'primary_restaurant_id': rid,
            'role': 'owner',
            'created_at': FieldValue.serverTimestamp(),
          },
        );
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => AdminDashboardOverviewScreen(restaurantId: rid)),
        (route) => false,
      );
    } catch (e) {
      setState(
          () => _errorMessage = 'Erreur lors de la création du restaurant: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer votre restaurant'),
        backgroundColor: AdminTokens.neutral50,
        foregroundColor: AdminTokens.neutral900,
        elevation: 0,
      ),
      body: Container(
        color: AdminTokens.neutral50,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.store,
                        size: 64, color: AdminTokens.primary600),
                    const SizedBox(height: 24),
                    const Text('Bienvenue !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Configurons votre restaurant',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du restaurant *',
                        helperText: 'Exemple: Chez Milano, Le Petit Bistrot...',
                        prefixIcon: const Icon(Icons.restaurant),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide:
                              const BorderSide(color: AdminTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.primary600, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.error500, width: 1),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Le nom du restaurant est obligatoire';
                        }
                        if (v.trim().length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Adresse *',
                        helperText: 'Adresse complète du restaurant',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide:
                              const BorderSide(color: AdminTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.primary600, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.error500, width: 1),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'L\'adresse est obligatoire'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      items: _currencies
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(
                          () => _selectedCurrency = v ?? _selectedCurrency),
                      decoration: InputDecoration(
                        labelText: 'Devise',
                        prefixText: '${_symbol(_selectedCurrency)} ',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide:
                              const BorderSide(color: AdminTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.primary600, width: 2),
                        ),
                      ),
                    ),
                    // --- Description courte (tagline) ---
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taglineController,
                      decoration: InputDecoration(
                        labelText: 'Description courte (tagline)',
                        hintText: 'Ex. La vraie pizza italienne à Tel Aviv',
                        prefixIcon: const Icon(Icons.short_text),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide:
                              const BorderSide(color: AdminTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.primary600, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.error500, width: 1),
                        ),
                      ),
                      maxLength: 120, // optionnel
                      maxLines: 1,
                    ),

                    // --- Texte promo (bandeau) ---
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _promoController,
                      decoration: InputDecoration(
                        labelText: 'Texte promo (bandeau)',
                        hintText:
                            'Ex. ✨ 2ème pizza à -50% • Livraison offerte dès 80₪ ✨',
                        prefixIcon: const Icon(Icons.campaign),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide:
                              const BorderSide(color: AdminTokens.neutral300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.primary600, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AdminTokens.radius8),
                          borderSide: const BorderSide(
                              color: AdminTokens.error500, width: 1),
                        ),
                      ),
                      maxLength: 140, // optionnel
                      maxLines: 2,
                    ),

                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red.shade700)),
                      ),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createRestaurant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTokens.primary600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AdminTokens.radius8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)),
                              )
                            : const Text('Créer mon restaurant'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
