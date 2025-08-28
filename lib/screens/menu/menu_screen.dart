import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/menu_data.dart';
import '../../widgets/gradient_text_widget.dart';
import '../../widgets/category_pill_widget.dart';
import '../../widgets/menu_item_widget.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => SimpleMenuScreenState();
}

class SimpleMenuScreenState extends State<MenuScreen> {
  int _cartItemCount = 0;
  double _cartTotal = 0.0;
  String _selectedCategory = 'Pizzas';
  Map<String, int> itemQuantities = {}; // Track quantities per item
  bool _showOrderModal = false;
  final Map<String, List<Map<String, dynamic>>> _menuData = menuData;

  void addToCart(String itemName, double price) {
    setState(() {
      if (itemQuantities.containsKey(itemName)) {
        itemQuantities[itemName] = itemQuantities[itemName]! + 1;
      } else {
        itemQuantities[itemName] = 1;
      }
      _cartItemCount++;
      _cartTotal += price;
    });

    // Animation visuelle (optionnel)
    _showCustomNotification(context, '✅ $itemName ajouté au panier !');
  }

  void increaseQuantity(String itemName, double price) {
    setState(() {
      itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + 1;
      _cartItemCount++;
      _cartTotal += price;
    });
  }

  void decreaseQuantity(String itemName, double price) {
    setState(() {
      int currentQty = itemQuantities[itemName] ?? 0;
      if (currentQty > 1) {
        itemQuantities[itemName] = currentQty - 1;
        _cartItemCount--;
        _cartTotal -= price;
      } else {
        itemQuantities.remove(itemName);
        _cartItemCount--;
        _cartTotal -= price;
      }
    });
  }

  void _showCustomNotification(BuildContext context, String message,
      {bool persistent = false}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 25,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: persistent
                ? Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 30),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17.6,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            overlayEntry.remove();
                            setState(() {
                              _showOrderModal = false;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 17.6,
                    ),
                  ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-suppression seulement si pas persistant
    if (!persistent) {
      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    }
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _showOrderReview() {
    if (_cartItemCount == 0) {
      _showCustomNotification(context, '🛒 Votre panier est vide !');
      return;
    }
    setState(() {
      _showOrderModal = true;
    });
  }

  void _closeOrderReview() {
    setState(() {
      _showOrderModal = false;
    });
  }

  void _confirmOrder() {
    // Construire le récapitulatif détaillé
    String orderSummary = '🎉 COMMANDE CONFIRMÉE !\n\n📋 RÉCAPITULATIF:\n\n';

    for (var entry in itemQuantities.entries) {
      double itemPrice = 0.0;
      for (var category in _menuData.values) {
        for (var item in category) {
          if (item['name'] == entry.key) {
            final priceText = item['price'].toString().replaceAll('₪', '');
            itemPrice = double.tryParse(priceText) ?? 0.0;
            break;
          }
        }
      }
      orderSummary +=
          '• ${entry.key} x${entry.value} - ₪${(itemPrice * entry.value).toStringAsFixed(2)}\n';
    }

    orderSummary += '\nTOTAL: ₪${_cartTotal.toStringAsFixed(2)}\n\n';
    orderSummary += '✅ Votre commande a été transmise à la cuisine !\n';
    orderSummary += '⏱️ Temps d\'attente estimé: 15-20 minutes';

    _showCustomNotification(context, orderSummary, persistent: true);
  }

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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ===== HEADER (en dur) =====
                SliverAppBar(
                  pinned: true,
                  toolbarHeight:
                      96, // ← hauteur fixe de la bannière (essaie 88–92)
                  collapsedHeight: 96, // ← même hauteur quand “collapsée”
                  backgroundColor: Colors.transparent,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 10, sigmaY: 10), // blur 10px
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        decoration: const BoxDecoration(
                          color: AppColors.headerOverlay, // rgba(0,0,0,0.20)
                          border: Border(
                            bottom: BorderSide(
                                color: AppColors.headerDivider,
                                width: 1), // 10%
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
                                      Text('🍽️',
                                          style: TextStyle(fontSize: 16)),
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
                                child: GradientText(
                                  'PIZZA\nPOWER',
                                  gradient:
                                      AppColors.titleGradient, // blanc → jaune
                                  style: TextStyle(
                                    fontSize: 24, // 22–24 selon ton goût
                                    fontWeight: FontWeight.w800,
                                    height: 1.10, // interligne serré
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            // Droite : bouton “Serveur”
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  // ← rétrécit le bouton si l’espace manque
                                  fit: BoxFit.scaleDown,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              '📞 Appel envoyé au serveur'),
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
                ),

                // ===== SECTION HÉRO (2e “rectangle”) =====
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 40, horizontal: 20),
                        decoration:
                            const BoxDecoration(color: AppColors.heroOverlay),
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
                                  const GradientText(
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
                    ],
                  ),
                ),

                // ===== SECTION PROMO (glassmorphism) =====
                SliverToBoxAdapter(
                  child: Container(
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
                ),

                // ===== NAVIGATION CATÉGORIES =====
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 20, right: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CategoryPill(
                            label: '🍕 Pizzas',
                            isActive: _selectedCategory == 'Pizzas',
                            onTap: () => _selectCategory('Pizzas'),
                          ),
                          const SizedBox(width: 12),
                          CategoryPill(
                              label: '🥗 Entrées',
                              isActive: _selectedCategory == 'Entrées',
                              onTap: () => _selectCategory('Entrées')),
                          const SizedBox(width: 12),
                          CategoryPill(
                              label: '🍝 Pâtes',
                              isActive: _selectedCategory == 'Pâtes',
                              onTap: () => _selectCategory('Pâtes')),
                          const SizedBox(width: 12),
                          CategoryPill(
                              label: '🍰 Desserts',
                              isActive: _selectedCategory == 'Desserts',
                              onTap: () => _selectCategory('Desserts')),
                          const SizedBox(width: 12),
                          CategoryPill(
                              label: '🍹 Boissons',
                              isActive: _selectedCategory == 'Boissons',
                              onTap: () => _selectCategory('Boissons')),
                          const SizedBox(
                              width:
                                  20), // ← AJOUTE l'espacement final à la fin
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== TITRE DE SECTION =====
                const SliverToBoxAdapter(
                  child: Padding(
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
                ),

                // ===== ITEMS DU MENU =====
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final currentItems = _menuData[_selectedCategory] ?? [];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: MenuItem(pizza: currentItems[index]),
                        );
                      },
                      childCount: _menuData[_selectedCategory]?.length ?? 0,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
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
                Text(
                  '🛒 Commandes ($_cartItemCount) - ₪${_cartTotal.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17.6,
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
                        onTap: _showOrderReview,
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

        // Modal de révision de commande
        if (_showOrderModal)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDC2626), // Rouge (primary)
                        Color(0xFFF97316), // Orange (secondary)
                        Color(0xFFFCD34D), // Jaune (accent)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 255, 255, 0.2),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      const Text(
                        '📋 RÉVISION DE VOTRE COMMANDE',
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),

                      // Liste des items
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: itemQuantities.entries.map((entry) {
                              // Trouver le prix de l'article dans les données
                              double itemPrice = 0.0;
                              for (var category in _menuData.values) {
                                for (var item in category) {
                                  if (item['name'] == entry.key) {
                                    final priceText = item['price']
                                        .toString()
                                        .replaceAll('₪', '');
                                    itemPrice =
                                        double.tryParse(priceText) ?? 0.0;
                                    break;
                                  }
                                }
                              }

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(15),
                                // LIGNE DE SÉPARATION EN BAS
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromRGBO(255, 255, 255, 0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),

                                child: LayoutBuilder(builder: (context, c) {
                                  // Breakpoint "étroit" pour la modale
                                  final isNarrow = c.maxWidth < 360;

                                  // Ta taille de contrôles, compacte si étroit
                                  final btn = isNarrow ? 28.0 : 32.0;
                                  final iconSz = isNarrow ? 16.0 : 18.0;
                                  final qtyPad = isNarrow ? 10.0 : 16.0;
                                  final gap = isNarrow ? 8.0 : 10.0;

                                  // Widgets réutilisables
                                  final nameText = Text(
                                    entry.key,
                                    maxLines: isNarrow
                                        ? 2
                                        : 1, // ← 2 lignes en étroit
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      decoration: TextDecoration.none,
                                    ),
                                  );

                                  final qtyControls = Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          255, 255, 255, 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // --- bouton moins ---
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (itemQuantities[entry.key]! >
                                                  1) {
                                                itemQuantities[entry.key] =
                                                    itemQuantities[entry.key]! -
                                                        1;
                                                _cartItemCount--;
                                                _cartTotal -= itemPrice;
                                              } else {
                                                _cartItemCount -=
                                                    itemQuantities[entry.key]!;
                                                _cartTotal -= itemPrice *
                                                    itemQuantities[entry.key]!;
                                                itemQuantities
                                                    .remove(entry.key);
                                                if (itemQuantities.isEmpty) {
                                                  _closeOrderReview();
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: btn,
                                            height: btn,
                                            decoration: const BoxDecoration(
                                                color: AppColors.accent,
                                                shape: BoxShape.circle),
                                            child: Icon(Icons.remove,
                                                color: AppColors.primary,
                                                size: iconSz),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: qtyPad),
                                          child: Text(
                                            '${entry.value}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ),
                                        // --- bouton plus ---
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              itemQuantities[entry.key] =
                                                  itemQuantities[entry.key]! +
                                                      1;
                                              _cartItemCount++;
                                              _cartTotal += itemPrice;
                                            });
                                          },
                                          child: Container(
                                            width: btn,
                                            height: btn,
                                            decoration: const BoxDecoration(
                                                color: AppColors.accent,
                                                shape: BoxShape.circle),
                                            child: Icon(Icons.add,
                                                color: AppColors.primary,
                                                size: iconSz),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  // --- bouton supprimer ---
                                  final deleteBtn = GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _cartItemCount -=
                                            itemQuantities[entry.key]!;
                                        _cartTotal -= itemPrice *
                                            itemQuantities[entry.key]!;
                                        itemQuantities.remove(entry.key);
                                        if (itemQuantities.isEmpty) {
                                          _closeOrderReview();
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(isNarrow ? 6 : 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.delete_outline,
                                          color: Colors.white, size: 18),
                                    ),
                                  );

                                  final priceText = Directionality(
                                    textDirection:
                                        TextDirection.ltr, // pour '₪'
                                    child: Text(
                                      '₪${(itemPrice * entry.value).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  );

                                  // --- Layout responsive ---
                                  if (isNarrow) {
                                    // 2 LIGNES : (Nom + Prix) / (Qty + Delete)
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: nameText),
                                            const SizedBox(width: 8),
                                            priceText,
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            qtyControls,
                                            SizedBox(width: gap),
                                            deleteBtn,
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    // LARGE : 1 LIGNE compressible à droite
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(child: nameText),
                                        const SizedBox(width: 12),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              qtyControls,
                                              SizedBox(width: gap),
                                              deleteBtn,
                                              SizedBox(width: gap),
                                              priceText,
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Total
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'TOTAL: ₪${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Boutons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _closeOrderReview,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                '← MODIFIER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accent,
                                    AppColors.secondary
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _confirmOrder,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'CONFIRMER',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
