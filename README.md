# SmartMenu — QR Menu SaaS

![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-blue)
![Firebase](https://img.shields.io/badge/Firebase-Ready-orange)
![PWA](https://img.shields.io/badge/PWA-Ready-success)

Une solution SaaS complète permettant aux restaurants de digitaliser leurs menus avec un système QR code moderne.

## Vue d'ensemble

**SmartMenu** combine une PWA client élégante avec un dashboard admin professionnel pour offrir une expérience restaurant premium.

### Architecture

- **Client PWA** (`/r/{restaurantId}`) — Menu accessible via QR, panier, commandes
- **Admin Dashboard** (`/admin`) — Interface SaaS premium pour gérer menus, médias, branding
- **Multi-tenant** — Données isolées par restaurant avec sécurité Firestore
- **Landing Page** (`/`) — Saisie code restaurant avec validation

## Démarrage rapide

### Prérequis

- Flutter 3.16+ avec support web
- Firebase CLI
- Git

### Installation

```bash
git clone https://github.com/RaphHtech/smartmenu.git
cd smartmenu
flutter config --enable-web
flutter pub get
```

### Configuration Firebase

1. **Installer Firebase CLI et FlutterFire**

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

2. **Configurer les services Firebase**

   - Auth : Activer Email/Password
   - Firestore : Activer et appliquer les règles de sécurité
   - Storage : Activer et configurer CORS (voir `docs/DEPLOYMENT.md`)

3. **Domaines autorisés** : `localhost`, `127.0.0.1`, votre domaine de production

### Lancement développement

```bash
flutter run -d chrome
```

## Fonctionnalités principales

### Interface Client (PWA)

- Navigation par catégories avec design glassmorphism
- Panier interactif avec contrôles +/-
- Modal de révision avant commande
- Notifications personnalisées
- Support multi-devises (₪, €, $)
- Mode offline partiel

### Admin Dashboard Premium

- Interface SaaS inspirée Stripe/Notion/Linear
- CRUD complet des plats avec upload d'images
- Gestion catégories unifiée (même éditeur depuis Menu et Paramètres)
- Réorganisation drag & drop avec sauvegarde temps réel
- Branding personnalisé (logo, couleurs)
- Analytics de base (compteurs, métriques)
- Responsive design desktop/mobile

## Documentation technique

- **[Architecture](docs/ARCHITECTURE.md)** — Design système et services
- **[Développement](docs/DEVELOPMENT.md)** — Guide setup et conventions
- **[API & Services](docs/API.md)** — Contrats et modèles de données
- **[Déploiement](docs/DEPLOYMENT.md)** — Firebase Hosting et production

## Stack technique

- **Frontend** : Flutter Web (PWA + Admin)
- **Backend** : Firebase (Firestore + Auth + Storage)
- **Design** : Material 3 + Design System custom
- **Tests** : Unit tests avec mocks Firestore

## État du projet

**Version** : 2.7.1 — Auth mobile responsive corrigé  
**Tests** : Repository catégories complets (9/9 passing)  
**Code quality** : 8 issues mineurs (flutter analyze)

### Phase actuelle : Auth mobile perfectionné ✅

- ✅ Architecture catégories unifiée (`CategoryManager`)
- ✅ Design system premium (`AdminTokens`) avec responsive utilities
- ✅ Auth screens mobile pixel-perfect (overflow fixes)
- ✅ Interface mobile optimisée
- ✅ Tests unitaires avec mocks Firestore
- ✅ Documentation structurée

### Prochaines phases

- **QR Scanner fonctionnel** avec mobile_scanner
- **Gestion d'équipe** (invitations, rôles manager/staff)
- **Analytics avancées** (tendances, plats populaires)
- **Export PDF** des menus pour impression

## Support et contact

- **Développeur** : Raphaël Benitah
- **Email** : rafaelbenitah@gmail.com
- **Repository** : [GitHub](https://github.com/RaphHtech/smartmenu)

## License

Propriétaire — Tous droits réservés
