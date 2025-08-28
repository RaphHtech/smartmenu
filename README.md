# SmartMenu App 🍕

Une application de menu numérique moderne pour restaurants, développée avec Flutter.

## Description

SmartMenu est une solution complète de menu digital permettant aux clients de consulter le menu d'un restaurant, ajouter des articles à leur panier, et passer commande directement depuis leur smartphone. L'application reproduit l'expérience d'un restaurant italien "Pizza Power" à Tel Aviv.

## Fonctionnalités

### Interface utilisateur

- **Design moderne** avec dégradés et effets visuels
- **Navigation par catégories** (Pizzas, Entrées, Pâtes, Desserts, Boissons)
- **Responsive design** adaptatif pour mobile et desktop
- **Animations fluides** et transitions élégantes

### Gestion de commande

- **Ajout d'articles** au panier avec contrôles +/-
- **Modal de révision** complète avant validation
- **Calcul automatique** des totaux et quantités
- **Système de notifications** personnalisées
- **Confirmation de commande** avec récapitulatif détaillé

### Expérience restaurant

- **Thème Pizza Power** avec identité visuelle cohérente
- **Bouton d'appel serveur** intégré
- **Badges "Signature"** pour les spécialités
- **Affichage des prix** en shekels (₪)

## Architecture technique

### Structure du projet

```
lib/
├── core/constants/
│   └── colors.dart              # Palette de couleurs centralisée
├── data/
│   └── menu_data.dart          # Données du menu
├── screens/menu/
│   └── menu_screen.dart        # Écran principal (~900 lignes)
├── widgets/
│   ├── gradient_text_widget.dart    # Texte avec dégradé
│   ├── category_pill_widget.dart    # Pills de navigation
│   └── menu_item_widget.dart       # Cartes d'articles
└── main.dart                   # Point d'entrée simplifié
```

### Principes de design

- **Séparation des responsabilités** : Widgets modulaires réutilisables
- **Single source of truth** : Palette de couleurs centralisée
- **État local** : Gestion simple avec StatefulWidget
- **Code maintenable** : Extraction des widgets complexes

## Refactoring réalisé

Le projet a été restructuré pour améliorer la maintenabilité :

- **Avant** : Fichier monolithique de 1300 lignes
- **Après** : Architecture modulaire avec séparation claire
- **Résultat** : Réduction de 30% de la complexité du fichier principal

### Extractions effectuées

1. **Données** → Fichier séparé (`menu_data.dart`)
2. **Widgets** → Modules réutilisables
3. **Couleurs** → Constantes centralisées
4. **Logique métier** → Méthodes publiques accessibles

## Installation

### Prérequis

- Flutter SDK (≥3.0.0)
- Dart SDK (≥3.0.0)
- Android Studio / VS Code
- Émulateur Android/iOS ou appareil physique

### Commandes

```bash
# Cloner le repository
git clone https://github.com/RaphHtech/smartmenu.git
cd smartmenu_app

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

## Utilisation

1. **Navigation** : Utilisez les pills de catégories pour explorer le menu
2. **Ajout au panier** : Appuyez sur "AJOUTER" puis utilisez les contrôles +/-
3. **Révision** : Cliquez sur "VOIR COMMANDE" pour réviser votre panier
4. **Modification** : Ajustez les quantités ou supprimez des articles
5. **Confirmation** : Validez votre commande pour recevoir la confirmation
6. **Assistance** : Utilisez le bouton "Serveur" pour appeler l'équipe

## Données de test

L'application inclut des données de démonstration pour :

- **6 pizzas** incluant des spécialités signature
- **1 entrée** (Antipasti Misto)
- **2 pâtes** (Carbonara, Penne Arrabbiata)
- **1 dessert** (Tiramisu)
- **1 boisson** (Chianti Classico)

Prix en shekels israéliens (₪) adaptés au marché local de Tel Aviv.

## Technologies utilisées

- **Flutter** : Framework UI multiplateforme
- **Dart** : Langage de programmation
- **Material Design 3** : Système de design Google
- **Git** : Contrôle de version avec commits sémantiques

## Déploiement

L'application est prête pour le déploiement sur :

- **Android** : Google Play Store
- **iOS** : App Store
- **Web** : Hébergement statique

Aucune configuration backend requise - fonctionne entièrement en local.

## Roadmap

### Améliorations possibles

- [ ] Intégration d'images réelles
- [ ] Système de favoris
- [ ] Support multilingue (FR/EN/HE)
- [ ] Gestion des allergènes
- [ ] Intégration paiement
- [ ] Mode sombre/clair
- [ ] Analytics utilisateur

### Architecture évoluée

- [ ] State management (Bloc/Riverpod)
- [ ] API REST / GraphQL
- [ ] Base de données locale
- [ ] Tests automatisés
- [ ] CI/CD Pipeline

## Contribution

Le projet suit les bonnes pratiques de développement :

- **Commits sémantiques** : feat/fix/refactor/docs
- **Code review** : Validation avant merge
- **Documentation** : README et commentaires
- **Architecture** : Séparation claire des responsabilités

## Licence

Projet éducatif - Tous droits réservés.

---

**Développé avec ❤️ en Flutter**

_Application de démonstration pour portfolio technique_
