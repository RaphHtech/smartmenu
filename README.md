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

### Système d'Appel Serveur ✅

- **Bouton d'appel intégré** dans l'interface client avec gestion d'état
- **Notifications admin temps réel** : banner avec statuts open/acked/done
- **Cooldown anti-spam** : 45 secondes entre appels par table
- **Interface responsive** : actions mobile (empilées) vs desktop (côte à côte)
- **Sons d'alerte différenciés** : distincts des notifications commandes
- **Architecture scalable** : collection Firestore avec règles sécurisées
- **Gestion des états** : "Pris en compte" → "Résolu" avec timestamps

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

### Système de Commandes Professionnel ✅

- **Commandes temps réel** avec panier interactif et modal de révision
- **Notifications multi-canal** : son + navigateur + Slack automatique
- **Interface admin complète** : onglets par statut (Reçues → Préparation → Prêtes → Servies)
- **Idempotence robuste** : anti-doublon via hash déterministe
- **Cloud Functions v2** : notifications automatiques restaurant
- **Sécurité Firestore** : rules strictes, validation complète
- **Architecture scalable** : prêt pour Web Push et intégrations POS

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
- **Cloud Functions** : Firebase Functions v2 (notifications Slack)
- **Notifications** : Notifications API + AudioElement (Flutter Web)
- **Currency** : intl ^0.19.0 (formatage multi-locale)
- **State** : InheritedWidget (CurrencyScope injection)

## État du projet

**Version** : 4.0.0 - QR Code System Complete

### Phase 1 : Système QR Complet ✅

- ✅ **Scanner QR fonctionnel** avec mobile_scanner et fallback saisie manuelle
- ✅ **Interface admin génération QR** avec personnalisation et preview temps réel
- ✅ **Téléchargement QR PNG** fonctionnel et scannable
- ✅ **Templates A5 imprimables** bilingues pour tables restaurant
- ✅ **URLs propres** `/r/nom-restaurant` avec résolution automatique
- ✅ **Système bout-en-bout** : admin crée → client scanne → menu accessible

### Phase Actuelle : Internationalisation RTL (J+5-J+8)

- **Architecture i18n** : extraction libellés + flutter_localizations
- **RTL Implementation** : direction complète pour hébreu + formatage ₪ 25
- **Tests multilingues** : HE/EN/FR sans reload

### Prochaines phases

- **Système commandes** temps réel avec notifications admin
- **RBAC complet** (owner/manager/staff)
- **Analytics avancées** (métriques conversion + insights)## Support et contact

- **Développeur** : Raphaël Benitah
- **Email** : rafaelbenitah@gmail.com
- **Repository** : [GitHub](https://github.com/RaphHtech/smartmenu)

## License

Propriétaire — Tous droits réservés
