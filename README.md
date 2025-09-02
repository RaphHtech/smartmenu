SmartMenu App 🍕

Une application de menu numérique moderne pour restaurants, développée avec Flutter (mobile & web PWA).

Description

SmartMenu est une solution SaaS complète permettant :

Clients : consulter le menu digital d’un restaurant via QR code, composer un panier, et passer commande.

Restaurateurs : gérer leurs menus via un dashboard web sécurisé.

Fonctionnalités
Côté Client (PWA Web)

Navigation par catégories (Pizzas, Entrées, Pâtes, Desserts, Boissons)

Ajout d’articles au panier avec contrôles +/-

Modal de révision avant validation

Notification de commande

QR Code → URL directe (ex : /r/chez-milano)

Offline partiel via Service Worker

Installable comme une vraie app (manifest.json)

Côté Restaurateur (Dashboard Web – en cours)

Authentification Firebase (email / mot de passe)

Création restaurant (onboarding propriétaire)

Gestion CRUD des plats (ajouter / modifier / supprimer)

Upload d’images via Firebase Storage

Prévisualisation live du menu client

Multi-tenant : chaque restaurant gère ses propres données isolées

Architecture technique

Frontend Client : Flutter Web (PWA installable)

Frontend Restaurateur : Flutter Web (dashboard /admin)

Backend : Firebase

Firestore (NoSQL multi-tenant)

Auth (gestion restaurateurs)

Storage (images des plats)

PWA : Service Worker + Manifest + Cache intelligent

Structure projet (simplifiée)
lib/
├── core/constants/colors.dart
├── services/
│ ├── cart_service.dart
│ └── firebase_menu_service.dart
├── screens/
│ ├── home_screen.dart # Accueil (QR / demo)
│ ├── menu/menu_screen.dart # Menu client
│ └── admin/ # Dashboard restaurateur
│ ├── admin_login_screen.dart
│ ├── admin_signup_screen.dart
│ └── admin_dashboard_screen.dart
└── widgets/...
web/
├── index.html
├── manifest.json
└── sw.js # Service Worker

Installation
Prérequis

Flutter SDK ≥3.0

Dart ≥3.0

Firebase CLI configuré

Android Studio / VS Code

Commandes
git clone https://github.com/RaphHtech/smartmenu.git
cd smartmenu_app

flutter pub get
flutter run -d chrome # version web PWA

Déploiement

Web PWA : Firebase Hosting

Mobile : Android / iOS (optionnel phase 2)

Roadmap

App client Flutter (MVP terminé)

Migration PWA Flutter Web avec Service Worker

Routing multi-restaurant /r/{restaurantId}

Dashboard restaurateur /admin

CRUD menus + upload images

Règles Firestore multi-tenant

Déploiement Firebase Hosting (prod)

Status : App Client finalisée ✅ – Dashboard en développement 🚧
Prochaine étape : Auth + CRUD restaurateur
