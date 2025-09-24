# SmartMenu — QR Menu SaaS

![Flutter](https://img.shields.io/badge/Flutter-3.16%2B-blue)
![Firebase](https://img.shields.io/badge/Firebase-Ready-orange)
![PWA](https://img.shields.io/badge/PWA-Ready-success)

Une solution SaaS complète permettant aux restaurants de digitaliser leurs menus avec un système QR code moderne.

## Vue d'ensemble

**SmartMenu** combine une PWA client élégante avec un dashboard admin professionnel pour offrir une expérience restaurant premium.

### Architecture

- **Client PWA** (`/r/{slug}`) — Menu accessible via QR, panier, commandes
- **Admin Dashboard** (`/admin`) — Interface SaaS premium pour gérer menus, médias, branding
- **Multi-tenant** — Données isolées par restaurant avec sécurité Firestore
- **Landing Page** (`/`) — Scanner QR intégré + saisie code restaurant

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

### Système QR Code Complet ✅

- **Scanner QR intégré** avec mobile_scanner et interface moderne
- **Génération QR codes** personnalisables avec preview temps réel
- **URLs propres** : `/r/nom-restaurant` automatiquement générées
- **Résolution intelligente** slug → restaurant ID avec fallbacks
- **Interface admin** pour visualiser, générer et partager les QR codes
- **Support multi-formats** : téléchargement et partage multi-canaux

### URLs Propres et Partage

- Système de slugs automatiques `/r/nom-restaurant`
- Génération automatique à partir du nom du restaurant
- Résolution intelligente slug → ID restaurant
- Interface admin pour visualiser et partager les URLs
- Compatibilité avec les restaurants existants

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
- **Générateur QR intégré** avec personnalisation
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
- **QR** : mobile_scanner v4.0.1 (scan desktop) + qr_flutter (génération)
- **Design** : Material 3 + Design System custom AdminTokens
- **Tests** : Unit tests avec mocks Firestore

## État du projet

**Version** : 2.9.1 — Scanner QR fonctionnel + fixes techniques

### Phase actuelle : QR Code stable ✅

- ✅ Scanner QR fonctionnel (desktop HTTPS, mobile via saisie manuelle)
- ✅ Génération QR codes avec téléchargement PNG
- ✅ URLs propres avec système de slugs automatiques
- ✅ Résolution slug → restaurant ID avec fallbacks
- ✅ Interface admin QR complète
- ✅ Support multi-canaux de partage
- ✅ Fix mobile_scanner v4.0.1 compatible Flutter Web

### Prochaines phases

- **Internationalisation RTL** (hébreu/anglais/français)
- **Système de commandes** avec transmission automatique
- **Gestion d'équipe** (invitations, rôles manager/staff)
- **Analytics avancées** (tendances, plats populaires)

## Support et contact

- **Développeur** : Raphaël Benitah
- **Email** : rafaelbenitah@gmail.com
- **Repository** : [GitHub](https://github.com/RaphHtech/smartmenu)

## License

Propriétaire — Tous droits réservés
