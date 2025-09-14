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

## 🚀 État Actuel (Septembre 2025) - Version 2.5.0 ✅ TERMINÉE

### ✅ Fonctionnalités Terminées

**Client PWA :**

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

**Admin Dashboard - Interface SaaS Premium :**

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

**Landing Page Client :**

- **Interface moderne** : Design premium avec logo gradient
- **Saisie code restaurant** : Input avec validation format (a-z, 0-9, tirets)
- **Navigation optimisée** : pushReplacement vers menu (pas de retour accidentel)
- **Scanner QR Beta** : Affiché conditionnellement sur HTTPS/localhost
- **Validation robuste** : Normalisation, messages d'erreur clairs
- **UX clavier** : textInputAction.go, focus management

**Infrastructure :**

- Firestore Rules multi-tenant sécurisées
- Storage Rules avec lecture publique images
- CORS configuré (localhost + production)
- Service Worker différencié (cache client vs network admin)
- Upload web-safe avec putData(Uint8List)

### 🎯 Nouvelles Fonctionnalités v2.1.0 - AdminShell Premium

- **AdminShell Layout** : Interface SaaS avec sidebar/topbar premium
- **Navigation intelligente** : Retour contextuel (sous-pages → Dashboard)
- **Responsive optimisé** : Recherche adaptive, débordement corrigé
- **Modification nom restaurant** : Interface intuitive avec validation
- **Écrans placeholder** : Médias et Paramètres avec design cohérent

### 🎯 Nouvelles Fonctionnalités v2.2.0 - Filtres & Recherche

- **Filtres et recherche avancés** : Interface complète dans AdminDashboardScreen
- **Recherche en temps réel** : Filtrage instantané par nom/description/catégorie avec support accents
- **Tri dynamique** : Par catégorie/nom/prix avec persistence de l'état
- **Chips de filtrage** : Filtrage par catégorie avec toggle et état "Toutes"
- **Architecture optimisée** : Interface de recherche séparée du StreamBuilder pour performance
- **Responsive design** : Champs de recherche et tri adaptés mobile/desktop

**Interface de filtrage :**

- Champ de recherche avec normalisation des accents
- Menu déroulant tri compact et responsive
- Chips catégories scrollables horizontalement
- Bouton clear avec conservation du focus
- Normalisation des accents pour recherche tolérante

### 🎯 Nouvelles Fonctionnalités v2.3.0 - MediaScreen & Assignation Images

- **AdminMediaScreen complète** : Interface de gestion des médias opérationnelle
- **Upload d'images** : Sélection de fichiers avec validation format/taille (PNG, JPG, WebP - max 5MB)
- **Galerie des médias** : Grille responsive des images uploadées avec métadonnées
- **Gestion avancée** : Suppression avec confirmation, affichage taille fichier et date
- **Feedback utilisateur** : Progress bar d'upload, alertes d'erreur avec dismiss
- **Storage Rules optimisées** : Permissions multi-tenant pour upload/suppression sécurisés
- **🆕 Assignation d'images aux plats** : Depuis MediaScreen vers plats existants

**Interface MediaScreen :**

- Zone d'upload cliquable avec instructions claires
- Bouton "Ajouter" dans topbar pour accès rapide
- Grille 4 colonnes adaptative desktop/mobile
- Cartes médias avec aperçu, nom, taille et actions
- **Bouton "Utiliser"** : Modal de sélection des plats avec recherche
- **Assignation Firestore** : Update automatique image + imageUrl des plats
- Gestion d'erreurs contextuelle (format, taille, permissions)
- Loading states et empty states élégants

### 🎯 Nouvelles Fonctionnalités v2.4.0 - Dashboard Overview & Landing Page

**Dashboard Overview :**

- **Métriques temps réel** : Total plats, catégories, images, signatures
- **Actions rapides** : Ajouter plat, gérer médias, modifier infos, prévisualiser
- **Calculs côté client** : Zero surcoût Firestore, 100% synchro
- **Responsive** : Grille adaptive 4/2 colonnes selon écran
- **États visuels** : Carte warning pour plats sans image

**Landing Page Client :**

- **Design moderne** : Logo gradient, typographie premium
- **Validation robuste** : Regex format, normalisation lowercase
- **Feature flag scanner** : Détection HTTPS/localhost automatique
- **Navigation optimisée** : pushReplacement, pas de retour accidentel
- **UX premium** : États loading, erreurs inline, focus management

---

### 🎯 Nouvelles Fonctionnalités v2.5.0 - Gestion avancée des catégories ✅

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

**Améliorations techniques :**

- **Normalisation tolérante** : Comparaison "pizza" vs "Pizzas" fonctionnelle
- **Sélection intelligente** : Reset automatique si catégorie sélectionnée devient masquée
- **Interface réactive** : Optimistic UI pour fluidité, \_load() pour synchronisation

**Workflow fonctionnel :**

1. Paramètres → Réorganiser catégories par drag & drop
2. Masquer catégories temporaires (ex: menu hivernal)
3. Ajouter nouvelles catégories → Apparition immédiate côté admin/client
4. Admin Menu & Client → Ordre et visibilité synchronisés

---

### 🎯 Nouvelles Fonctionnalités v2.6.0 - Branding & Identité Visuelle ✅ TERMINÉE

**Page Branding dédiée :**

- **Upload logo restaurant** : Gestion Firebase Storage avec validation PNG/JPG, max 2MB
- **Aperçus temps réel** : Prévisualisation Hero (36px) et Sticky (28px) identiques au client
- **Fallback intelligent** : Monogramme auto-généré avec couleur dérivée stable du nom
- **Cache-busting** : Versioning automatique pour mise à jour immédiate côté client
- **Suppression sécurisée** : Nettoyage Storage + Firestore avec gestion d'erreurs

**Interface Header client professionnalisée :**

- **Logo + nom lockup** : Brand lockup professionnel remplaçant le dégradé "cheap"
- **Typographie premium** : Texte blanc net sans effets, ombre subtile pour lisibilité
- **Responsive adaptatif** : Tailles logo/texte différenciées Hero (36px) vs Sticky (28px)
- **Standards UX** : Alignement avec patterns UberEats/DoorDash pour crédibilité marque

**Architecture technique :**

- **HTML5 Upload natif** : API web native évitant dépendances file_picker
- **Storage organisé** : `restaurants/{rid}/branding/logo_*.png` avec versioning
- **Validation robuste** : Format, taille, dimensions avec feedback utilisateur clair
- **RBAC préparé** : Restriction Owner/Admin extensible selon roadmap permissions

**Workflow fonctionnel :**

1. Admin → Branding → Upload logo avec prévisualisation live Hero + Sticky
2. Client header → Affichage automatique logo + nom en brand lockup professionnel
3. Fallback → Monogramme coloré dérivé du nom si pas de logo
4. Versioning → Cache-busting automatique garantit mise à jour immédiate

**Impact UX majeur :** Transformation de l'aspect "amateur" en identité de marque professionnelle alignée standards SaaS modernes (Stripe, Notion, Linear).

---

**Workflow fonctionnel :**

1. Paramètres → Réorganiser catégories par drag & drop
2. Masquer catégories temporaires (ex: menu hivernal)
3. Ajouter nouvelles catégories → Apparition immédiate côté admin/client
4. Admin Menu & Client → Ordre et visibilité synchronisés

**Compatibilité assurée :** Si `categoriesOrder`/`categoriesHidden` absents, comportement alphabétique par défaut.

## 🎨 AdminShell - Interface SaaS Premium

### Architecture AdminShell

```

lib/widgets/ui/
├── admin*shell.dart # Layout principal sidebar + topbar
├── admin_themed.dart # Wrapper thème admin
├── categories_settings_widget.dart # 🆕 gestion des catégories (drag, hide, add)
└── admin*\*.dart # Composants spécialisés

lib/screens/admin/
├── admin_dashboard_overview_screen.dart # Vue d'ensemble + métriques
├── admin_dashboard_screen.dart # Gestion menu (CRUD plats)
├── admin_media_screen.dart # Gestion médias complète
├── admin_settings_screen.dart # Paramètres + nom restaurant
├── admin_restaurant_info_screen.dart # Infos détaillées
└── ... # Autres écrans admin

```

### Navigation AdminShell

**Sidebar (Desktop 1024px+) :**

- **Dashboard** : Vue d'ensemble (métriques + actions rapides)
- **Menu** : Gestion des plats (CRUD, filtres, tri)
- **Médias** : Gestion fichiers complète + assignation
- **Infos resto** : Tagline, promo, devise
- **Paramètres** : Nom restaurant, équipe (futur)

**Topbar responsive :**

- Burger menu (mobile) / Bouton retour contextuel
- Titre de page dynamique
- Actions personnalisées par écran
- Interface épurée (recherche globale supprimée)
- **Recherche par écran** : Recherche au niveau écran (ex. Menu) sans recherche globale AdminShell

**Navigation intelligente :**

- **Dashboard = racine** (pushAndRemoveUntil, pas de retour)
- **Autres pages** → push simple avec retour visible vers Dashboard
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
└── menus/{itemId} (name, price, category, image, imageUrl, signature, visible)

users/{uid}/ (primary_restaurant_id, role, created_at)

```

### Routing Web

```

/ → HomeScreen (landing page + saisie code)
/r/{restaurantId} → MenuScreen (PWA client)
/admin → AdminLoginScreen (avec AdminShell)
/admin/signup → AdminSignupScreen (avec AdminShell)

```

---

## 📂 Structure Projet

```

lib/
├── core/
│ ├── constants/colors.dart # Palette client (PWA)
│ └── design/ # 🆕 Design System Admin
│ ├── admin_tokens.dart # Variables design (couleurs, spacing, etc.)
│ ├── admin_typography.dart # Hiérarchie typographique
│ └── admin_theme.dart # ThemeData Material 3
├── services/
│ ├── cart_service.dart # Gestion panier
│ └── firebase_menu_service.dart # Intégration Firestore (client)
├── screens/
│ ├── home_screen.dart # Landing page avec saisie code
│ ├── qr_scanner_screen.dart # Scanner QR multi-restaurants (futur)
│ ├── menu/
│ │ └── menu_screen.dart # Menu client
│ └── admin/ # 🆕 Interface AdminShell
│ ├── admin_login_screen.dart # Login restaurateur
│ ├── admin_signup_screen.dart # Signup + onboarding
│ ├── create_restaurant_screen.dart # Création resto + owner
│ ├── admin_dashboard_overview_screen.dart # Dashboard métriques
│ ├── admin_dashboard_screen.dart # Gestion menu (CRUD)
│ ├── admin_media_screen.dart # Gestion médias complète
│ ├── admin_settings_screen.dart # Paramètres + nom restaurant
│ ├── admin_restaurant_info_screen.dart # Gestion tagline/promo
│ ├── admin_branding_screen.dart # 🆕 Gestion identité visuelle complète
│ └── menu_item_form_screen.dart # CRUD plats + upload images
├── widgets/
│ ├── ui/ # 🆕 Composants AdminShell
│ │ ├── admin_shell.dart # Layout principal sidebar/topbar
│ │ └── admin_themed.dart # Wrapper + navigation admin
│ ├── modals/order_review_modal.dart
│ ├── notifications/custom_notification.dart
│ ├── menu/
│ │ ├── cart_floating_widget.dart
│ │ └── app_header_widget.dart
│ ├── category_pill_widget.dart
│ ├── gradient_text_widget.dart
│ └── menu_item_widget.dart
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
    "origin": ["*"],
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
gsutil cors set cors.json gs://smartmenu-mvp.appspot.com
```

### Développement

```bash
flutter run -d chrome  # Mode dev
flutter build web      # Build production
```

### Tests manuels

- **Landing** : `/` → saisir code restaurant (ex: `newtest`) → navigation vers menu
- **Client** : `/r/{restaurantId}` → navigation menu avec preview admin
- **Admin** :
  1. `/admin/signup` → créer compte + restaurant
  2. `/admin` → login puis redirection Dashboard Overview
  3. Dashboard → métriques + actions rapides fonctionnelles
  4. Menu → CRUD plats avec recherche/filtres
  5. Médias → upload images + assignation aux plats
  6. Preview → `/r/{rid}` avec retour admin
  7. Paramètres → modifier nom restaurant
  8. **Preview admin** : `/r/{rid}?admin=true` → bouton retour admin visible et fonctionnel
  9. **Navigation landing** : Depuis `/` vers menu → bouton back ne retourne PAS à l'accueil

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

### ✅ Phase 3 - Consolidation Features (Terminé - v2.4.0)

- **Recherche et filtres** : Interface complète avec tri par catégorie/nom/prix
- **MediaScreen opérationnelle** : Upload, gestion et assignation d'images
- **Assignation Media → Plats** : Modal de sélection avec recherche
- **Dashboard Overview** : Métriques temps réel + actions rapides
- **Landing Page Client** : Saisie code + feature flag scanner
- **Preview admin** : Navigation aller-retour seamless client ↔ admin
- **Interface épurée** : Suppression recherche globale inutile

### 🔮 Phase 4 - Features Avancées

- **Scanner QR fonctionnel** : Implémentation mobile_scanner
- **Gestion équipe** : Invitations, rôles (manager, staff)
- **Analytics avancées** : Tendances, plats populaires
- **Export PDF Menu** : Génération automatique format print
- **Notifications Temps Réel** : WebSocket pour commandes
- **Multi-langues** : Hebrew/English/French selon marché

### 🔮 Phase 5 - Composants Premium

- **Liste Plats Améliorée** : Thumbnails carrées, hover effects, skeleton loading
- **États Vides Élégants** : Illustrations, CTAs clairs
- **Modales Cohérentes** : Design system unifié
- **Notifications Premium** : Toast messages avec icônes
- **Formulaires Sectionnés** : Groupes logiques, validation temps réel

### 🚀 Phase 6 - Production & Scale

- **Déploiement Firebase Hosting** : `smartmenu-mvp.web.app`
- **Core Web Vitals** : Optimisations performance
- **Analytics Complètes** : Usage patterns, conversion rates
- **API REST** : Intégrations tierces (POS, delivery)
- **Tests E2E** : Couverture complète user journeys

---

## 📊 État Technique

**Statut :** Phase 4 en cours - Fonctionnalités avancées  
**Version :** 2.6.0 (Branding & Identité visuelle)
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
- **Performance** : Filtrage en mémoire sur snapshot existant pour réactivité
- **Normalisation accents** : Fonction `_normalize()` pour recherche tolérante (français/hébreu)
- **MediaScreen opérationnelle** : Upload/suppression Firebase Storage avec validation complète
- **Storage Rules multi-tenant** : Permissions basées sur membership restaurant pour sécurité
- **Assignation images** : Modal de sélection plats avec recherche locale et update Firestore dual (image + imageUrl)
- **Dashboard métriques** : Calculs côté client temps réel, zero surcoût Firestore
- **Landing page robuste** : Validation regex, feature flag scanner, navigation optimisée
- **Routing dynamique** : onGenerateRoute pour `/r/{code}` avec navigation interne

### Leçons Apprises

- **AdminShell Pattern** : Layout centralisé évite duplication code et assure cohérence
- **Navigation intelligente** : Différencier pages racines vs sous-pages critique pour UX
- **Responsive Design** : Champ recherche adaptatif évite débordements
- **Design System** : Tokens centralisés facilitent maintenance et évolutions
- **Validation formulaires** : Feedback temps réel améliore satisfaction utilisateur
- **Focus management** : TextField dans StreamBuilder cause perte de focus systématique
- **Architecture reactive** : Séparer UI stable (filtres) de UI dynamique (liste) crucial pour UX
- **Performance filtering** : Filtrage en mémoire plus rapide que requêtes Firestore multiples
- **Firebase Storage Rules** : Délai de propagation (1-2 min) critique pour tests fonctionnels
- **File upload UX** : Progress bar et gestion d'erreurs essentiels pour feedback utilisateur
- **Storage permissions** : Vérification membership restaurant plus sécurisée que auth simple
- **Media workflow** : Assignation image → plat depuis galerie améliore significativement UX gestion contenu
- **Dashboard insights** : Métriques temps réel côté client plus réactives que compteurs backend
- **Landing page MVP** : Feature flag + validation robuste meilleur que sur-engineering
- **Navigation routing** : onGenerateRoute nécessaire pour navigation interne dynamique

---

## 🎯 Prochaines Étapes Recommandées

### Phase 4 Priority (Optionnel)

1. **Scanner QR fonctionnel** : Implémentation mobile_scanner pour compléter landing page
2. **Analytics Dashboard** : Métriques avancées avec tendances temporelles
3. **Gestion équipe basique** : Invitations collaborateurs avec rôles

### Production Ready

1. **Déploiement Firebase Hosting** : Configuration environnement production
2. **Performance audit** : Core Web Vitals et optimisations
3. **Tests E2E** : Couverture complète user journeys

### Déploiement production

- `flutter build web` puis `firebase deploy --only hosting`
- Vérifier **Authorized domains** (inclure le domaine prod)
- Repasser CORS si le bucket change d'environnement

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

**Version :** 2.4.0 (MVP complet - Dashboard Overview + Landing Page)  
**License :** Propriétaire  
**Contact :** rafaelbenitah@gmail.com

**Repository :** `https://github.com/RaphHtech/smartmenu`
