# SmartMenu App 🍕

Une application de menu numérique moderne pour restaurants, développée avec **Flutter** (mobile & web PWA) et **Firebase**.

---

## 📖 Description

**SmartMenu** est une solution SaaS multi-tenant permettant aux restaurants de digitaliser leurs menus avec un système QR code moderne.

### Architecture

- **Client PWA** (`/r/{restaurantId}`) : Menu accessible via QR code, panier, commande
- **Admin Dashboard** (`/admin`) : Interface restaurateur SaaS premium pour gérer menu, plats, images
- **Multi-tenant** : Chaque restaurant a ses données isolées avec sécurité Firestore

---

## 🚀 État Actuel (Septembre 2025) - Version 2.2.0

### ✅ Fonctionnalités Terminées

**Client PWA :**

- Navigation par catégories dynamiques (Pizzas, Entrées, Pâtes, Desserts, Boissons)
- Ajout au panier avec contrôles +/-
- Modal de révision avant validation
- Notifications (confirmation commande)
- QR Code → URL directe (ex: `/r/newtest`)
- Offline partiel via Service Worker (cache-first)
- Manifest PWA (installable comme app)
- Nom restaurant dynamique depuis Firestore
- Devise dynamique (₪, €, $) selon restaurant
- Tagline et bandeau promo personnalisables

**Admin Dashboard - Interface SaaS Premium :**

- **AdminShell** : Sidebar/Topbar professionnelle (inspiration Stripe/Notion/Linear)
- **Navigation complète** : Dashboard, Menu, Médias, Infos resto, Paramètres
- **Responsive design** : Sidebar fixe desktop, drawer mobile
- **Breadcrumbs** : Navigation contextuelle avec retour intelligent
- **Design System Premium** : Palette neutre + accent indigo, typographie hiérarchisée
- Auth Firebase (email/password) avec mapping users/{uid}
- Signup → Create Restaurant → Dashboard complet
- CRUD plats : création, modification, suppression
- Upload images Firebase Storage (avec gestion suppression)
- Options : plat signature, visible/masqué, catégories
- Preview live (ouvre `/r/{rid}` nouvel onglet)
- **Modification nom restaurant** : Interface dédiée dans Paramètres
- Gestion devises multiples (ILS par défaut)
- Placeholders avec icônes de catégorie (🍕, 🥗, etc.)
- Screen "Infos du restaurant" pour modifier tagline/promo

**Infrastructure :**

- Firestore Rules multi-tenant sécurisées
- Storage Rules avec lecture publique images
- CORS configuré (localhost + production)
- Service Worker différencié (cache client vs network admin)
- Upload web-safe avec putData(Uint8List)

### 🎯 Nouvelles Fonctionnalités v2.1.0

- **AdminShell Layout** : Interface SaaS avec sidebar/topbar premium
- **Navigation intelligente** : Retour contextuel (sous-pages → Dashboard)
- **Responsive optimisé** : Recherche adaptive, débordement corrigé
- **Modification nom restaurant** : Interface intuitive avec validation
- **Écrans placeholder** : Médias et Paramètres avec design cohérent

### 🎯 Nouvelles Fonctionnalités v2.2.0 - Phase 3 Étape 1

- **Filtres et recherche avancés** : Interface complète dans AdminDashboardScreen
- **Recherche en temps réel** : Filtrage instantané par nom/description/catégorie avec support accents
- **Tri dynamique** : Par catégorie/nom/prix avec persistence de l'état
- **Chips de filtrage** : Filtrage par catégorie avec toggle et état "Toutes"
- **Architecture optimisée** : Interface de recherche séparée du StreamBuilder pour performance
- **Responsive design** : Champs de recherche et tri adaptés mobile/desktop

**Interface de filtrage :**

- Champ de recherche avec debouncing (300ms)
- Menu déroulant tri compact et responsive
- Chips catégories scrollables horizontalement
- Bouton clear avec conservation du focus
- Normalisation des accents pour recherche tolérante

### 🎯 Nouvelles Fonctionnalités v2.3.0 - Phase 3 Étape 2

- **AdminMediaScreen complète** : Interface de gestion des médias opérationnelle
- **Upload d'images** : Sélection de fichiers avec validation format/taille (PNG, JPG, WebP - max 5MB)
- **Galerie des médias** : Grille responsive des images uploadées avec métadonnées
- **Gestion avancée** : Suppression avec confirmation, affichage taille fichier et date
- **Feedback utilisateur** : Progress bar d'upload, alertes d'erreur avec dismiss
- **Storage Rules optimisées** : Permissions multi-tenant pour upload/suppression sécurisés

**Interface MediaScreen :**

- Zone d'upload cliquable avec instructions claires
- Bouton "Ajouter" dans topbar pour accès rapide
- Grille 4 colonnes adaptative desktop/mobile
- Cartes médias avec aperçu, nom, taille et actions
- Gestion d'erreurs contextuelle (format, taille, permissions)
- Loading states et empty states élégants

---

## 📊 État Technique mis à jour

**Statut :** Phase 3 Étape 1 terminée - Filtres et recherche opérationnels  
**Version :** 2.3.0 (Filtres + Recherche + MediaScreen + Navigation stable)
**Environnement :** Développement local + Firebase project configuré  
**Dernière mise à jour :** Septembre 2025

### Nouvelles Notes Techniques

- **Architecture de recherche** : Interface séparée du StreamBuilder pour éviter la perte de focus
- **Performance** : Debouncing de 300ms + filtrage en mémoire sur snapshot existant
- **Normalisation accents** : Fonction `_normalize()` pour recherche tolérante (français/hébreu)
- **État local** : Gestion cohérente des filtres avec TextEditingController listener
- **Responsive** : Menu déroulant largeur fixe (130px) pour éviter overflow mobile

### Leçons Apprises Phase 3

- **Focus management** : TextField dans StreamBuilder cause perte de focus systématique
- **Architecture reactive** : Séparer UI stable (filtres) de UI dynamique (liste) crucial pour UX
- **Performance filtering** : Filtrage en mémoire plus rapide que requêtes Firestore multiples
- **State management** : TextEditingController.listener plus stable que onChanged pour recherche temps réel

---

## 🎨 AdminShell - Interface SaaS Premium

### Architecture AdminShell

```
lib/widgets/ui/
├── admin_shell.dart          # Layout principal sidebar + topbar
├── admin_themed.dart         # Wrapper thème admin
└── admin_*.dart             # Composants spécialisés

lib/screens/admin/
├── admin_dashboard_screen.dart    # Gestion menu (wrappé AdminShell)
├── admin_media_screen.dart        # Placeholder médias
├── admin_settings_screen.dart     # Paramètres + nom restaurant
├── admin_restaurant_info_screen.dart # Infos détaillées
└── ...                           # Autres écrans admin
```

### Navigation AdminShell

**Sidebar (Desktop 1024px+) :**

- Dashboard : Liste des plats + stats
- Menu : Alias vers Dashboard (compatibilité)
- Médias : Gestion fichiers (placeholder)
- Infos resto : Tagline, promo, devise
- Paramètres : Nom restaurant, équipe (futur)

**Topbar responsive :**

- Burger menu (mobile) / Bouton retour contextuel
- Titre de page dynamique
- Actions personnalisées par écran
- Recherche globale (>1000px) / Icône recherche (<1000px)

**Navigation intelligente :**

- Sidebar → Pages racines (Dashboard, Paramètres, etc.) sans retour
- Sous-pages → Flèche retour vers page parente
- Breadcrumbs contextuels

### Design System Appliqué

- **Palette Premium** : Gris neutres (#F9FAFB → #111827) + accent indigo (#6366F1)
- **Typography** : Hiérarchie Display/Headline/Body/Label cohérente
- **Composants** : Cards fines, inputs modernes, buttons premium
- **States** : Loading, hover, focus, error harmonisés
- **Responsive** : Breakpoints logiques, débordement maîtrisé

---

## 🛠 Architecture Technique

### Stack Principal

- **Frontend** : Flutter Web (PWA + Admin)
- **Backend** : Firebase (Firestore + Auth + Storage + Hosting)
- **Sécurité** : Rules multi-tenant + mapping users/{uid}
- **Design** : Material 3 + Design System custom admin

### Structure Firestore

```
restaurants/{rid}/
  ├── info/details (name, currency, tagline, promo_text, promo_enabled, owner_uid)
  ├── members/{uid} (role, invited_at)
  └── menus/{itemId} (name, price, category, imageUrl, signature, visible)

users/{uid}/ (primary_restaurant_id, role, created_at)
```

### Routing Web

```
/ → HomeScreen (demo)
/r/{restaurantId} → MenuScreen (PWA client)
/admin → AdminLoginScreen (avec AdminShell)
/admin/signup → AdminSignupScreen (avec AdminShell)
```

---

## 📂 Structure Projet

```
lib/
├── core/
│   ├── constants/colors.dart        # Palette client (PWA)
│   └── design/                      # 🆕 Design System Admin
│       ├── admin_tokens.dart        # Variables design (couleurs, spacing, etc.)
│       ├── admin_typography.dart    # Hiérarchie typographique
│       └── admin_theme.dart         # ThemeData Material 3
├── services/
│   ├── cart_service.dart           # Gestion panier
│   └── firebase_menu_service.dart  # Intégration Firestore (client)
├── screens/
│   ├── home_screen.dart            # Accueil (QR / demo)
│   ├── qr_scanner_screen.dart      # Scanner QR multi-restaurants
│   ├── menu/
│   │   └── menu_screen.dart        # Menu client
│   └── admin/                      # 🆕 Interface AdminShell
│       ├── admin_login_screen.dart      # Login restaurateur
│       ├── admin_signup_screen.dart     # Signup + onboarding
│       ├── create_restaurant_screen.dart # Création resto + owner
│       ├── admin_dashboard_screen.dart   # Dashboard liste plats
│       ├── admin_media_screen.dart       # Gestion médias (placeholder)
│       ├── admin_settings_screen.dart    # Paramètres + nom restaurant
│       ├── admin_restaurant_info_screen.dart # Gestion tagline/promo
│       └── menu_item_form_screen.dart    # CRUD plats + upload images
├── widgets/
│   ├── ui/                         # 🆕 Composants AdminShell
│   │   ├── admin_shell.dart        # Layout principal sidebar/topbar
│   │   └── admin_themed.dart       # Wrapper + navigation admin
│   ├── modals/order_review_modal.dart
│   ├── notifications/custom_notification.dart
│   ├── menu/
│   │   ├── cart_floating_widget.dart
│   │   └── app_header_widget.dart
│   ├── category_pill_widget.dart
│   ├── gradient_text_widget.dart
│   └── menu_item_widget.dart
└── main.dart                       # Init Firebase + routing

web/
├── index.html                      # Entrypoint Web (Flutter loader)
├── manifest.json                   # PWA manifest
├── sw.js                          # Service Worker (cache client/admin)
└── icons/
    ├── Icon-192.png
    └── Icon-512.png
```

---

## ⚙️ Setup Développement

### Prérequis

- Flutter 3.16+ (Web enabled)
- Firebase CLI
- Google Cloud SDK (pour gsutil)
- Git

### Installation

```bash
git clone https://github.com/RaphHtech/smartmenu.git
cd smartmenu_app
flutter pub get
```

### Configuration Firebase

**1. Activer les produits Firebase :**

- Console Firebase → **Auth** → activer **Email/Password**
- **Authorized domains** : ajouter `localhost`, `127.0.0.1`, `smartmenu-mvp.web.app`
- **Firestore** → activer, coller les Rules ci-dessous
- **Storage** → activer, coller les Rules ci-dessous

**2. Configuration CORS Storage :**

```bash
# Créer cors.json dans le dossier racine :
echo '[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
  }
]' > cors.json

# Appliquer CORS :
gcloud auth login
gcloud config set project smartmenu-mvp
gsutil cors set cors.json gs://smartmenu-mvp.firebasestorage.app
```

### Développement

```bash
flutter run -d chrome  # Mode dev
flutter build web      # Build production
```

### Tests manuels

- **Client** : ouvrir `/r/{restaurantId}`
- **Admin** :
  1. `/admin/signup` → créer compte + restaurant
  2. `/admin` → login puis redirection Dashboard
  3. CRUD plats → upload image Storage
  4. Preview → `/r/{rid}`
  5. **Nouveau** : Paramètres → modifier nom restaurant

---

## 🔒 Sécurité & Rules Firebase

### Firestore Rules (Multi-tenant)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /restaurants/{rid} {
      // Infos restaurant
      match /info/{docId} {
        allow read: if true;
        allow create: if request.auth != null && request.resource.data.owner_uid == request.auth.uid;
        allow update, delete: if isMember(rid);
      }

      // Menus
      match /menus/{itemId} {
        allow read: if true;
        allow write: if isMember(rid);
      }

      // Membres
      match /members/{uid} {
        allow read: if request.auth != null && request.auth.uid == uid;
        allow create: if request.auth != null && request.auth.uid == uid && request.resource.data.role == "owner";
        allow update, delete: if isMember(rid) && request.auth.uid == uid;
      }
    }

    function isMember(rid) {
      return request.auth != null &&
             exists(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid));
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurants/{rid}/menu/{file} {
      allow read: if true;
      allow write: if request.auth != null &&
        exists(/databases/(default)/documents/restaurants/$(rid)/members/$(request.auth.uid));
    }
  }
}
```

---

## 📋 Roadmap

### ✅ Phase 1 - MVP Fonctionnel (Terminé)

- Client PWA Flutter Web terminé
- Authentification restaurateurs (login/signup)
- Onboarding propriétaire (CreateRestaurantScreen)
- Rules Firestore multi-tenant + Rules Storage
- Dashboard restaurateur : liste temps réel des plats
- CRUD plats + upload images (web + mobile)
- Upload d'images avec suppression
- Placeholders avec icônes de catégorie

### ✅ Phase 2 - AdminShell & Interface Premium (Terminé - v2.1.0)

- **Design System Premium** : Couleurs neutres, espacements, typographie
- **AdminShell Layout** : Sidebar + Topbar professionnelle
- **Navigation Premium** : Dashboard, Menu, Médias, Infos, Paramètres
- **Responsive Design** : Sidebar fixe desktop, drawer mobile
- **Breadcrumbs** : Navigation contextuelle
- **Modification nom restaurant** : Interface dédiée avec validation
- **Interface transformation** : Passage de basique à niveau Stripe/Notion

### 🔮 Phase 3 - Fonctionnalités Utilisateur

- **Recherche globale** : Fonctionnalité complète dans topbar
- **Navigation retour** : Amélioration UX entre écrans
- **Tri par catégorie** : Filtres et organisation
- **Gestion équipe** : Invitations, rôles (manager, staff)
- **Analytics de base** : Vues menu, plats populaires

### 🔮 Phase 4 - Composants Premium

- **Liste Plats Améliorée** : Thumbnails carrées, hover effects, skeleton loading
- **États Vides Élégants** : Illustrations, CTAs clairs
- **Modales Cohérentes** : Design system unifié
- **Notifications Premium** : Toast messages avec icônes
- **Formulaires Sectionnés** : Groupes logiques, validation temps réel

### 🔮 Phase 5 - Features Avancées

- **Gestion Médias** : Upload, organisation, optimisation images
- **Analytics Dashboard** : Métriques avancées, rapports
- **Preview Live Intégrée** : iframe dans admin au lieu nouvel onglet
- **Export PDF Menu** : Génération automatique format print
- **Notifications Temps Réel** : WebSocket pour commandes
- **Multi-langues** : Hebrew/English/French selon marché

### 🚀 Phase 6 - Production & Scale

- **Déploiement Firebase Hosting** : `smartmenu-mvp.web.app`
- **Core Web Vitals** : Optimisations performance
- **Analytics Complètes** : Usage patterns, conversion rates
- **API REST** : Intégrations tierces (POS, delivery)
- **Tests E2E** : Couverture complète user journeys

---

## 📊 État Technique

**Statut :** Phase 3 Étape 1 terminée - Filtres et recherche opérationnels  
**Version :** 2.2.0 (Filtres + Recherche + Navigation stable)  
**Environnement :** Développement local + Firebase project configuré  
**Déploiement cible :** `https://smartmenu-mvp.web.app`  
**Dernière mise à jour :** Septembre 2025

### Notes Techniques Importantes

- **Bucket Storage** : `smartmenu-mvp.firebasestorage.app` (configuré)
- **Devise par défaut** : ILS (marché israélien)
- **PWA** : Cache différencié client/admin pour UX optimale
- **Upload Web** : `putData(Uint8List)` obligatoire pour compatibilité web
- **Design Isolation** : Admin premium isolé du client PWA
- **Navigation** : `pushAndRemoveUntil` pour pages racines, retour contextuel
- **Architecture de recherche** : Interface séparée du StreamBuilder pour éviter la perte de focus
- **Performance** : Debouncing de 300ms + filtrage en mémoire sur snapshot existant
- **Normalisation accents** : Fonction `_normalize()` pour recherche tolérante (français/hébreu)
- **État local** : Gestion cohérente des filtres avec TextEditingController listener
- **Responsive** : Menu déroulant largeur fixe (130px) pour éviter overflow mobile
- **MediaScreen opérationnelle** : Upload/suppression Firebase Storage avec validation complète
- **Storage Rules multi-tenant** : Permissions basées sur membership restaurant pour sécurité
- **Upload validation** : Contrôle format (PNG/JPG/WebP) et taille (max 5MB) côté client
- **UI responsive** : Grille adaptive 4 colonnes desktop, gestion mobile optimisée

### Leçons Apprises

- **AdminShell Pattern** : Layout centralisé évite duplication code et assure cohérence
- **Navigation intelligente** : Différencier pages racines vs sous-pages critique pour UX
- **Responsive Design** : Champ recherche adaptatif évite débordements
- **Design System** : Tokens centralisés facilitent maintenance et évolutions
- **Validation formulaires** : Feedback temps réel améliore satisfaction utilisateur
- **Focus management** : TextField dans StreamBuilder cause perte de focus systématique
- **Architecture reactive** : Séparer UI stable (filtres) de UI dynamique (liste) crucial pour UX
- **Performance filtering** : Filtrage en mémoire plus rapide que requêtes Firestore multiples
- **State management** : TextEditingController.listener plus stable que onChanged pour recherche temps réel
- **Firebase Storage Rules** : Délai de propagation (1-2 min) critique pour tests fonctionnels
- **File upload UX** : Progress bar et gestion d'erreurs essentiels pour feedback utilisateur
- **Storage permissions** : Vérification membership restaurant plus sécurisée que auth simple

---

## 🎯 Prochaines Étapes Immédiates

### Phase 3 Priority (Prochaine semaine)

1. **Recherche globale fonctionnelle** : Implémentation recherche plats
2. **Navigation retour optimisée** : Résolution bug bouton retour Dashboard
3. **Tri par catégorie** : Filtres dans liste plats
4. **Gestion équipe basique** : Invitations collaborateurs

### Corrections Techniques

1. **Debug navigation** : Bouton retour persistant sur Dashboard
2. **CORS avancé** : Headers upload résumable pour gros fichiers
3. **RBAC sécurité** : Restriction owner/manager pour actions sensibles

---

## 🎨 Style Guidelines Admin

### Palette Couleurs

- **Neutrals** : 50 (background) → 900 (text max contrast)
- **Primary** : Indigo moderne (#6366F1) pour actions
- **States** : Success (#10B981), Warning (#F59E0B), Error (#EF4444)

### Typography Hierarchy

- **Display** : Titres de page (32px, 24px, 20px)
- **Headline** : Titres composants (18px, 16px, 14px)
- **Body** : Contenu (16px, 14px, 12px)
- **Label** : UI elements (14px, 12px, 11px)

### Spacing System

- **Base 4px** : 4, 8, 12, 16, 20, 24, 32, 40, 48, 64
- **Radius** : 4, 8, 12, 16, 24 selon contexte
- **Elevation** : Ombres subtiles, max 8px blur

---

## 💥 Crédits

Projet développé par **Raphaël Benitah** avec accompagnement technique collaboratif (Claude + ChatGPT).

**AdminShell & Design System** inspirés de Stripe Dashboard, Notion, Linear pour une expérience restaurateur premium.

---

**Version :** 2.1.0 (AdminShell + Modification nom restaurant)  
**License :** Propriétaire  
**Contact :** rafaelbenitah@gmail.com

**Repository :** `https://github.com/RaphHtech/smartmenu`
