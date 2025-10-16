# Architecture SmartMenu

Ce document décrit l'architecture technique de SmartMenu, une application SaaS multi-tenant pour restaurants développée avec Flutter Web et Firebase.

## Vue d'ensemble

SmartMenu utilise une architecture en couches avec séparation claire entre l'interface client (PWA) et l'administration (Dashboard), partageant une base de données Firebase commune.

```
┌─────────────────┐    ┌─────────────────┐
│   Client PWA    │    │  Admin Dashboard│
│   (/r/{slug})   │    │    (/admin)     │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          └──────────┬───────────┘
                     │
            ┌────────▼────────┐
            │   Firebase      │
            │ Firestore+Auth+ │
            │    Storage      │
            └─────────────────┘
```

**Schéma d'URL**

- Client PWA : `/r/{slug}` avec option `?t=table12` (identifiant table)
- Admin : `/admin` (auth Firebase)

## Architecture Frontend

### Structure des dossiers

```
lib/
├── core/
│   ├── constants/          # Couleurs client PWA
│   └── design/            # Design System Admin
├── models/                # Modèles de données
├── services/              # Couche d'accès aux données
├── screens/
│   ├── admin/            # Interface d'administration
│   └── menu/             # Interface client
└── widgets/
    ├── ui/               # Composants admin
    └── menu/             # Composants client
```

### Design System Dual

**Client PWA** (`core/constants/colors.dart`)

- Design glassmorphism avec gradients
- Palette chaude et accueillante
- Optimisé pour l'expérience consommateur

**Admin Dashboard** (`core/design/admin_tokens.dart`)

- Design system professionnel inspiré Stripe/Notion
- Palette neutre avec accent indigo
- Variables de design centralisées

```dart
class AdminTokens {
  // Couleurs principales
  static const Color neutral900 = Color(0xFF171717);
  static const Color primary600 = Color(0xFF4F46E5);

  // Espacements
  static const double space24 = 24.0;

  // Composants
  static const double sidebarWidth = 280.0;
}
```

## Services et Gestion des Données

### Architecture des Services

SmartMenu utilise des services statiques avec injection de dépendances pour les tests.

**Dépendance** : `rxdart: ^0.27.7` (voir `pubspec.yaml`)

```dart
class CategoryManager {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  // Injection pour tests
  static void setFirestoreInstance(FirebaseFirestore instance) {
    _db = instance;
  }

  // Streams temps réel
  static Stream<CategoryLiveState> getLiveState(String restaurantId) {
    return CombineLatestStream.combine2(
      getRestaurantInfoStream(restaurantId),
      getCategoryCountsStream(restaurantId),
      (info, counts) => CategoryLiveState(...)
    );
  }
}
```

### Modèles de Données

**CategoryLiveState** - État temps réel des catégories

```dart
class CategoryLiveState {
  final List<String> order;        // Ordre personnalisé
  final Set<String> hidden;        // Catégories masquées
  final Map<String, int> counts;   // Compteurs par catégorie
}
```

### CurrencyService

Service centralisé de formatage monétaire avec support multi-locale.

**Dépendances** : `intl: ^0.20.2`

#### Configuration supportée

```dart
static const _configs = {
  'ILS': CurrencyConfig(code: 'ILS', symbol: '₪', locale: 'he_IL'),
  'EUR': CurrencyConfig(code: 'EUR', symbol: '€', locale: 'fr_FR'),
  'USD': CurrencyConfig(code: 'USD', symbol: '$', locale: 'en_US'),
};
```

#### Usage avec CurrencyScope

```dart
// Injection restaurant-level
CurrencyScope(
  code: restaurant.currency, // 'ILS', 'EUR', 'USD'
  child: MenuScreen(),
)

// Usage dans widgets
Text(context.money(46.0)); // "₪46" ou "46,00 €" ou "$46.00"
```

**Architecture** : CurrencyScope (InheritedWidget) injecte le code currency au niveau restaurant, extension `MoneyX` fournit `context.money()` dans tout l'arbre widget.

### Patterns de Synchronisation

**Optimistic Updates**

- Mise à jour immédiate de l'UI
- Rollback automatique en cas d'erreur réseau
- Feedback visuel des états (saving, saved, error)

**Streams RxDart**

- Combinaison de flux multiples avec `CombineLatestStream`
- Synchronisation temps réel entre interface admin et données
- Gestion automatique des souscriptions

## Architecture Firestore

### Structure Multi-tenant

```
restaurants/{rid}/
├── info/
│   └── details              # Configuration restaurant
│       ├── name: string
│       ├── currency: string
│       ├── categoriesOrder: string[]
│       └── categoriesHidden: string[]
├── members/{uid}            # Équipe restaurant
│   ├── role: "owner"|"manager"|"staff"
│   └── invited_at: timestamp
└── menus/{itemId}          # Plats du menu
    ├── name: string
    ├── price: number
    ├── category: string
    ├── visible: boolean
    └── position: number     # Ordre dans catégorie
```

### Sécurité RBAC

**Règles Firestore actuelles** (exemple minimal MVP - lecture publique)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Configuration ouverte pour PWA clients
    match /restaurants/{rid}/menus/{doc} {
      allow read: if true;
    }
    match /restaurants/{rid}/info/{doc} {
      allow read: if true;
    }

    // Admin protégé (minimal)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Production RBAC** - voir `docs/DEPLOYMENT.md` pour règles strictes

→ Les règles complètes (Firestore + Storage) sont décrites dans **docs/DEPLOYMENT.md** (section RBAC Production).

**Évolution prévue** - RBAC complet

```javascript
// Gestion par rôles
function isMember(rid) {
  return exists(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid));
}

function isOwner(rid) {
  return isMember(rid) &&
         get(...).data.role == "owner";
}
```

## Interface Admin (AdminShell)

### Architecture Composants

**AdminShell** - Layout principal

- Sidebar responsive (desktop) / Drawer (mobile)
- Navigation contextuelle avec breadcrumbs
- Gestion d'état activeRoute
- Authentification Firebase intégrée

```dart
class AdminShell extends StatefulWidget {
  final Widget child;
  final String title;
  final List<String> breadcrumbs;
  final String? activeRoute;

  // Navigation intelligente
  void _onNavItemTap(String route) {
    if (route == '/dashboard') {
      // Reset navigation stack
      Navigator.pushAndRemoveUntil(...);
    } else {
      // Push simple avec retour
      Navigator.push(...);
    }
  }
}
```

### Design Patterns UI

**Responsive Design**

- Breakpoints : 1024px (desktop), 768px (tablet/mobile cutoff)
- Sidebar fixe desktop, drawer mobile (≤768px)
- Adaptation automatique des composants

**Navigation Contextuelle**

- Dashboard = racine (reset stack)
- Autres pages = push avec retour visible
- Breadcrumbs automatiques

## Gestion des Catégories

### Architecture Unifiée

**CategoryManagerSheet** - Interface unique

- Dialog desktop (720px max) / BottomSheet mobile (90% hauteur)
- Réorganisation drag & drop avec ReorderableListView
- Actions : toggle visibilité, renommer, supprimer
- Sauvegarde optimiste avec auto-save

### Points d'Accès Multiples

**Interface Unifiée**
| Point d'accès | Contexte | Interface |
|---------------|----------|-----------|
| Menu Dashboard | Gestion pendant édition plats | `CategoryManagerSheet.show()` |
| Paramètres | Configuration globale restaurant | Même `CategoryManagerSheet.show()` |

**Avantage** : Cohérence UX garantie - même logique, même interface dans les deux contextes.

**Séquence Renommer Catégorie**

```
UI → startRename() → TextField → confirmRename()
  → Dialog confirmation → batchUpdate Firestore
  → Stream refresh → UI sync
```

### Algorithmes Techniques

**Positionnement Fractionnel**

```dart
// Évite conflits lors réorganisation massive
position = (previousPosition + nextPosition) / 2

// Invariants : positions strictement croissantes
// Renormalisation périodique pour éviter précision flottante
```

**Optimisations Firestore**

- Delta writes : seuls les changements sont sauvegardés
- Chunking : batches limitées à 500 opérations
- Dirty tracking : suivi précis des modifications

## Système de Commandes

### Architecture Multi-Canal

SmartMenu implémente une approche hybride inspirée des grandes plateformes :

```
Client Commande → Firestore → Cloud Function → Slack
                      ↓
                 Admin UI ← Notifications (Son + Bureau)
```

### Modèles de Données Orders

**Order** - Commande restaurant complète

```dart
class Order {
  final String oid;           // Hash idempotent
  final String rid;           // Restaurant ID
  final String table;         // "table5", "table12"
  final List<OrderItem> items;
  final double total;
  final String currency;      // "ILS", "EUR", "USD"
  final OrderStatus status;   // received|preparing|ready|served
  final DateTime createdAt;
  final Map<String, dynamic> channel; // État notifications
}
```

### Patterns de Notification

**Notifications Temps Réel**

- Son instantané (AudioElement) pour alertes immédiates
- Notifications navigateur avec détails commande
- Badge dynamique sidebar avec compteur live

**Canal de Secours**

- Webhook Slack pour notification mobile restaurateur
- Marquage état d'envoi dans Firestore
- Rate-limiting naturel (onCreate unique par commande)

### Sécurité et Validation

**Rules Firestore Orders**

- Création publique strictement validée (tous champs requis)
- Lecture/modification admin authentifié uniquement
- Validation types et contraintes business

**Idempotence Robuste**

- Hash basé sur : `rid|table|timeslot30s|itemCount|totalRounded`
- Évite doublons même en cas de double-clic rapide
- Compatible avec retry automatique côté client

## Patterns de Performance

### Optimisations Client

**Service Worker (Flutter Web)**

```
Flutter génère automatiquement flutter_service_worker.js.
Pour stratégies différenciées client/admin :
- Customiser web/ folder build options
- Ou config via flutter build web --dart-define
```

**Optimisations Images**

- `cached_network_image` (si activé web)
- Routes avec navigation paresseuse
- Composants admin séparés du bundle client

### Optimisations Firestore

**Requêtes Optimisées**

```dart
// Éviter les listeners multiples
Stream<QuerySnapshot> menuStream = FirebaseFirestore.instance
  .collection('restaurants/{rid}/menus')
  .snapshots()
  .distinct(); // Évite rebuilds identiques
```

**Indexation Sélective**

- Index composites limités aux vraies requêtes
- Éviter sur-indexation coûteuse

## Patterns de Test

### Architecture Testable

**Injection de Dépendances**

```dart
class CategoryManager {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  // Test injection
  static void setFirestoreInstance(FirebaseFirestore instance) {
    _db = instance;
  }
}
```

**Mocks Firestore**

```dart
void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    CategoryManager.setFirestoreInstance(fakeFirestore);
  });
}
```

### Couverture Tests

**Repository Tests** (`test/services/`)

- CRUD operations avec rollback
- Streams temps réel
- Gestion d'erreurs réseau
- Optimistic updates

**Coverage Actuel**

- CategoryManager : 9/9 tests passing
- Repository catégories : tests complets
- Services critiques : covered

## Sécurité et Conformité

### Protection des Données

**Isolation Multi-tenant**

- Séparation stricte par `restaurantId`
- Validation côté rules Firestore
- Pas de données cross-tenant

**Authentification**

- Firebase Auth avec email/password
- Sessions gérées automatiquement
- Logout sécurisé avec nettoyage state

### CORS et Domaines

**CORS Storage**

```bash
# Obtenir le bucket exact
firebase storage:bucket

# Appliquer CORS sur le bucket retourné
gsutil cors set cors.json gs://<your-storage-bucket>
```

**Domaines Autorisés**

- Développement : `localhost`, `127.0.0.1`
- Production : domaines configurés Firebase Auth

## Évolutions Prévues

### Phase Technique

**QR Scanner Natif**

- Integration `mobile_scanner`
- Permissions caméra cross-platform
- Fallback gallery upload

**QR Scanner Mobile Web**

- Solution photo upload + décodage client-side
- Integration zxing2 pour décodage QR
- Progressive enhancement mobile/desktop

**RBAC Complet**

- Système de rôles owner/manager/staff
- Permissions granulaires par ressource
- Invitations d'équipe

### Phase Performance

**Core Web Vitals**

- Optimisation bundle size
- Tree-shaking avancé
- Image optimization pipeline

**Analytics Avancées** (à venir)

- Métriques usage détaillées
- Tracking conversion clients
- Dashboard insights restaurant

## Architecture Évolutive

SmartMenu est conçu pour évoluer sans refactoring majeur :

**Extensibilité Services**

- Pattern service statique réutilisable
- Injection dépendances pour tests
- APIs contractuelles stables

**Modularité UI**

- Design system découplé
- Composants réutilisables
- Responsive patterns scalables

**Scalabilité Backend**

- Architecture serverless Firebase
- Auto-scaling intégré
- Coûts optimisés par usage
