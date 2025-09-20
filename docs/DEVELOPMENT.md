# Guide de Développement SmartMenu

Ce guide couvre la configuration de l'environnement de développement, les workflows et les conventions pour contribuer à SmartMenu.

## Prérequis

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
