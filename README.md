# SmartMenu App 🍕

Une application de menu digital moderne pour restaurants, développée avec Flutter.

## 📱 À propos du projet

**SmartMenu** est une application mobile Flutter qui permet aux restaurants de proposer un menu digital interactif à leurs clients. L'application offre une interface moderne avec des dégradés, une navigation fluide par catégories et un système de panier intégré.

## ✨ Fonctionnalités actuelles

- 🎨 **Interface moderne** avec dégradés et design responsive
- 📱 **Navigation par catégories** (Pizzas, Boissons, Desserts, etc.)
- 🛒 **Panier flottant** avec compteur d'articles
- 🎯 **Design optimisé** pour smartphone
- 🔄 **Architecture Provider** pour la gestion d'état
- 🌐 **Support multilingue** prévu

## 🎯 Fonctionnalités principales

### 📋 Menu interactif
- Affichage des plats par catégories
- Cards de produits avec images et prix
- Interface intuitive et moderne

### 🛒 Système de panier
- Ajout/suppression d'articles
- Visualisation du total
- Bouton flottant avec compteur

### 🎨 Design & UX
- Dégradés colorés modernes
- Interface responsive
- Navigation fluide

## 🛠 Stack technique

- **Framework** : Flutter 3.x
- **Langage** : Dart
- **État management** : Provider
- **UI** : Material Design avec thème personnalisé
- **Architecture** : MVVM avec Provider pattern

## 📂 Structure du projet

```
lib/
├── core/
│   ├── constants/
│   │   └── colors.dart           # Palette de couleurs et dégradés
│   └── themes/
│       └── app_theme.dart        # Configuration du thème global
├── providers/
│   ├── menu_provider.dart        # Gestion des données menu
│   ├── cart_provider.dart        # Gestion du panier
│   └── language_provider.dart    # Gestion des langues
├── screens/
│   ├── home_screen.dart          # Écran d'accueil
│   ├── menu_screen.dart          # Écran principal du menu
│   ├── cart_screen.dart          # Écran du panier
│   └── qr_scanner_screen.dart    # Scanner QR (prévu)
├── widgets/
│   ├── menu_item_card.dart       # Card produit
│   ├── category_chips.dart       # Puces de catégories
│   ├── cart_floating_button.dart # Bouton panier flottant
│   └── custom_app_bar.dart       # Barre d'application
└── main.dart                     # Point d'entrée
```

## 🎨 Design System

### Couleurs principales
- **Dégradé primaire** : Orange vers rouge-orange
- **Accent** : Couleurs vives pour les CTAs
- **Background** : Dégradés fluides
- **Cards** : Backgrounds semi-transparents

## 🚀 Installation et lancement

### Prérequis
- Flutter SDK (version 3.0+)
- VS Code ou Android Studio
- Un émulateur ou appareil physique

### Installation
```bash
# Cloner le repository
git clone [URL_DU_REPO]
cd smartmenu-app

# Installer les dépendances
flutter pub get

# Créer les dossiers d'assets
mkdir -p assets/images assets/icons

# Lancer l'application
flutter run
```

## 📱 Plateformes supportées

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- 🔄 Web (en développement)

## 🔧 Configuration

### Assets requis
Créez les dossiers suivants dans votre projet :
```
assets/
├── images/           # Images des plats
└── icons/           # Icônes personnalisées
```

Ajoutez dans `pubspec.yaml` :
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

## 🏗 Roadmap de développement

### Phase actuelle - MVP 
- [x] Interface de base avec Provider
- [x] Affichage du menu par catégories  
- [x] Système de panier fonctionnel
- [x] Design moderne avec dégradés
- [ ] Corrections mineures d'UI (alignements, espacements)

### Phase 2 - Fonctionnalités avancées
- [ ] Scanner QR code pour accès restaurant
- [ ] Envoi de commandes réelles
- [ ] Interface restaurateur
- [ ] Notifications push

### Phase 3 - Optimisations
- [ ] Système de paiement intégré
- [ ] Mode offline
- [ ] Analytics et métriques
- [ ] Tests automatisés

## 🔄 État actuel

**Version** : MVP en développement  
**Status** : 🚧 Interface en cours d'ajustement  
**Focus actuel** : Perfectionnement de l'UI pour correspondre exactement au design HTML de référence

## 🛠 Dépendances principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  go_router: ^10.1.2
  # Autres dépendances à ajouter selon les besoins
```

## 👨‍💻 Développement

**Développeur** : RaphHtech  
**Architecture** : MVVM avec Provider  
**Approche** : MVP itératif avec améliorations progressives

## 📞 Contact

Pour toute question sur le projet ou contribution, ouvrez une issue ou contactez-moi directement.

---

**Status** : 🚧 En développement actif - Ajustements UI en cours
