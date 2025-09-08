import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class AdminRestaurantInfoScreen extends StatefulWidget {
  final String restaurantId; // rid

  const AdminRestaurantInfoScreen({
    super.key,
    required this.restaurantId,
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
      _promoEnabled = (data['promo_enabled'] as bool?) ?? true; // <-- NEW

      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Impossible de charger les infos : $e';
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
        // on fusionne uniquement ces 2 champs
        'tagline': _taglineController.text.trim(),
        'promo_text': _promoController.text.trim(),
        'promo_enabled': _promoEnabled,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Infos enregistrées ✅')),
      );
      Navigator.pop(context); // retour dashboard
    } catch (e) {
      setState(() => _error = 'Erreur enregistrement : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infos du restaurant'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Texte sous le titre (tagline)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _taglineController,
                        decoration: const InputDecoration(
                          hintText: 'Ex. La vraie pizza italienne à Tel Aviv',
                          prefixIcon: Icon(Icons.short_text),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 120,
                        validator: (v) => (v ?? '').length > 120
                            ? '120 caractères max'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('Afficher le bandeau promo'),
                        subtitle: const Text(
                            'Décoche pour masquer la bannière sur le site'),
                        value: _promoEnabled,
                        onChanged: (v) => setState(() => _promoEnabled = v),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Bandeau promotionnel (optionnel)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _promoController,
                        decoration: const InputDecoration(
                          hintText:
                              'Ex. ✨ 2ème pizza -50% • Livraison offerte dès 80₪ ✨',
                          prefixIcon: Icon(Icons.campaign),
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 140,
                        maxLines: 2,
                        validator: (v) => (v ?? '').length > 140
                            ? '140 caractères max'
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
                              : const Text('Enregistrer'),
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
