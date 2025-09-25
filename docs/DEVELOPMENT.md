# Guide de Développement SmartMenu

Ce guide couvre la configuration de l'environnement de développement, les workflows et les conventions pour contribuer à SmartMenu.

## Prérequis

### Système de Slugs

#### Configuration

Le système génère automatiquement des URLs propres :

- `/r/pizza-corner` au lieu de `/r/mpzzZ4GAnsJUjpYO6X7d`
- Génération automatique à la création du restaurant
- Résolution via collection Firestore `slugs`

#### Structure Firestore

- `slugs/{slug}` → `{ rid: "restaurant-id" }`
- `restaurants/{rid}/info/details.slug` → nom du slug

### Système QR Code

#### Dépendances

```yaml
dependencies:
  mobile_scanner: ^4.0.1 # Scanner QR (stable Flutter Web)
  qr_flutter: ^4.1.0 # Génération QR
```

#### Structure Firestore QR

```
restaurants/{rid}/
└── qr_config/
    └── settings
        ├── customMessage: string?
        ├── showLogo: boolean
        ├── size: "small"|"medium"|"large"
        └── updated_at: timestamp
```

#### Usage Patterns

```dart
// Scanner depuis home_screen.dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const QRScannerScreen()),
);

// Génération depuis admin_settings_screen.dart
void _generateQRCode(String code) {
  showDialog(
    context: context,
    builder: (_) => _QRGeneratorDialog(
      restaurantId: widget.restaurantId,
      restaurantName: _currentName ?? 'Mon Restaurant',
      slug: code,
    ),
  );
}
```

#### Services QR

**`qr_service.dart` - Service principal :**

```dart
class QRService {
  static String generateRestaurantUrl(String slug) {
    return '${Uri.base.origin}/r/$slug';
  }

  static bool isValidSmartMenuQR(String qrData) {
    return qrData.contains('/r/') && Uri.tryParse(qrData) != null;
  }

  static String? extractSlugFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri?.pathSegments.length == 2 && uri?.pathSegments[0] == 'r') {
      return uri!.pathSegments[1];
    }
    return null;
  }
}
```

### Système de Commandes

#### Architecture MVP

Le système implémente l'expérience complète des grandes plateformes (Uber Eats, DoorDash) :

- Notifications temps réel (son + navigateur)
- Canal de secours automatique (Slack webhook)
- Interface admin professionnelle avec onglets de statut

#### Dépendances

```yaml
dependencies:
  crypto: ^3.0.3 # Hash idempotent pour anti-doublon
  # Notifications navigateur intégrées Flutter Web
```

#### Structure Firestore Orders

```
restaurants/{rid}/orders/{oid}
├── oid: string (hash déterministe)
├── rid: string
├── table: string ("table1", "table12")
├── items: array<{name, price, quantity}>
├── total: number
├── currency: string ("ILS", "EUR", "USD")
├── status: string ("received"|"preparing"|"ready"|"served")
├── created_at: timestamp (serverTimestamp)
└── channel: map
    ├── source: "web"
    └── slack: {sent: boolean, at: timestamp}
```

#### Services Orders

`OrderService` - Service principal :

```dart
class OrderService {
  // Idempotence via hash robuste (30s timeslot)
  static String generateOrderId(String rid, String table,
                                Map<String, int> items, double total);

  // Soumission avec validation stricte
  static Future<String> submitOrder({
    required String restaurantId,
    required Map<String, int> itemQuantities,
    required Map<String, List<Map<String, dynamic>>> menuData,
    required String currency,
  });

  // Streams temps réel par statut
  static Stream<List<Order>> getOrdersByStatusStream(
    String restaurantId,
    OrderStatus status
  );
}
```

#### Cloud Functions Integration

**Configuration Slack :**

```bash
firebase functions:secrets:set SLACK_WEBHOOK_URL
```

**Pattern Function v2 :**

```javascript
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

exports.onNewOrderNotifySlack = onDocumentCreated(
  "restaurants/{rid}/orders/{oid}",
  async (event) => {
    // Notification Slack automatique + marquage état
  }
);
```

#### Notifications Temps Réel

**Notifications navigateur (admin) :**

```dart
// Son d'alerte
html.AudioElement('/assets/sounds/new_order.mp3')..play();

// Notification bureau
if (html.Notification.permission == 'granted') {
  html.Notification('Nouvelle commande',
    body: 'Table 5 • 3 items • 45 ₪');
}
```

## Système d'Appel Serveur

### Architecture Notification Interne

SmartMenu implémente le pattern standard des POS modernes (Toast, Resy) :

```
Client Appel → Firestore → Admin UI (Son + Banner)
                  ↓
              Collection server_calls
```

### Modèles de Données Server Calls

**ServerCall** - Demande d'assistance table

```dart
class ServerCall {
  final String id;            // Document ID auto-généré
  final String table;         // "table5", "table12"
  final String status;        // "open"|"acked"|"done"
  final DateTime createdAt;   // Timestamp création
  final DateTime? ackedAt;    // Timestamp pris en compte
  final DateTime? closedAt;   // Timestamp résolu
}
```

### Structure Firestore Server Calls

```
restaurants/{rid}/server_calls/{callId}
├── rid: string                 // Restaurant ID
├── table: string              // "table12"
├── status: string             // "open"|"acked"|"done"
├── created_at: timestamp      // serverTimestamp
├── acked_at: timestamp?       // null si status != "acked"|"done"
├── closed_at: timestamp?      // null si status != "done"
└── repeat: number             // Compteur rappels (futur)
```

### Services Server Calls

`ServerCallService` - Service principal :

```dart
class ServerCallService {
  // Anti-spam côté client (45s cooldown)
  static final Map _lastCallPerTable = {};
  static const _cooldown = Duration(seconds: 45);

  // Création appel avec validations
  static Future callServer({
    required String rid,
    required String table,
  });

  // Streams temps réel pour admin
  static Stream<List> getServerCalls(String rid);

  // Actions admin
  static Future acknowledgeCall(String rid, String callId);
  static Future closeCall(String rid, String callId);
}
```

### Patterns de Notification Admin

**Interface Admin Responsive**

- Banner au-dessus des onglets commandes
- Mobile : boutons empilés (pleine largeur)
- Desktop : boutons côte à côte (alignés droite)

**Sons Différenciés**

- `new_order.mp3` : Son commandes (plus doux)
- `server_call.mp3` : Son appels serveur (plus urgent)

**États Visuels**

- **Orange** : Status "open" (nouveau)
- **Bleu** : Status "acked" (pris en compte)
- **Disparition** : Status "done" (résolu)

### Sécurité et Validation

**Rules Firestore Server Calls**

```javascript
match /restaurants/{rid}/server_calls/{callId} {
  allow create: if
    request.resource.data.rid == rid &&
    request.resource.data.table.matches('^table\\d+$') &&
    request.resource.data.status == 'open' &&
    request.resource.data.created_at == request.time;

  allow read, update: if isMember(rid);
  allow delete: if isOwner(rid);
}
```

**Validations Business**

- Cooldown 45s entre appels par table
- Vérification appel existant (pas de doublon open/acked)
- Validation format table (`table\d+`)

### Interface Client

**Intégration PremiumAppHeaderWidget**

```dart
PremiumAppHeaderWidget(
  onServerCall: _isLoading ? null : () {
    // Logique appel avec gestion d'état
    final tableId = TableService.getTableId();
    ServerCallService.callServer(rid: restaurantId, table: 'table$tableId');
  },
)
```

**UX Patterns**

- Bouton désactivé pendant traitement
- Notification succès persistante
- Gestion d'erreurs avec messages clairs

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

### Outils Requis

- **Flutter SDK** 3.16+ avec support web activé
- **Firebase CLI** 13.0+
- **Google Cloud SDK** (pour CORS Storage)
- **Git** 2.30+
- **VS Code** ou IDE compatible Flutter

### Vérification Installation

```bash
flutter doctor -v
firebase --version
gcloud --version
```

**Output attendu :**

- Flutter : aucun problème sur web support
- Firebase CLI : connecté à un projet
- gcloud : authentifié

## Limitations Actuelles

### Scanner QR Mobile Web

- **Desktop HTTPS** : Scanner live fonctionnel
- **Mobile Web** : Saisie manuelle uniquement (limitation technique)
- **Alternative** : QR generators externes + codes manuels

### Téléchargement QR

- **Format** : PNG basique (placeholder avec texte)
- **Production future** : Intégration lib QR-to-canvas dédiée

## Configuration Environnement

### 1. Clone et Dependencies

```bash
git clone https://github.com/RaphHtech/smartmenu.git
cd smartmenu
flutter config --enable-web
flutter pub get
```

### 2. Configuration Firebase

#### Initialisation FlutterFire

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**Sélectionner :**

- Projet : `smartmenu-mvp` (ou votre projet)
- Plateformes : Web
- Configuration : Oui pour Firestore, Auth, Storage

#### Variables d'Environnement

Créer `lib/firebase_options.dart` (généré automatiquement) :

```dart
// Auto-généré par flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "...",
    projectId: "smartmenu-mvp",
    // ...
  );
}
```

### 3. Configuration Firebase Console

#### Firestore Rules

> **⚠️ WARNING** : Configuration MVP avec writes `request.auth != null`. Pour production, implémenter RBAC strict avec membership verification (voir `docs/DEPLOYMENT.md`).

Copier dans Console Firebase > Firestore > Rules :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Lecture publique pour PWA clients
    match /restaurants/{rid}/menus/{doc} {
      allow read: if true;
    }
    match /restaurants/{rid}/info/{doc} {
      allow read: if true;
    }

    // Admin protégé (MVP - à restreindre en production)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurants/{rid}/menu/{file=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /restaurants/{rid}/branding/{file=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /restaurants/{rid}/media/{file=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

#### Configuration CORS

```bash
# Créer cors.json
cat > cors.json << EOF
[
  {
    "origin": [
      "http://localhost:3000",
      "http://127.0.0.1:3000",
      "https://smartmenu-mvp.web.app"
    ],
    "method": ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Authorization", "Content-Length", "User-Agent", "x-goog-resumable"]
  }
]
EOF

# Appliquer CORS
firebase storage:bucket  # Noter le bucket retourné
gsutil cors set cors.json gs://BUCKET_FROM_ABOVE
```

**Note** : Pour dev rapide, remplacer `"origin"` par `["*"]` (dev uniquement, à restreindre avant production)

### 4. Configuration Auth

**Console Firebase > Auth > Sign-in method :**

- Activer Email/Password
- Ajouter domaines autorisés :
  - `localhost`
  - `127.0.0.1`
  - Votre domaine de production

## Workflows de Développement

### Démarrage Serveur de Dev

```bash
flutter run -d chrome --web-port 3000
```

**URLs locales :**

- Admin : `http://localhost:3000/admin`
- Client test : `http://localhost:3000/r/TEST_RESTAURANT_ID`
- Landing : `http://localhost:3000`

### Structure des Branches

```
main           # Production stable
├── develop    # Intégration features
├── feature/*  # Nouvelles fonctionnalités
├── hotfix/*   # Corrections urgentes
└── docs/*     # Documentation
```

### Workflow Feature

```bash
# Créer feature branch
git checkout -b feature/qr-scanner-mobile

# Développement avec commits fréquents
git add .
git commit -m "feat: ajout mobile_scanner dependency"
git commit -m "feat: interface QR scanner basique"

# Tests avant merge
flutter test
flutter analyze

# Push et PR
git push origin feature/qr-scanner-mobile
```

## Conventions de Code

### Nommage

**Fichiers :**

- Screens : `admin_dashboard_screen.dart`
- Widgets : `category_pill_widget.dart`
- Services : `category_repository.dart`
- Models : `category.dart`

**Classes et Variables :**

```dart
// Classes : PascalCase
class CategoryManager {}
class AdminShell {}

// Variables : camelCase
final String restaurantId;
late StreamSubscription _subscription;

// Constantes : lowerCamelCase
static const double sidebarWidth = 280.0;

// Privé : prefixe _
String _selectedCategory;
void _handleStateUpdate() {}
```

**Imports :**

```dart
// Flutter framework
import 'package:flutter/material.dart';

// Packages externes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

// Imports relatifs du projet
import '../../core/design/admin_tokens.dart';
import '../services/category_repository.dart';
```

### Structure Widget

**Template de base :**

```dart
class NewWidget extends StatefulWidget {
  final String requiredParam;
  final String? optionalParam;

  const NewWidget({
    super.key,
    required this.requiredParam,
    this.optionalParam,
  });

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  // State variables
  late String _internalState;

  @override
  void initState() {
    super.initState();
    _internalState = widget.requiredParam;
  }

  @override
  void dispose() {
    // Cleanup resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget tree
    );
  }

  // Helper methods
  void _privateMethod() {}
}
```

### Gestion d'État

**StreamBuilder Pattern :**

```dart
StreamBuilder<CategoryLiveState>(
  stream: CategoryManager.getLiveState(restaurantId),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return ErrorWidget(snapshot.error.toString());
    }

    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }

    final state = snapshot.data!;
    return _buildContent(state);
  },
)
```

**State Management :**

```dart
// Optimistic updates
setState(() {
  _localState = newValue;
});

try {
  await service.updateRemote(newValue);
} catch (e) {
  // Rollback
  setState(() {
    _localState = oldValue;
  });
  _showError(e);
}
```

## Tests

### Configuration Tests

**Dependencies test :**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.0.2
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

### Tests Unitaires

**Structure test :**

```dart
void main() {
  group('CategoryManager', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      CategoryManager.setFirestoreInstance(fakeFirestore);
    });

    test('should add category to order', () async {
      // Setup
      await fakeFirestore
          .collection('restaurants')
          .doc('test-rid')
          .collection('info')
          .doc('details')
          .set({'categoriesOrder': []});

      // Execute
      await CategoryManager.addCategory('test-rid', 'Nouvelle');

      // Verify
      final doc = await fakeFirestore
          .collection('restaurants')
          .doc('test-rid')
          .collection('info')
          .doc('details')
          .get();

      final order = List<String>.from(doc.data()!['categoriesOrder']);
      expect(order, contains('Nouvelle'));
    });
  });
}
```

### Lancement Tests

```bash
# Tests unitaires
flutter test

# Tests avec coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Tests spécifiques
flutter test test/services/category_repository_test.dart

# Watch mode
flutter test --watch
```

### Critères Qualité

**Avant commit :**

```bash
# Analyse statique
flutter analyze

# Tests
flutter test

# Format code
dart format .

# Vérifications
flutter doctor
```

**Seuils acceptés :**

- flutter analyze : ≤ 10 issues info/warning
- Tests : 100% des tests critiques passent
- Coverage : ≥ 70% pour services core

## Design System

### Utilisation AdminTokens

**Couleurs :**

```dart
// Textes
color: AdminTokens.neutral900,  // Principal
color: AdminTokens.neutral600,  // Secondaire
color: AdminTokens.primary600,  // Actions

// Backgrounds
backgroundColor: AdminTokens.neutral50,   // Page
backgroundColor: AdminTokens.primary50,   // Accent léger
```

**Espacements :**

```dart
padding: EdgeInsets.all(AdminTokens.space24),
margin: EdgeInsets.only(bottom: AdminTokens.space16),
```

**Composants :**

```dart
// Boutons
SizedBox(
  height: AdminTokens.buttonHeightMd,
  child: ElevatedButton(...),
)

// Cards
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AdminTokens.radius8),
    boxShadow: AdminTokens.shadowMd,
  ),
)
```

### Responsive Patterns

**Breakpoints :**

```dart
class Breakpoints {
  static const double mobile = 768;   // ≤768px mobile
  static const double desktop = 1024; // ≥1024px desktop
}

// Usage
Widget _buildResponsive() {
  final width = MediaQuery.of(context).size.width;

  if (width >= Breakpoints.desktop) {
    return _buildDesktopLayout();
  } else {
    return _buildMobileLayout();
  }
}
```

## Performance

### Optimisations Build

**Configuration web :**

```bash
# Build production optimisé
flutter build web --release --tree-shake-icons

# Build avec source maps (debug)
flutter build web --source-maps

# Analyse bundle size
flutter build web --analyze-size
```

### Patterns Performance

**Lazy Loading :**

```dart
// Widgets coûteux
class ExpensiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Skeleton();
        }
        return _buildContent(snapshot.data!);
      },
    );
  }
}
```

**Optimisations Firestore :**

```dart
// Limitation résultats
.limit(50)
.where('visible', isEqualTo: true)

// Cache local
.snapshots(includeMetadataChanges: false)

// Pagination
Query query = collection.orderBy('created_at').limit(20);
if (lastDocument != null) {
  query = query.startAfterDocument(lastDocument);
}
```

### Currency Management

**Service centralisé** : Tous les prix passent par `CurrencyService.format()`

```dart
// ❌ Éviter
Text('₪${price.toStringAsFixed(2)}');
Text('$currencySymbol$price');

// ✅ Utiliser
Text(context.money(price));
Text(CurrencyService.format(price, currencyCode));
```

**Architecture** : InheritedWidget scope restaurant-level, extension helper élégante.
**Stockage Firestore** : `restaurants/{rid}/info/details.currency: "ILS"`

## Débogage

### Outils Debug

**Flutter Inspector :**

```bash
flutter run -d chrome --debug
# Ouvrir Flutter Inspector dans VS Code
```

**Firebase Emulator :**

```bash
# Installation
npm install -g firebase-tools

# Démarrage emulators (développement)
firebase emulators:start --only firestore,auth

# Configuration app pour emulators
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

**⚠️ Important** : Désactiver les emulators avant build production (commenter les `useEmulator()` calls).

### Debug Common Issues

**CORS Errors :**

```bash
# Vérifier bucket CORS
gsutil cors get gs://YOUR_BUCKET

# Re-appliquer si nécessaire
gsutil cors set cors.json gs://YOUR_BUCKET

# Clear cache
# DevTools > Application > Clear Storage
```

**Auth Errors :**

```dart
// Debug auth state
FirebaseAuth.instance.authStateChanges().listen((user) {
  debugPrint('Auth state: ${user?.uid ?? 'anonymous'}');
});

// Vérifier domaines autorisés
// Console Firebase > Auth > Settings > Authorized domains
```

**Build Errors :**

```bash
# Clean build
flutter clean
flutter pub get

# Clear web cache
rm -rf build/web
flutter build web

# Check dependencies conflicts
flutter pub deps
```

## Sécurité

### Validation Input

**Sanitization :**

```dart
String sanitizeInput(String input) {
  if (input.isEmpty) return input;

  return input
      .trim()
      .replaceAll(RegExp(r'[<>\"\'&]'), '') // Basic sanitization
      .substring(0, math.min(input.length, 100)); // Length limit avec guard
}
```

**Note** : Exemple générique - Flutter Web a moins de risques XSS que web classique.

**Validation Business :**

```dart
bool isValidRestaurantId(String id) {
  return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id) &&
         id.length >= 3 &&
         id.length <= 50;
}
```

### Protection Données

**Firestore Rules Testing :**

```bash
# Installer emulator
npm install -g @firebase/rules-unit-testing

# Test rules
firebase emulators:exec --only firestore "npm test"
```

## Production

### Build Production

```bash
# Build optimisé
flutter build web --release \
  --tree-shake-icons \
  --web-renderer canvaskit \
  --split-debug-info=debug_symbols \
  --obfuscate

# canvaskit = plus fluide sur desktop
# html = plus léger, meilleur sur mobile

# Vérifier output
ls -la build/web/
```

**⚠️ Production** : Servir PWA en HTTPS uniquement pour fonctionnalités complètes.

### Déploiement

```bash
# Deploy Firebase Hosting
firebase deploy --only hosting

# Deploy avec preview
firebase hosting:channel:deploy preview-branch

# Rollback si nécessaire
firebase hosting:rollback
```

### Monitoring

**Analytics Setup :** (packages optionnels : `firebase_analytics`, `firebase_crashlytics`)

```dart
// Configuration
FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

// Events tracking
FirebaseAnalytics.instance.logEvent(
  name: 'menu_open',
  parameters: {'restaurant_id': restaurantId},
);
```

## Troubleshooting

### Problèmes Fréquents

**Hot reload ne fonctionne pas :**

```bash
# Restart avec cache clean
flutter clean
flutter run -d chrome
```

**Images ne s'affichent pas :**

- Vérifier CORS Storage configuré
- Vérifier URLs Firebase Storage valides
- Check network tab pour errors 403/404

**Performance lente :**

- Réduire listeners Firestore multiples
- Implementer pagination
- Optimiser widget rebuilds

**Auth issues :**

- Vérifier domaines autorisés Firebase Console
- Clear browser cache et localStorage
- Tester en navigation privée

### Logs et Debugging

**Logs structurés :**

```dart
import 'package:flutter/foundation.dart';

void logDebug(String message, [Object? data]) {
  if (kDebugMode) {
    debugPrint('[SmartMenu] $message${data != null ? ': $data' : ''}');
  }
}
```

**Error Reporting :**

```dart
// Capture exceptions
FlutterError.onError = (details) {
  // Send to crash reporting service
  FirebaseCrashlytics.instance.recordFlutterError(details);
};
```

Cette documentation fournit tous les éléments nécessaires pour développer efficacement sur SmartMenu en maintenant la qualité et les standards du projet.
