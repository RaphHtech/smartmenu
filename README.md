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
- Interface responsive avec AppColors
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

---

## 🛠 Architecture Technique

### Stack Principal

- **Frontend** : Flutter Web (PWA + Admin)
- **Backend** : Firebase (Firestore + Auth + Storage + Hosting)
- **Sécurité** : Rules multi-tenant + mapping users/{uid}

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
/admin → AdminLoginScreen
/admin/signup → AdminSignupScreen
```

---

## 📂 Structure Projet

```
lib/
├── core/
│   └── constants/colors.dart        # Palette AppColors
├── services/
│   ├── cart_service.dart           # Gestion panier
│   └── firebase_menu_service.dart  # Intégration Firestore (client)
├── screens/
│   ├── home_screen.dart            # Accueil (QR / demo)
│   ├── qr_scanner_screen.dart      # Scanner QR multi-restaurants
│   ├── menu/
│   │   └── menu_screen.dart        # Menu client
│   └── admin/
│       ├── admin_login_screen.dart      # Login restaurateur
│       ├── admin_signup_screen.dart     # Signup + onboarding
│       ├── create_restaurant_screen.dart # Création resto + owner
│       ├── admin_dashboard_screen.dart   # Dashboard liste plats
│       ├── admin_restaurant_info_screen.dart # Gestion tagline/promo
│       └── menu_item_form_screen.dart    # CRUD plats + upload images
├── widgets/
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

### 🚧 Phase 2 - Déploiement & Optimisations

- Preview live améliorée (iframe intégré)
- Service Worker avancé : split stratégie client/admin
- Déploiement Firebase Hosting (prod smartmenu.web.app)
- Core Web Vitals + Analytics
- Tests complets en production

### 🔮 Phase 3 - Features Avancées

- V2 : Commandes clients + notifications temps réel
- Analytics dashboard restaurateur
- Multi-langues (Hebrew/English/French)
- Thèmes personnalisables par restaurant
- API REST pour intégrations tiers

---

## 📊 État Technique

**Statut :** MVP fonctionnel, prêt pour déploiement  
**Environnement :** Développement local uniquement  
**Déploiement cible :** `https://smartmenu-mvp.web.app`  
**Dernière mise à jour :** Septembre 2025

### Notes Importantes

- **Bucket Storage** : `smartmenu-mvp.firebasestorage.app` (configuré)
- **Devise par défaut** : ILS (marché israélien)
- **PWA** : Cache différencié client/admin pour UX optimale
- **Upload Web** : `putData(Uint8List)` obligatoire pour compatibilité web

---

## 🎯 Style de Travail & Communication

### Méthodologie Appliquée

- **Demander les fichiers avant modification** : Toujours voir le code actuel
- **Corrections précises** : "Change ligne X par Y" plutôt que réécrire
- **Tests méthodiques** : Valider chaque étape avant passer à la suivante
- **Architecture first** : Éviter l'over-engineering, privilégier simplicité

### Debugging Approach

- Logs explicites avec `print()` pour tracer les problèmes
- Terminal outputs analysés systématiquement
- Storage/Firestore Rules testées via simulateur Firebase

---

## 👥 Crédits

Projet développé par **Raphaël Benitah** avec accompagnement technique collaboratif (Claude + ChatGPT).

---

**Version :** 1.0.0  
**License :** Propriétaire  
**Contact :** rafaelbenitah@gmail.com
