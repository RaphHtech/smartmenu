import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

// Structure de base : Scaffold → SafeArea → Container (avec gradient) → Column

// decoration: const BoxDecoration(gradient: AppColors.primaryGradient, // ← LES couleurs parfaites !),

// 🔍 Chaque ligne expliquée :
// SafeArea → Évite l'encoche du téléphone
// double.infinity → Prend toute la largeur
// Expanded → Prend tout l'espace restant
// mainAxisSize.min → Bouton juste la taille nécessaire

class SimpleMenuScreen extends StatelessWidget {
  const SimpleMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) Fond diagonal (135°)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.bgGradientWarm,
            ),
          ),
        ),

        // 2) Voile global léger
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.pageOverlay),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ===== HEADER (en dur) =====
                ClipRect(
                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(sigmaX: 10, sigmaY: 10), // blur 10px
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppColors.headerOverlay, // rgba(0,0,0,0.20)
                        border: Border(
                          bottom: BorderSide(
                              color: AppColors.headerDivider, width: 1), // 10%
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Gauche : emoji + “SmartMenu”
                          const Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                // évite tout dépassement côté gauche
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🍽️', style: TextStyle(fontSize: 16)),
                                    SizedBox(width: 8),
                                    Text(
                                      'SmartMenu',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ---- Colonne centre : 2 lignes, centrées ----
                          const Expanded(
                            flex: 2,
                            child: Center(
                              child: _GradientText(
                                'PIZZA\nPOWER',
                                gradient:
                                    AppColors.titleGradient, // blanc → jaune
                                style: TextStyle(
                                  fontSize: 24, // 22–24 selon ton goût
                                  fontWeight: FontWeight.w800,
                                  height: 1.05, // interligne serré
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),

                          // Droite : bouton pilule “Serveur”
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                // ← rétrécit le bouton si l’espace manque
                                fit: BoxFit.scaleDown,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('📞 Appel envoyé au serveur'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.phone_outlined,
                                      size: 18),
                                  label: const Text('Serveur'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.primary,
                                    shape: const StadiumBorder(), // pilule
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    minimumSize:
                                        const Size(0, 44), // min-height 44px
                                    textStyle: const TextStyle(
                                        fontWeight: FontWeight.w700),
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

                // ===== SECTION HÉRO (2e “rectangle”) =====
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: const BoxDecoration(color: AppColors.heroOverlay),
                  child:
                      // Ligne du logo + grand titre (sur 1 ligne)
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ligne du logo + grand titre (sur 1 ligne)
                      FittedBox(
                        // ← évite tout dépassement horizontal
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo "triangle" doré
                            ShaderMask(
                              shaderCallback: (r) => const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFF5F5F5),
                                  Color(0xFFE3D7A3)
                                ], // doré clair
                              ).createShader(r),
                              child: Transform.scale(
                                scaleX: -1, // pointe vers la gauche
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 64, // ajuste à 68–72 si tu veux
                                  color: Colors
                                      .white, // remplacé par le gradient via ShaderMask
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Titre HÉRO en dégradé — 1 LIGNE
                            const _GradientText(
                              'PIZZA POWER',
                              gradient: AppColors
                                  .titleGradient, // tu peux passer à un gradient plus doré si tu veux
                              style: TextStyle(
                                fontSize: 56, // ≈ 3.5rem
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    // léger relief comme sur la maquette
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 📝 DESCRIPTION
                      const Text(
                        'La vraie pizza italienne à Tel Aviv',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20, // ≈ 1.3rem
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== SECTION PROMO (glassmorphism) =====
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '✨ 2ème Pizza à -50% • Livraison gratuite dès 80₪ ✨',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ===== NAVIGATION CATÉGORIES =====
                Container(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 20, right: 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CategoryPill(
                          label: '🍕 Pizzas',
                          isActive: true,
                          onTap: () => print('Pizzas sélectionnées'),
                        ),
                        const SizedBox(width: 12),
                        _CategoryPill(
                          label: '🥗 Entrées',
                          isActive: false,
                          onTap: () => print('Entrées sélectionnées'),
                        ),
                        const SizedBox(width: 12),
                        _CategoryPill(
                          label: '🍝 Pâtes',
                          isActive: false,
                          onTap: () => print('Pâtes sélectionnées'),
                        ),
                        const SizedBox(width: 12),
                        _CategoryPill(
                          label: '🍰 Desserts',
                          isActive: false,
                          onTap: () => print('Desserts sélectionnés'),
                        ),
                        const SizedBox(width: 12),
                        _CategoryPill(
                          label: '🍹 Boissons',
                          isActive: false,
                          onTap: () => print('Boissons sélectionnées'),
                        ),
                        const SizedBox(
                            width: 20), // ← AJOUTE l'espacement final à la fin
                      ],
                    ),
                  ),
                ),

                // ===== TITRE DE SECTION =====
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    '🍕 SPECIALITÉS',
                    style: TextStyle(
                      fontSize: 32, // ← 2rem du HTML
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                      shadows: [
                        Shadow(
                          color: Color.fromRGBO(0, 0, 0, 0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ===== ITEMS DU MENU =====
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      itemCount: 3, // Pour commencer avec 3 pizzas
                      itemBuilder: (context, index) {
                        final pizzas = [
                          {
                            'name': 'Margherita Royale',
                            'description':
                                'Mozzarella di bufala, tomates San Marzano, basilic frais, huile d\'olive extra vierge, sur notre pâte artisanale 48h',
                            'price': '₪65',
                            'hasSignature': true,
                          },
                          {
                            'name': 'Diavola Infernale',
                            'description':
                                'Sauce tomate épicée, mozzarella, salami piquant, piments jalapeños, oignons rouges, huile pimentée maison',
                            'price': '₪72',
                            'hasSignature': true,
                          },
                          {
                            'name': 'Quatre Fromages',
                            'description':
                                'Mozzarella, gorgonzola DOP, parmesan 24 mois, ricotta fraîche, miel de truffe, noix',
                            'price': '₪78',
                            'hasSignature': false,
                          },
                        ];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _MenuItem(pizza: pizzas[index]),
                        );
                      },
                    ),
                  ),
                ),

                // 🔥 RESTE DE L'ÉCRAN (pour l'instant vide)
                const Expanded(
                  child: Center(
                    child: Text(
                      '✨ Notre menu arrive bientôt ! ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ===== PANIER FLOTTANT =====
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 0, 0, 0.9), // ← rgba(0,0,0,0.9)
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0.1),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(
                      0, 0, 0, 0.4), // 0 8px 30px rgba(0,0,0,0.4)
                  blurRadius: 30,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🛒 Commandes (0) - ₪0.00',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17.6, // ← 1.1rem du HTML
                    color: AppColors.accent,
                    letterSpacing: 0.2,
                    decoration: TextDecoration.none,
                  ),
                ),

                const SizedBox(height: 15), // Gap entre texte et bouton

                // Bouton 'voir commande'
                SizedBox(
                  width: double.infinity, // Prend toute la largeur
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft, // 45deg
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent, // var(--accent) = #FCD34D
                          AppColors.secondary, // var(--secondary) = #F97316
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(
                              0, 0, 0, 0.2), // 0 4px 15px rgba(0,0,0,0.2)
                          blurRadius: 15,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => print('Voir commande'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30, // padding: 15px 30px du HTML
                            vertical: 15,
                          ),
                          constraints: const BoxConstraints(
                            minHeight: 48, // min-height: 48px du HTML
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'VOIR COMMANDE',
                            style: TextStyle(
                              color: AppColors.primary, // color: var(--primary)
                              fontWeight: FontWeight.w700,
                              fontSize: 16, // font-size: 1rem du HTML
                            ),
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
      ],
    );
  }
}

// Petit helper pour le texte en dégradé (aucun autre fichier requis)
class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;

  const _GradientText(
    this.text, {
    required this.gradient,
    required this.style,
    this.textAlign,
    this.maxLines,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSingleLine = (maxLines ?? 0) == 1;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: isSingleLine ? TextOverflow.ellipsis : TextOverflow.visible,
        softWrap: !isSingleLine,
      ),
    );
  }
}

// Widget helper pour les pills de catégories
class _CategoryPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromRGBO(255, 255, 255, 0.9)
              : const Color.fromRGBO(255, 255, 255, 0.1),
          border: Border.all(
            color: isActive
                ? Colors.white
                : const Color.fromRGBO(255, 255, 255, 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15.2, // ← 0.95rem du HTML
          ),
        ),
      ),
    );
  }
}

// Widget helper pour les items de menu
class _MenuItem extends StatelessWidget {
  final Map<String, dynamic> pizza;

  const _MenuItem({required this.pizza});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // IMAGE SECTION
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Text(
                    '🍕',
                    style: TextStyle(fontSize: 64),
                  ),
                ),
                if (pizza['hasSignature'])
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SIGNATURE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.8, // ← 0.8rem du HTML
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // CONTENT SECTION
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pizza['name'],
                  style: const TextStyle(
                    fontSize: 22.4, // ← 1.4rem du HTML
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pizza['description'],
                  style: const TextStyle(
                    fontSize: 15.2, // ← 0.95rem du HTML
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pizza['price'],
                      style: const TextStyle(
                        fontSize: 22.4, // ← 1.4rem du HTML
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => print('${pizza['name']} ajouté !'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'AJOUTER',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
