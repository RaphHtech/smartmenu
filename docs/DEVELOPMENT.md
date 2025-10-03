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

## Phase 1 : QR System Achievements

### Scanner QR Complet

- **Mobile Scanner** : `mobile_scanner: ^4.0.1` intégré avec permissions
- **Fallback saisie** : TextField pour codes manuels si caméra indisponible
- **Parsing robuste** : URLs modernes + legacy `smartmenu://` support
- **Analytics hooks** : `qr_scanned`, `qr_scan_failed`, `qr_manual_submit`

### Génération QR Admin

- **Interface complète** : preview + personnalisation + export
- **Multi-formats** : PNG individuel + Template A5 bilingue
- **Configuration** : messages custom + tailles variables
- **Persistance** : QRService.saveQRConfig() avec Firestore

### Production Ready

- **URLs propres** : `/r/{slug}` générées automatiquement
- **Téléchargement fonctionnel** : QR PNG scannables via RepaintBoundary
- **Templates impression** : A5 bilingues FR/EN prêts découpe
- **Système bout-en-bout** : validation terrain par utilisateurs

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

## Système d'Internationalisation

### Architecture I18N

SmartMenu supporte 3 langues avec RTL automatique pour l'hébreu.

**Dépendances requises**

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  provider: ^6.0.5

dev_dependencies:
  intl_utils: ^2.8.7 # Optionnel
```

### Structure Fichiers

lib/
├── l10n/
│ ├── app_en.arb # Anglais (template)
│ ├── app_he.arb # Hébreu
│ ├── app_fr.arb # Français
│ ├── app_localizations.dart # Généré
│ ├── app_localizations_en.dart # Généré
│ ├── app_localizations_he.dart # Généré
│ └── app_localizations_fr.dart # Généré
├── services/
│ └── language_service.dart
├── state/
│ └── language_provider.dart
└── widgets/
└── language_selector_widget.dart

### Configuration

l10n.yaml (racine du projet) :

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
synthetic-package: false
```

### Génération Traductions

```bash
# Après modification des fichiers ARB
flutter gen-l10n

# Vérification
ls lib/l10n/app_localizations*.dart
```

### Usage dans le Code

#### Import et helper :

```dart
import '../../l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return Text(_l10n(context).menuTitle);
  }
}
```

#### Avec placeholders :

```dart
// ARB
{
  "itemAddedToCart": "{itemName} ajouté au panier !",
  "@itemAddedToCart": {
    "placeholders": {
      "itemName": {"type": "String"}
    }
  }
}

// Dart
Text(_l10n(context).itemAddedToCart("Pizza Margherita"));
```

### RTL Support

#### Configuration automatique via MaterialApp :

```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: languageProvider.locale,  // Contrôlé par Provider
)
```

#### Directionality adaptative :

```dart
// Détection automatique
final isRTL = Directionality.of(context) == TextDirection.rtl;

// Icônes directionnelles
Icon(
  isRTL ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
  matchTextDirection: true,
)

// Padding directionnel
EdgeInsetsDirectional.only(start: 16, end: 8)
```

### Ajout de Nouvelles Traductions

#### Ajouter clé dans les 3 ARB :

```json
// app_en.arb
{
  "newKey": "English text",
  "@newKey": {
    "description": "Description for translators"
  }
}
```

#### Régénérer :

```bash
flutter gen-l10n
```

#### Utiliser :

```dart
Text(_l10n(context).newKey)
```

### Langue Persistente

#### Le système sauvegarde la préférence dans SharedPreferences :

```dart
// LanguageService
static Future<void> setLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_language', locale.languageCode);
}
```

### Phase 6 : Traduction Interface Admin (Partiel)

**Status Phase 6A-6B** : Complété (Octobre 2025)

#### Écrans Traduits

**✅ Complets :**

- Sidebar navigation (10 clés)
- Dashboard overview (18 clés avec ICU plurals)
- Menu screen avec filtres (26 clés)
- Primitives communes réutilisables (10 clés)

**⏳ Restant Phase 6C :**

- Formulaire édition plat (labels seulement, tabs déjà multilingues)
- Orders screen (statuts, actions)
- Settings screen (configuration)
- Media screen (upload, gestion)
- Branding screen (personnalisation)
- Restaurant info screen (détails)
- Sélecteur langue admin dans AdminShell

#### Clés ARB Admin

**Structure organisée par écran :**
common._ → Primitives réutilisables (add, edit, delete, etc.)
adminShell._ → Navigation sidebar + footer
adminDashboard._ → Tableau de bord overview
adminMenu._ → Écran liste plats
adminOrders._ → (Phase 6C) Gestion commandes
adminSettings._ → (Phase 6C) Paramètres

#### Méthodologie Phase 6

**Process itératif appliqué :**

1. Inventaire strings par écran
2. Création clés ARB (EN/HE/FR) avec descriptions
3. Génération via `flutter gen-l10n`
4. Remplacement hardcoded strings
5. Test compilation + vérification langues
6. Commit atomique par sous-phase

**Convention nommage :**

- `common.*` pour réutilisables cross-screen
- `admin[Screen].*` pour écrans spécifiques
- ICU plurals obligatoires : `{count, plural, =0{} one{} other{}}`
- Placeholders typés : `{name}`, `{error}`

#### Ajout Nouvelles Clés Admin

```bash
# 1. Ajouter dans les 3 ARB (EN/HE/FR)
# lib/l10n/app_en.arb
{
  "adminNewKey": "English text",
  "@adminNewKey": {
    "description": "Context for translators"
  }
}

# 2. Régénérer
flutter gen-l10n

# 3. Utiliser
final l10n = AppLocalizations.of(context)!;
Text(l10n.adminNewKey)
```

#### Tests I18N Admin

```dart
testWidgets('Admin sidebar displays in Hebrew', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider()..setLocale(Locale('he')),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AdminShell(...),
      ),
    ),
  );

  expect(find.text('לוח בקרה'), findsOneWidget); // "Dashboard" en hébreu
});
```

### Règles Critiques

#### Déclarer l10n dans chaque fonction :

```dart
Widget _build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  // ...
}
```

#### Jamais de const avec l10n :

```dart
// ❌ ERREUR
const Text(l10n.key)

// ✅ CORRECT
Text(l10n.key)
```

#### ICU obligatoire pour pluriels :

```json
"key": "{count, plural, =0{Aucun} one{Un} other{{count}}}"
```

#### Placeholders typés :

```json
"@key": {
  "placeholders": {
    "name": {"type": "String"}
  }
}
```

### Fichiers Clés

#### ARB Files :

lib/l10n/app_en.arb (template référence)
lib/l10n/app_he.arb (hébreu RTL)
lib/l10n/app_fr.arb (français)

#### Config :

l10n.yaml (racine projet)
pubspec.yaml (dépendances i18n)

#### Services :

lib/services/language_service.dart (persistence)
lib/state/language_provider.dart (Provider)

#### Commandes Utiles

```bash
# Régénérer après modification ARB
flutter gen-l10n

# Tester compilation
flutter run -d chrome

# Hot reload
r

# Restart complet
R

# Vérifier clés manquantes
grep -r "l10n\." lib/screens/admin/ | grep -v "app_localizations"
```

#### Problèmes Courants

Undefined name 'l10n'
→ Ajouter final l10n = AppLocalizations.of(context)!; au début de la fonction
Invalid constant value
→ Enlever const devant widget utilisant l10n

#### Clé non trouvée après gen-l10n

→ Vérifier syntaxe JSON (virgules, guillemets)
→ Relancer flutter gen-l10n

#### RTL cassé

→ Utiliser EdgeInsetsDirectional, Alignment.start/end
→ matchTextDirection: true sur icônes directionnelles

#### Prochaine Session (Phase 6C)

Objectif : Compléter admin multilingue complet
Plan suggéré :
Orders screen (critique, 1h)
Settings screen (important, 1h)
Sélecteur langue admin (30 min)
Media/Branding/Info si temps (bonus)

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

## Design System Client

### ClientTokens Usage

**Espacements standardisés :**

```dart
// ✅ Utiliser
EdgeInsets.all(ClientTokens.space16)
const SizedBox(width: ClientTokens.space12)

// ❌ Éviter
EdgeInsets.all(16)
const SizedBox(width: 12)
```

**Rayons standardisés :**

```dart
// ✅ Utiliser
BorderRadius.circular(ClientTokens.radius16)

// ❌ Éviter
BorderRadius.circular(16)
```

**Touch targets :**

```dart
// ✅ Utiliser
IconButton(
  constraints: BoxConstraints(
    minWidth: ClientTokens.minTouchTarget,
    minHeight: ClientTokens.minTouchTarget,
  ),
)
```

**Architecture** : ClientTokens évite les couleurs figées, utilise uniquement spacing/radius/elevation pour compatibilité thème Material 3.

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
