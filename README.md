# SmartMenu App 🍕

Une application de menu numérique moderne pour restaurants, développée avec **Flutter** (mobile & web PWA) et **Firebase**.

---

## 📖 Description

**SmartMenu** est une solution SaaS multi-tenant permettant aux restaurants de digitaliser leurs menus avec un système QR code moderne.

### Architecture

- **Client PWA** (`/r/{restaurantId}`) : Menu accessible via QR code, panier, commande
- **Admin Dashboard** (`/admin`) : Interface restaurateur pour gérer menu, plats, images
- **Multi-tenant** : Chaque restaurant a ses données isolées avec sécurité Firestore

---

## 🚀 État Actuel (Septembre 2025)

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

**Admin Dashboard :**

- Auth Firebase (email/password) avec mapping users/{uid}
- Signup → Create Restaurant → Dashboard complet
- CRUD plats : création, modification, suppression
- Upload images Firebase Storage (avec gestion suppression)
- Options : plat signature, visible/masqué, catégories
- Preview live (ouvre `/r/{rid}` nouvel onglet)
- **NOUVEAU : Interface Premium avec Design System**
- Gestion devises multiples (ILS par défaut)
- Placeholders avec icônes de catégorie (🍕, 🥗, etc.)
- Screen "Infos du restaurant" pour modifier tagline/promo

**Infrastructure :**

- Firestore Rules multi-tenant sécurisées
- Storage Rules avec lecture publique images
- CORS configuré (localhost + production)
- Service Worker différencié (cache client vs network admin)
- Upload web-safe avec putData(Uint8List)

### 🎯 Fonctionnalités Validées

- Upload d'images fonctionne (Storage + Firestore)
- Suppression d'images avec bouton "Retirer"
- Placeholders avec emojis de catégorie côté admin
- Affichage correct des devises selon restaurant
- Preview menu depuis dashboard admin
- **Design System Admin Premium appliqué avec succès**

---

## 🎨 NOUVEAU : Design System Admin Premium

### Architecture Design

```
lib/core/design/
├── admin_tokens.dart      # Couleurs, espacements, radius, ombres
├── admin_typography.dart  # Hiérarchie typographique premium
├── admin_theme.dart       # ThemeData complet Material 3
└── admin_themed.dart      # Wrapper pour appliquer le thème admin

lib/widgets/ui/
└── admin_themed.dart      # Extension navigation + wrapper
```

### Styles Appliqués

- **Palette Premium** : Gris neutres + accent indigo (inspiration Notion/Linear)
- **Typography** : Hiérarchie Display/Headline/Body/Label
- **AppBar** : Blanc avec bordure fine vs rouge avant
- **Cards** : Bordures fines, coins arrondis, élévation subtile
- **Inputs** : Focus states modernes, padding harmonieux
- **Buttons** : Style indigo premium avec hover effects
- **Background** : Gris très clair (neutral50) vs rose avant

### Navigation Admin Wrappée

Tous les écrans admin utilisent désormais `AdminThemed` wrapper :

- Via routes directes (`/admin`, `/admin/signup`)
- Via navigation interne (`context.pushAdminScreen()`)
- Isolation parfaite : le client PWA garde sa palette originale
- Hot restart requis après migration pour voir le thème sur la 1re route admin

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
/admin → AdminLoginScreen (avec AdminThemed)
/admin/signup → AdminSignupScreen (avec AdminThemed)
```

---

## 📂 Structure Projet

```
lib/
├── core/
│   ├── constants/colors.dart        # Palette client (PWA)
│   └── design/                      # 🆕 Design System Admin
│       ├── admin_tokens.dart
│       ├── admin_typography.dart
│       └── admin_theme.dart
├── services/
│   ├── cart_service.dart           # Gestion panier
│   └── firebase_menu_service.dart  # Intégration Firestore (client)
├── screens/
│   ├── home_screen.dart            # Accueil (QR / demo)
│   ├── qr_scanner_screen.dart      # Scanner QR multi-restaurants
│   ├── menu/
│   │   └── menu_screen.dart        # Menu client
│   └── admin/                      # 🆕 Tous wrappés avec AdminThemed
│       ├── admin_login_screen.dart      # Login restaurateur
│       ├── admin_signup_screen.dart     # Signup + onboarding
│       ├── create_restaurant_screen.dart # Création resto + owner
│       ├── admin_dashboard_screen.dart   # Dashboard liste plats
│       ├── admin_restaurant_info_screen.dart # Gestion tagline/promo
│       └── menu_item_form_screen.dart    # CRUD plats + upload images
├── widgets/
│   ├── ui/                         # 🆕 Composants UI
│   │   └── admin_themed.dart       # Wrapper + navigation admin
│   ├── modals/order_review_modal.dart
│   ├── notifications/custom_notification.dart
│   ├── menu/
│   │   ├── cart_floating_widget.dart
│   │   └── app_header_widget.dart
│   ├── category_pill_widget.dart
│   ├── gradient_text_widget.dart
│   └── menu_item_widget.dart
└── main.dart                       # Init Firebase + routing (AdminThemed)

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

### ✅ Phase 1.5 - Design System Admin (Terminé - Septembre 2025)

- **Design Tokens Premium** : Couleurs neutres, espacements, typographie
- **Thème Material 3** : AppBar, Cards, Buttons, Inputs, etc.
- **Wrapper AdminThemed** : Application isolée du thème admin
- **Navigation Wrappée** : Toutes les routes admin utilisent le design premium
- **Interface transformation** : Passage de basique à niveau Stripe/Notion

### 🚧 Phase 2 - AdminShell & Navigation (En cours)

- **AdminShell Layout** : Sidebar + Topbar professionnelle
- **Navigation Premium** : Dashboard, Menu, Médias, Infos, Paramètres
- **Responsive Design** : Sidebar fixe desktop, drawer mobile
- **Breadcrumbs** : Navigation contextuelle
- **Recherche Globale** : Dans topbar avec filtres

### 🔮 Phase 3 - Composants Premium

- **Liste Plats Améliorée** : Thumbnails carrées, hover effects, skeleton loading
- **États Vides Élégants** : Illustrations, CTAs clairs
- **Modales Cohérentes** : Design system unifié
- **Notifications Premium** : Toast messages avec icônes
- **Formulaires Sectionnés** : Groupes logiques, validation temps réel

### 🔮 Phase 4 - Features Avancées

- **Analytics Dashboard** : Métriques vues menu, plats populaires
- **Preview Live Intégrée** : iframe dans admin au lieu nouvel onglet
- **Export PDF Menu** : Génération automatique format print
- **Notifications Temps Réel** : WebSocket pour commandes
- **Multi-langues** : Hebrew/English/French selon marché
- **Thèmes Client Multiples** : Pizza, Café, Fine Dining, etc.

### 🚀 Phase 5 - Production & Scale

- **Déploiement Firebase Hosting** : `smartmenu-mvp.web.app`
- **Core Web Vitals** : Optimisations performance
- **Analytics Complètes** : Usage patterns, conversion rates
- **API REST** : Intégrations tierces (POS, delivery)
- **Tests E2E** : Couverture complète user journeys

---

## 📊 État Technique

**Statut :** Design System Admin implémenté avec succès, prêt pour AdminShell  
**Environnement :** Développement local + Firebase project configuré  
**Déploiement cible :** `https://smartmenu-mvp.web.app`  
**Dernière mise à jour :** Septembre 2025

### Notes Techniques Importantes

- **Bucket Storage** : `smartmenu-mvp.firebasestorage.app` (configuré)
- **Devise par défaut** : ILS (marché israélien)
- **PWA** : Cache différencié client/admin pour UX optimale
- **Upload Web** : `putData(Uint8List)` obligatoire pour compatibilité web
- **Design Isolation** : Admin premium isolé du client PWA
- **Theme Override** : AdminThemed wrapper priorité sur styles explicites

### Leçons Apprises

- **Wrapper Pattern** : Essentiel pour isoler thèmes dans routing Flutter Web
- **Migration Progressive** : Appliquer design system par étapes évite breaking changes
- **Style Precedence** : Properties explicites écrasent ThemeData, nécessite nettoyage
- **Navigation Extensions** : `context.pushAdminScreen()` simplifie application wrapper

---

## 🎯 Prochaines Étapes Immédiates

### AdminShell Priority (Semaine courante)

1. **Créer AdminShell widget** : Layout sidebar + topbar + content area
2. **Navigation Structure** : Dashboard, Menu, Médias, Infos, Paramètres, Logout
3. **Responsive Breakpoints** : Desktop fixe, mobile drawer
4. **Breadcrumbs Component** : Navigation contextuelle
5. **Intégrer Écrans Existants** : Wrapper dans AdminShell

### Composants Next

1. **ProCard Component** : Remplacer Card basique par version premium
2. **ListRow Component** : Items plats avec thumbnail + actions
3. **EmptyState Component** : États vides avec illustrations
4. **Skeleton Component** : Loading states élégants

---

## 🎨 Style Guidelines Admin

### Palette Couleurs

- **Neutrals** : 50 (background) → 900 (text max contrast)
- **Primary** : Indigo moderne (#6366F1) pour actions
- **States** : Success (vert), Warning (orange), Error (rouge)

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

**Design System Admin** inspiré de Notion, Linear, Stripe Dashboard pour une expérience restaurateur premium.

---

**Version :** 2.0.0 (Design System Admin)  
**License :** Propriétaire  
**Contact :** rafaelbenitah@gmail.com

**Repository :** `https://github.com/RaphHtech/smartmenu`
