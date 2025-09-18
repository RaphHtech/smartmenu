# SmartMenu App 🍕

Une application de menu numérique moderne pour restaurants, développée avec **Flutter** (mobile & web PWA) et **Firebase**.

---

## 📖 Description

**SmartMenu** est une solution SaaS multi-tenant permettant aux restaurants de digitaliser leurs menus avec un système QR code moderne.

### Architecture

- **Client PWA** (`/r/{restaurantId}`) : Menu accessible via QR code, panier, commande
- **Admin Dashboard** (`/admin`) : Interface restaurateur SaaS premium pour gérer menu, plats, images
- **Multi-tenant** : Chaque restaurant a ses données isolées avec sécurité Firestore
- **Landing Page** (`/`) : Page d'accueil avec saisie code restaurant

---

## 🚀 État Actuel (Septembre 2025) — Version 2.6.1 ✅

### 📌 Évolution

- v2.4.0 — Dashboard Overview + Landing Page
- v2.5.0 — Gestion avancée catégories
- v2.6.0 — Branding professionnel (logo + fallback intelligent)
- v2.6.1 — Rollback stabilisation + optimisations performance

---

## ✅ Fonctionnalités Terminées

### Client PWA

- Navigation par catégories dynamiques (Pizzas, Entrées, Pâtes, Desserts, Boissons)
- Ajout au panier avec contrôles +/-
- Modal de révision avant validation
- Notifications (confirmation commande)
- QR Code → URL directe (ex: `/r/newtest`)
- **Preview admin** : Bouton retour conditionnel vers interface admin
- Offline partiel via Service Worker (cache-first)
- Manifest PWA (installable comme app)
- Nom restaurant dynamique depuis Firestore
- Devise dynamique (₪, €, $) selon restaurant
- Tagline et bandeau promo personnalisables

**Landing (client) :**

- **Interface moderne** : Design premium avec logo gradient
- **Saisie code restaurant** : Input avec validation format (a-z, 0-9, tirets)
- **Navigation optimisée** : pushReplacement vers menu (pas de retour accidentel)
- **Scanner QR Beta** : Affiché conditionnellement sur HTTPS/localhost
- **Validation robuste** : Normalisation, messages d'erreur clairs
- **UX clavier** : textInputAction.go, focus management
  **URLs de test**
- Client : `/r/{restaurantId}?t=12` (aujourd'hui `{restaurantId}` = ID Firestore)
- Admin : `/admin`
  > Le support `slug` reviendra plus tard. En attendant, utiliser l'ID exact du doc restaurant.

### Admin Dashboard - Interface SaaS Premium

- **AdminShell** : Sidebar/Topbar professionnelle (inspiration Stripe/Notion/Linear)
- **Navigation complète** : Dashboard, Menu, Médias, Infos resto, Paramètres
- **Dashboard Overview** : Métriques temps réel + actions rapides
- **Responsive design** : Sidebar fixe desktop, drawer mobile
- **Breadcrumbs** : Navigation contextuelle avec retour intelligent
- **Design System Premium** : Palette neutre + accent indigo, typographie hiérarchisée
- Auth Firebase (email/password) avec mapping users/{uid}
- Signup → Create Restaurant → Dashboard complet
- CRUD plats : création, modification, suppression
- Upload images Firebase Storage (avec gestion suppression)
- Options : plat signature, visible/masqué, catégories
- **Preview live** : Ouvre `/r/{rid}` avec bouton retour admin
- **Modification nom restaurant** : Interface dédiée dans Paramètres
- Gestion devises multiples (ILS par défaut)
- Placeholders avec icônes de catégorie (🍕, 🥗, etc.)
- Screen "Infos du restaurant" pour modifier tagline/promo
- **Filtres et recherche avancés** : Interface complète avec tri dynamique
- **MediaScreen complète** : Upload, gestion et assignation d'images aux plats
- **Gestion catégories** : Réorganisation drag & drop, masquage/affichage, création
- **Branding** : Upload logo restaurant avec fallback monogramme intelligent
- **Stabilisation post-rollback** : Retour aux fonctionnalités core stables
- **Optimisations requêtes** : Suppression des index complexes problématiques
- **Architecture simplifiée** : Menu client et admin avec base de données unifiée
- **Gestion d'erreurs robuste** : Fallback de catégories, règles Firestore optimisées

### Infrastructure

- Firestore Rules multi-tenant sécurisées
- Storage Rules avec lecture publique images
- CORS restreint (dev/staging/prod)
- Service Worker différencié (cache client vs network admin)
- Upload web-safe avec putData(Uint8List)
- Analytics Firebase: `menu_open` (avec `tableId`) et `add_to_cart` (item + `tableId`)

**Compatibilité assurée :** Si `categoriesOrder`/`categoriesHidden` absents, comportement alphabétique par défaut.

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
├── info/details (name, currency, tagline, promo_text, categoriesOrder, categoriesHidden)
├── members/{uid} (role, invited_at)
└── menus/{itemId} (name, price, category, imageUrl, signature, visible)
```

### Routing Web

```
/ → HomeScreen (landing page + saisie code)
/r/{restaurantId} → MenuScreen (PWA client)
/admin → AdminLoginScreen (avec AdminShell)
/admin/signup → AdminSignupScreen (avec AdminShell)
```

### 🔐 Rôles et permissions (RBAC)

| Ressource              | Owner | Manager | Staff |
| ---------------------- | ----- | ------- | ----- |
| info (name, branding…) | CRUD  | R       | R     |
| menus                  | CRUD  | CRUD    | R     |
| media (photos)         | CRUD  | CRUD    | R     |
| members                | CRUD  | R       | —     |

⚠️ Les menus et images sont publics en lecture uniquement (aucune donnée sensible).

---

## 📂 Structure Projet

```
lib/
├── core/
│   ├── constants/colors.dart # Palette client (PWA)
│   └── design/ # 🆕 Design System Admin
│       ├── admin_tokens.dart # Variables design (couleurs, spacing, etc.)
│       ├── admin_typography.dart # Hiérarchie typographique
│       └── admin_theme.dart # ThemeData Material 3
├── services/
│   ├── cart_service.dart # Gestion panier
│   └── firebase_menu_service.dart # Intégration Firestore (client)
├── screens/
│   ├── home_screen.dart # Landing page avec saisie code
│   ├── qr_scanner_screen.dart # Scanner QR multi-restaurants (futur)
│   ├── menu/
│   │   └── menu_screen.dart # Menu client
│   └── admin/ # 🆕 Interface AdminShell
│       ├── admin_login_screen.dart # Login restaurateur
│       ├── admin_signup_screen.dart # Signup + onboarding
│       ├── create_restaurant_screen.dart # Création resto + owner
│       ├── admin_dashboard_overview_screen.dart # Dashboard métriques
│       ├── admin_dashboard_screen.dart # Gestion menu (CRUD)
│       ├── admin_media_screen.dart # Gestion médias complète
│       ├── admin_settings_screen.dart # Paramètres + nom restaurant
│       ├── admin_restaurant_info_screen.dart # Gestion tagline/promo
│       ├── admin_branding_screen.dart # Gestion identité visuelle complète
│       └── menu_item_form_screen.dart # CRUD plats + upload images
├── widgets/
│   ├── ui/ # 🆕 Composants AdminShell
│   │   ├── admin_shell.dart # Layout principal sidebar/topbar
│   │   ├── admin_themed.dart # Wrapper + navigation admin
│   │   └── categories_settings_widget.dart # Gestion des catégories
│   ├── modals/order_review_modal.dart
│   ├── notifications/custom_notification.dart
│   ├── menu/
│   │   ├── cart_floating_widget.dart
│   │   └── app_header_widget.dart
│   ├── category_pill_widget.dart
│   ├── gradient_text_widget.dart
│   └── menu_item_widget.dart
└── main.dart # Init Firebase + routing

web/
├── index.html # Entrypoint Web (Flutter loader)
├── manifest.json # PWA manifest
├── sw.js # Service Worker (cache client/admin)
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
    "origin": [
      "http://localhost:5000",
      "http://127.0.0.1:5000",
      "https://smartmenu-stg.web.app",
      "https://smartmenu.web.app"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
  }
]' > cors.json

# Appliquer CORS :
gcloud auth login
gcloud config set project smartmenu-mvp
# Vérifiez le bucket par défaut :
firebase storage:bucket
# Puis appliquez le CORS sur le bucket retourné, ex. :
gsutil cors set cors.json gs://smartmenu-mvp.firebasestorage.app
```

**Notes importantes :**

- Vérifier le bucket exact avec la commande puis appliquer CORS sur celui-ci (dans notre cas `gs://smartmenu-mvp.firebasestorage.app`)
- Après modification CORS: DevTools → Application → Unregister Service Worker → Empty cache and hard reload.

### Développement

```bash
flutter run -d chrome  # Mode dev
flutter build web      # Build production
```

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
        allow update, delete: if isOwner(rid);
      }

      // Menus
      match /menus/{itemId} {
        allow list, get: if resource.data.visible == true;
        allow create, update, delete: if isMember(rid);
      }

      // Membres
      match /members/{uid} {
        allow read: if request.auth != null && request.auth.uid == uid;
        allow update, delete: if isMember(rid) && request.auth.uid == uid;
        allow create: if isOwner(rid); // owner peut ajouter des membres
      }
    }

    // Helpers functions
    function isMember(rid) {
      return request.auth != null &&
             exists(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid));
    }

    function isOwner(rid) {
      return request.auth != null &&
             exists(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid)) &&
             get(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid)).data.role == "owner";
    }
  }
}
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurants/{rid}/menu/{file=**} {
      allow read: if true;
      allow write: if isMember(rid);
    }

    match /restaurants/{rid}/branding/{file=**} {
      allow read: if true;
      allow write: if isOwner(rid);
    }

    match /restaurants/{rid}/media/{file=**} {
      allow read: if true;
      allow write: if isMember(rid);
    }
  }
}
```

---

## Changelog

### v2.6.2 - Corrections Interface Mobile (Septembre 2025)

**Corrections UI responsive majeures :**

- **Dashboard mobile** : Boutons "Actions rapides" redesignés avec layout Column/Row adaptatif
- **Catégories admin** : Résolution problème affichage vertical ("P-i-z-z-a-s" → "Pizzas")
- **Design moderne** : Badges de statut, avatars catégories, ombres subtiles
- **Layout responsive** : Utilisation de `Wrap` et `LayoutBuilder` pour éviter les overflows iPhone SE
- **CORS développement** : Configuration `origin: ["*"]` pour ports Flutter aléatoires

**Architecture technique :**

- **Widgets responsifs** : `ConstrainedBox` + `Wrap` pour actions adaptatives
- **Gestion overflows** : `softWrap: false` + `maxLines: 1` + `TextOverflow.ellipsis`
- **Touch targets** : Boutons 36-40px minimum pour accessibilité mobile
- **Design cohérent** : Palette indigo/success/warning avec Material 3

### v2.6.1 — Rollback & Stabilisation

**Corrections architecturales majeures :**

- **Retour menu fonctionnel** : Suppression système de réorganisation complexe
- **Requêtes simplifiées** : Firestore sans index problématiques
- **CORS Firebase Storage** : Configuration correcte pour images
- **Règles Firestore** : Lecture publique menus pour clients anonymes
- **Code nettoyé** : Suppression variables inutilisées et logs debug

**Notes d'exploitation**

- Client: requêtes `.where('visible', true)` (alignées sur les Rules)
- CORS: configuré sur le bucket `…appspot.com` + hard-reload SW après changement
- Images: conserver l'URL brute `getDownloadURL()`; cache-bust côté UI en `?v=`/`&v=`
- URLs: `/r/{restaurantId}?t=12` (ID Firestore; slug repoussé)

### v2.6.0 — Branding professionnel

**Page Branding dédiée :**

- **Upload logo restaurant** : Gestion Firebase Storage avec validation PNG/JPG, max 2MB
- **Aperçus temps réel** : Prévisualisation Hero (36px) et Sticky (28px)
- **Fallback intelligent** : Monogramme auto-généré avec couleur dérivée stable du nom
- **Cache-busting** : Versioning automatique pour mise à jour immédiate côté client
- **Suppression sécurisée** : Nettoyage Storage + Firestore avec gestion d'erreurs

**Interface Header client professionnalisée :**

- **Logo + nom lockup** : Brand lockup professionnel
- **Typographie premium** : Texte blanc net sans effets, ombre subtile pour lisibilité
- **Responsive adaptatif** : Tailles logo/texte différenciées Hero (36px) vs Sticky (28px)

**Architecture technique :**

- **HTML5 Upload natif** : API web native évitant dépendances file_picker
- **Storage organisé** : `restaurants/{rid}/branding/logo_*.png` avec versioning
- **Validation robuste** : Format, taille, dimensions avec feedback utilisateur clair

### v2.5.0 — Gestion avancée des catégories

**Contrôle restaurateur (Paramètres) :**

- **Réorganisation par drag & drop** : ReorderableListView pour l'ordre personnalisé
- **Masquage/Affichage dynamique** : Switch par catégorie avec persistance
- **Création de nouvelles catégories** : Input avec validation case-insensitive et TitleCase
- **Suppression sécurisée** : Vérification des plats existants, proposition de masquage
- **Gestion d'erreurs robuste** : Optimistic UI + rollback en cas d'échec

**Application côté Client & Admin :**

- **Ordre personnalisé appliqué** : Barre de catégories et tri des plats respectent les paramètres
- **Masquage effectif** : Catégories masquées n'apparaissent plus dans l'interface
- **Synchronisation temps réel** : Listener Firestore pour mise à jour immédiate
- **Catégories vides visibles** : Nouvelles catégories apparaissent même sans plats

### v2.4.0 — Dashboard Overview & Landing Page

**Dashboard Overview :**

- **Métriques temps réel** : Total plats, catégories, images, signatures
- **Actions rapides** : Ajouter plat, gérer médias, modifier infos, prévisualiser
- **Responsive** : Grille adaptive 4/2 colonnes selon écran
- **États visuels** : Carte warning pour plats sans image

### v2.3.0 — MediaScreen & assignation d'images

- **AdminMediaScreen complète** : Interface de gestion des médias opérationnelle
- **Upload d'images** : Sélection de fichiers avec validation format/taille (PNG, JPG, WebP - max 5MB)
- **Galerie des médias** : Grille responsive des images uploadées avec métadonnées
- **Gestion avancée** : Suppression avec confirmation, affichage taille fichier et date
- **Assignation d'images aux plats** : Depuis MediaScreen vers plats existants

### v2.2.0 — Filtres & Recherche

- **Filtres et recherche avancés** : Interface complète dans AdminDashboardScreen
- **Recherche en temps réel** : Filtrage instantané par nom/description/catégorie avec support accents
- **Tri dynamique** : Par catégorie/nom/prix avec persistence de l'état
- **Chips de filtrage** : Filtrage par catégorie avec toggle et état "Toutes"
- **Architecture optimisée** : Interface de recherche séparée du StreamBuilder pour performance

### v2.1.0 — AdminShell Premium

- **AdminShell Layout** : Interface SaaS avec sidebar/topbar premium
- **Navigation intelligente** : Retour contextuel (sous-pages → Dashboard)
- **Responsive optimisé** : Recherche adaptive, débordement corrigé
- **Modification nom restaurant** : Interface intuitive avec validation
- **Écrans placeholder** : Médias et Paramètres avec design cohérent

---

## 📋 Roadmap

### 🔮 Phase 4 - Features Avancées

- **Scanner QR fonctionnel** : Implémentation mobile_scanner
- **Gestion équipe** : Invitations, rôles (manager, staff)
- **Analytics avancées** : Tendances, plats populaires
- **Export PDF Menu** : Génération automatique format print
- **Notifications Temps Réel** : WebSocket pour commandes
- **Multi-langues** : Hebrew/English/French selon marché

### 🚀 Phase 5 - Production & Scale

- **Déploiement Firebase Hosting** : `smartmenu-mvp.web.app`
- **Core Web Vitals** : Optimisations performance
- **Analytics Complètes** : Usage patterns, conversion rates
- **API REST** : Intégrations tierces (POS, delivery)
- **Tests E2E** : Couverture complète user journeys

---

## 📊 État Technique

**Statut :** Post-rollback - Base stable reconstituée
**Version :** 2.6.1 (Rollback + stabilisation)  
**Environnement :** Développement local + Firebase project configuré  
**Déploiement cible :** `https://smartmenu-mvp.web.app`  
**Dernière mise à jour :** Septembre 2025 - Rollback réussi

### Notes Techniques Importantes

- **Bucket Storage** : `smartmenu-mvp.firebasestorage.app` (configuré)
- **Devise par défaut** : ILS (marché israélien)
- **PWA** : Cache différencié client/admin pour UX optimale
- **Upload Web** : `putData(Uint8List)` obligatoire pour compatibilité web
- **Design Isolation** : Admin premium isolé du client PWA
- **Navigation** : `pushAndRemoveUntil` pour pages racines, retour contextuel

---

## 🛠 Troubleshooting

- **Propagation des Rules** : attendre 1—2 min après publication
- **403 Storage** : vérifier auth + rules + membership restaurant
- **Erreur CORS** : vérifier le domaine autorisé dans gsutil cors
- **Cache PWA** : vider le cache navigateur pour voir les derniers logos
- **Logo non affiché** : vérifier `logoVersion` et cache-busting `?v=`
- **Images cassées** : conserver l'URL `getDownloadURL()` telle quelle en base avec `?alt=media&token=...`
- **Cache-bust images** : ajouter `&v=123` si URL contient déjà `?`, sinon `?v=123`
- **Fallback UI** : utiliser `errorBuilder` sur `Image.network` pour éviter les cartes cassées
- **Interface mobile cassée** : Vérifier utilisation `Expanded` et `Wrap` au lieu de `Row` fixe
- **Catégories verticales** : Forcer `softWrap: false` + `letterSpacing: 0`
- **Overflows mobiles** : Remplacer `childAspectRatio` par `mainAxisExtent` dans GridView

---

## 💥 Crédits

Projet développé par **Raphaël Benitah** avec accompagnement technique collaboratif (Claude + ChatGPT).

**AdminShell & Design System** inspirés de Stripe Dashboard, Notion, Linear pour une expérience restaurateur premium.

---

**Version :** 2.6.2 (Interface mobile responsive)
**License :** Propriétaire  
**Contact :** rafaelbenitah@gmail.com  
**Repository :** `https://github.com/RaphHtech/smartmenu`
