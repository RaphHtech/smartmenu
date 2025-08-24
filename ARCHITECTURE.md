# SmartMenu – Architecture (résumé opératoire)

## Sources de vérité (où modifier quoi)

- Couleurs & gradients : lib/core/constants/colors.dart
- Styles de texte : lib/core/constants/text_styles.dart
- Thème Material global : lib/main.dart (\_buildTheme) ← N’influence PAS le header custom
- Header visuel (gradient, titre centré, bouton serveur) : lib/widgets/custom_app_bar.dart
- Textes & langues : lib/providers/language_provider.dart (translate('key'))

## Règles de modification

- Je veux changer la couleur du header → colors.dart (headerGradient) + custom_app_bar.dart (decoration)
- Je veux changer la police/taille du titre header → text_styles.dart (headerTitle) + utilisé dans custom_app_bar.dart
- Je veux changer le texte/bouton du serveur → language_provider.dart (clé 'call_server') + custom_app_bar.dart (translate)
- Je veux centrer/cadrer le titre → custom_app_bar.dart (layout Row→Stack, maxLines:2, textAlign:center)
- Je veux les chips catégories → lib/widgets/category_chips.dart
- Je veux le badge panier et son total → lib/providers/cart_provider.dart (totalItems) + lib/widgets/cart_floating_button.dart
- Je veux les items du menu → lib/providers/menu_provider.dart + lib/models/menu_item.dart + lib/widgets/menu_item_card.dart
- Navigation principale → lib/core/routes/app_router.dart

## Convention

- Pas de style inline → utiliser AppTextStyles.
- Pas de couleur hardcodée → utiliser AppColors.
- Pas de if(lang) dans l’UI → utiliser languageProvider.translate('clé').
- Un widget lit des providers (watch/select) mais ne déclenche pas de navigation dans les providers.
