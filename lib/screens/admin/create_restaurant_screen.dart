import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/colors.dart';
import 'admin_dashboard_screen.dart';

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

      await FirebaseFirestore.instance.runTransaction((tx) async {
        // 1) Infos du resto dans "restaurants/{rid}/info/details"
        tx.set(
          restaurantRef.collection('info').doc('details'),
          {
            'name': _nameController.text.trim(),
            'address': _addressController.text.trim(),
            'currency': _selectedCurrency,
            'active': true,
            'owner_uid': user.uid,
            'created_at': FieldValue.serverTimestamp(),
            'tagline': _taglineController.text.trim(),
            'promo_text': _promoController.text.trim(),
            'promo_enabled': true,
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(restaurantId: rid)),
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
          backgroundColor: AppColors.primary),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.store, size: 64, color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text('Bienvenue !',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Configurons votre restaurant',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du restaurant *',
                      helperText: 'Exemple: Chez Milano, Le Petit Bistrot...',
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Le nom du restaurant est obligatoire';
                      if (v.trim().length < 2)
                        return 'Le nom doit contenir au moins 2 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Adresse *',
                      helperText: 'Adresse complète du restaurant',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'L\'adresse est obligatoire'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    items: _currencies
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(
                        () => _selectedCurrency = v ?? _selectedCurrency),
                    decoration: InputDecoration(
                      labelText: 'Devise',
                      prefixText:
                          '${_symbol(_selectedCurrency)} ', // ← symbole lié à la sélection
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  // --- Description courte (tagline) ---
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _taglineController,
                    decoration: const InputDecoration(
                      labelText: 'Description courte (tagline)',
                      hintText: 'Ex. La vraie pizza italienne à Tel Aviv',
                      prefixIcon: Icon(Icons.short_text),
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 120, // optionnel
                    maxLines: 1,
                  ),

                  // --- Texte promo (bandeau) ---
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _promoController,
                    decoration: const InputDecoration(
                      labelText: 'Texte promo (bandeau)',
                      hintText:
                          'Ex. ✨ 2ème pizza à -50% • Livraison offerte dès 80₪ ✨',
                      prefixIcon: Icon(Icons.campaign),
                      border: OutlineInputBorder(),
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
    );
  }
}
