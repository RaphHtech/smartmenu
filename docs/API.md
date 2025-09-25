# API Documentation SmartMenu

Cette documentation décrit les services, modèles et contrats de données de SmartMenu.

## Services Core

### CategoryManager

Service principal pour la gestion des catégories avec streams temps réel et opérations optimistes.

#### Configuration

**Dépendances requises**

- `rxdart: ^0.27.7` (voir `pubspec.yaml`)

```dart
import 'package:smartmenu_app/services/category_repository.dart';
import 'package:smartmenu_app/models/category.dart';
```

#### Méthodes Principales

##### `getLiveState(String restaurantId)`

Retourne un stream temps réel de l'état des catégories.

```dart
static Stream<CategoryLiveState> getLiveState(String restaurantId)
```

**Paramètres**

- `restaurantId` : Identifiant unique du restaurant

**Retour**

- `Stream<CategoryLiveState>` : État live combinant ordre, visibilité et compteurs

**Usage**

```dart
CategoryManager.getLiveState('resto-123').listen((state) {
  print('Ordre: ${state.order}');
  print('Masquées: ${state.hidden}');
  print('Compteurs: ${state.counts}');
});
```

##### `reorderCategories(String restaurantId, List<String> newOrder)`

Réorganise l'ordre des catégories.

```dart
static Future<void> reorderCategories(String restaurantId, List<String> newOrder)
```

**Paramètres**

- `restaurantId` : Identifiant restaurant
- `newOrder` : Nouvel ordre des catégories

**Exceptions**

- Échec réseau Firestore
- Restaurant inexistant

**Usage**

```dart
await CategoryManager.reorderCategories(
  'resto-123',
  ['Pizzas', 'Pâtes', 'Desserts']
);
```

##### `toggleCategoryVisibility(String restaurantId, String category)`

Bascule la visibilité d'une catégorie (masquer/afficher).

```dart
static Future<void> toggleCategoryVisibility(String restaurantId, String category)
```

**Paramètres**

- `restaurantId` : Identifiant restaurant
- `category` : Nom de la catégorie à basculer

**Comportement**

- Si visible → masque
- Si masquée → affiche
- Mise à jour optimiste avec rollback en cas d'erreur

##### `renameCategory(String restaurantId, String oldName, String newName, {bool forceMerge = false})`

Renomme une catégorie et met à jour tous les plats associés.

```dart
static Future<void> renameCategory(
  String restaurantId,
  String oldName,
  String newName,
  {bool forceMerge = false}
)
```

**Paramètres**

- `restaurantId` : Identifiant restaurant
- `oldName` : Nom actuel de la catégorie
- `newName` : Nouveau nom souhaité
- `forceMerge` : Force la fusion si nouvelle catégorie existe

**Exceptions**

- `Exception('MERGE_REQUIRED')` : Catégorie destination existe (sans forceMerge)
- Échec batch operation Firestore

**Opération Batch** (limite 500 documents, chunking automatique)

1. Vérification existence catégorie destination
2. Mise à jour de tous les plats (WHERE category = oldName)
3. Mise à jour de l'ordre et visibilité
4. Commit atomique

##### `addCategory(String restaurantId, String categoryName)`

Ajoute une nouvelle catégorie.

```dart
static Future<void> addCategory(String restaurantId, String categoryName)
```

**Paramètres**

- `restaurantId` : Identifiant restaurant
- `categoryName` : Nom de la nouvelle catégorie

**Comportement**

- Transaction Firestore pour cohérence
- Évite les doublons automatiquement
- Ajoute en fin d'ordre par défaut

##### `deleteCategory(String restaurantId, String category)`

Supprime une catégorie vide.

```dart
static Future<void> deleteCategory(String restaurantId, String category)
```

**Paramètres**

- `restaurantId` : Identifiant restaurant
- `category` : Nom de la catégorie à supprimer

**Exceptions**

- `Exception('CATEGORY_NOT_EMPTY')` : Catégorie contient encore des plats

**Validation** (limite 500 vérifications, chunking si nécessaire)

1. Vérification que la catégorie est vide
2. Suppression de l'ordre et de la liste masquée
3. Transaction pour cohérence

#### Méthodes d'Injection (Tests)

##### `setFirestoreInstance(FirebaseFirestore instance)`

Injecte une instance Firestore pour les tests.

```dart
static void setFirestoreInstance(FirebaseFirestore instance)
```

**Usage Tests**

```dart
setUp(() {
  final fakeFirestore = FakeFirebaseFirestore();
  CategoryManager.setFirestoreInstance(fakeFirestore);
});

tearDown(() {
  // Note: resetFirestoreInstance() non utilisé en test environment
  // L'instance est isolée par test
});
```

## ServerCallService

Service de gestion des appels serveur avec cooldown et notifications temps réel.

### Configuration

**Dépendances requises**

```dart
import 'package:smartmenu_app/services/server_call_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
```

### Méthodes Principales

#### `callServer({required String rid, required String table})`

Crée un appel serveur avec validations anti-spam.

```dart
static Future callServer({
  required String rid,
  required String table,
})
```

**Paramètres**

- `rid` : Restaurant ID
- `table` : Identifiant table format "tableX" (ex: "table5")

**Validations**

- Cooldown 45 secondes par table
- Vérification absence d'appel ouvert existant
- Format table validé (`table\d+`)

**Exceptions**

- `'Veuillez attendre 45s entre les appels'` : Cooldown actif
- `'Un appel serveur est déjà en cours pour votre table'` : Appel existant

**Usage**

```dart
try {
  await ServerCallService.callServer(
    rid: 'resto-123',
    table: 'table5',
  );
  // Notification succès
} catch (e) {
  // Afficher erreur à l'utilisateur
}
```

#### `getServerCalls(String rid)`

Stream temps réel des appels serveur par ordre chronologique inverse.

```dart
static Stream<List> getServerCalls(String rid)
```

**Paramètres**

- `rid` : Restaurant ID

**Retour**

- `Stream<List<ServerCall>>` : Liste triée par created_at DESC, limitée à 50

**Usage**

```dart
StreamBuilder<List>(
  stream: ServerCallService.getServerCalls('resto-123'),
  builder: (context, snapshot) {
    final calls = snapshot.data ?? [];
    final openCalls = calls.where((c) => c.status != 'done').toList();

    return ListView(
      children: openCalls.map(_buildCallCard).toList(),
    );
  },
)
```

#### `acknowledgeCall(String rid, String callId)`

Marque un appel comme "pris en compte".

```dart
static Future acknowledgeCall(String rid, String callId)
```

**Paramètres**

- `rid` : Restaurant ID
- `callId` : ID document Firestore

**Comportement**

- Status passe de "open" → "acked"
- Ajoute timestamp `acked_at`

#### `closeCall(String rid, String callId)`

Marque un appel comme "résolu".

```dart
static Future closeCall(String rid, String callId)
```

**Paramètres**

- `rid` : Restaurant ID
- `callId` : ID document Firestore

**Comportement**

- Status passe de "open|acked" → "done"
- Ajoute timestamp `closed_at`

## Modèles ServerCall

### ServerCall

Représente une demande d'assistance table.

```dart
class ServerCall {
  final String id;
  final String table;
  final String status;
  final DateTime createdAt;
  final DateTime? ackedAt;
  final DateTime? closedAt;

  ServerCall({
    required this.id,
    required this.table,
    required this.status,
    required this.createdAt,
    this.ackedAt,
    this.closedAt,
  });
}
```

#### Propriétés

**`id : String`**

- ID unique du document Firestore
- Généré automatiquement à la création

**`table : String`**

- Format : "table12", "table5"
- Utilisé pour l'affichage UI

**`status : String`**

- **"open"** : Nouvel appel non traité
- **"acked"** : Pris en compte par staff
- **"done"** : Résolu et fermé

**`createdAt : DateTime`**

- Timestamp création de l'appel
- Utilisé pour tri chronologique et calcul "il y a X min"

**`ackedAt : DateTime?`**

- Null si status = "open"
- Timestamp quand status devient "acked"

**`closedAt : DateTime?`**

- Null si status != "done"
- Timestamp final de résolution

#### Factory fromDoc

```dart
factory ServerCall.fromDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map;
  return ServerCall(
    id: doc.id,
    table: data['table'] ?? 'table1',
    status: data['status'] ?? 'open',
    createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    ackedAt: (data['acked_at'] as Timestamp?)?.toDate(),
    closedAt: (data['closed_at'] as Timestamp?)?.toDate(),
  );
}
```

## Structure Firestore Server Calls

### Collection `restaurants/{rid}/server_calls/{callId}`

```typescript
{
  rid: string;                 // Restaurant ID (validation)
  table: string;               // "table12"
  status: "open"|"acked"|"done";
  created_at: Timestamp;       // serverTimestamp()
  acked_at?: Timestamp;        // null si open
  closed_at?: Timestamp;       // null si !done
  repeat: number;              // Compteur (défaut: 0)
}
```

### Index Recommandés

**Server calls par status**

```
Collection: restaurants/{rid}/server_calls
Fields: status (Ascending), created_at (Descending)
```

## Patterns d'Usage Server Calls

### Interface Admin Responsive

```dart
Widget _buildServerCallCard(ServerCall call) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 400) {
        // Mobile: boutons empilés
        return Column(
          children: [
            _buildCallInfo(call),
            _buildActionButtons(call, mobile: true),
          ],
        );
      } else {
        // Desktop: boutons côte à côte
        return Row(
          children: [
            Expanded(child: _buildCallInfo(call)),
            _buildActionButtons(call, mobile: false),
          ],
        );
      }
    },
  );
}
```

### Gestion Son Admin

```dart
class AdminSounds {
  static void playServerCallAlert() {
    if (kIsWeb) {
      try {
        html.AudioElement('assets/sounds/server_call.mp3')..play();
      } catch (e) {
        debugPrint('Erreur son: $e');
      }
    }
  }
}
```

## Modèles de Données

### CategoryLiveState

État temps réel des catégories d'un restaurant.

```dart
class CategoryLiveState {
  final List<String> order;
  final Set<String> hidden;
  final Map<String, int> counts;

  CategoryLiveState({
    required this.order,
    required this.hidden,
    required this.counts,
  });
}
```

#### Propriétés

**`order : List<String>`**

- Ordre personnalisé des catégories défini par le restaurateur
- Utilisé pour l'affichage dans les interfaces client et admin
- Vide par défaut (tri alphabétique fallback)

**`hidden : Set<String>`**

- Ensemble des catégories masquées
- N'apparaissent pas dans l'interface client
- Restent visibles côté admin avec indicateur

**`counts : Map<String, int>`**

- Compteur de plats par catégorie
- Calculé en temps réel depuis la collection menus
- Utilisé pour affichage et validation suppression

#### Usage

```dart
StreamBuilder<CategoryLiveState>(
  stream: CategoryManager.getLiveState(restaurantId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();

    final state = snapshot.data!;

    // Catégories visibles dans l'ordre
    final visibleCategories = state.order
        .where((cat) => !state.hidden.contains(cat))
        .toList();

    // Affichage avec compteurs
    return ListView(
      children: visibleCategories.map((category) {
        final count = state.counts[category] ?? 0;
        return ListTile(
          title: Text(category),
          trailing: Text('$count plats'),
        );
      }).toList(),
    );
  },
)
```

## Structure Firestore

### Collections

#### `restaurants/{rid}/info/details`

Document de configuration du restaurant.

**Schema**

```typescript
{
  name: string;                    // Nom du restaurant
  currency: string;                // Code devise (ILS, EUR, USD)
  tagline?: string;                // Sous-titre/slogan
  promo_text?: string;             // Bandeau promo
  promo_enabled?: boolean;         // Activation bandeau
  categoriesOrder: string[];       // Ordre personnalisé (noms case-sensitive)
  categoriesHidden: string[];      // Catégories masquées (noms case-sensitive)
  logoUrl?: string;                // URL logo uploadé
  logoVersion?: number;            // Version pour cache-busting
  updated_at: Timestamp;           // Dernière modification
}
```

#### `restaurants/{rid}/menus/{itemId}`

Documents des plats du menu.

**Schema**

```typescript
{
  name: string;                    // Nom du plat
  description?: string;            // Description
  price: number;                   // Prix (number, pas string)
  category: string;                // Catégorie
  imageUrl?: string;               // URL image
  signature?: boolean;             // Plat signature
  visible: boolean;                // Visible dans menu client
  position?: number;               // Position dans catégorie
  created_at: Timestamp;
  updated_at: Timestamp;
}
```

#### `restaurants/{rid}/members/{uid}`

Membres de l'équipe restaurant (RBAC futur).

**Schema**

```typescript
{
  role: 'owner' | 'manager' | 'staff';
  invited_at: Timestamp;
  invited_by: string;              // UID invitant
  accepted_at?: Timestamp;
}
```

### Index Firestore

#### Index Composites Requis

**Menus par catégorie et visibilité**

```
Collection: restaurants/{rid}/menus
Fields: category (Ascending), visible (Ascending)
```

**Menus par position dans catégorie**

```
Collection: restaurants/{rid}/menus
Fields: category (Ascending), position (Ascending)
```

## Patterns d'Usage

### Stream Management

**Souscription Simple**

```dart
late StreamSubscription _subscription;

@override
void initState() {
  super.initState();
  _subscription = CategoryManager.getLiveState(restaurantId)
      .listen(_handleStateUpdate);
}

@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

**Combinaison de Streams**

```dart
Stream<UiState> get combinedStream {
  return CombineLatestStream.combine2(
    CategoryManager.getLiveState(restaurantId),
    menuItemsStream,
    (categories, items) => UiState(
      categories: categories,
      items: items,
    ),
  );
}
```

### Gestion d'Erreurs

**Pattern Optimiste avec Rollback**

```dart
// État local optimiste
setState(() {
  _localCategories.remove(category);
});

try {
  await CategoryManager.deleteCategory(restaurantId, category);
} catch (e) {
  // Rollback en cas d'erreur
  setState(() {
    _localCategories.add(category);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $e')),
  );
}
```

### Validation et Contraintes

**Contraintes Business**

```dart
// Validation nom catégorie
bool isValidCategoryName(String name) {
  return name.trim().isNotEmpty &&
         name.length >= 2 &&
         name.length <= 50;
}

// Vérification catégorie vide avant suppression
Future<bool> canDeleteCategory(String restaurantId, String category) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('restaurants')
      .doc(restaurantId)
      .collection('menus')
      .where('category', isEqualTo: category)
      .limit(1)
      .get();

  return snapshot.docs.isEmpty;
}
```

## Design System API

### AdminTokens

Constantes de design pour l'interface admin.

```dart
import 'package:smartmenu_app/core/design/admin_tokens.dart';
```

#### Couleurs

**Palette Neutre**

```dart
AdminTokens.neutral50   // Background très clair
AdminTokens.neutral200  // Borders, dividers
AdminTokens.neutral600  // Text principal
AdminTokens.neutral900  // Text max contrast
```

**Couleurs Fonctionnelles**

```dart
AdminTokens.primary600  // Actions principales
AdminTokens.success500  // États de succès
AdminTokens.warning500  // Attention
AdminTokens.error500    // Erreurs
```

#### Espacements

```dart
AdminTokens.space8      // 8px
AdminTokens.space16     // 16px
AdminTokens.space24     // 24px
AdminTokens.space32     // 32px
```

#### Composants

```dart
AdminTokens.sidebarWidth    // 280px
AdminTokens.topbarHeight    // 64px
AdminTokens.inputHeight     // 44px
AdminTokens.buttonHeightMd  // 40px
```

#### Usage

```dart
Container(
  padding: EdgeInsets.all(AdminTokens.space24),
  decoration: BoxDecoration(
    color: AdminTokens.neutral50,
    borderRadius: BorderRadius.circular(AdminTokens.radius8),
    boxShadow: AdminTokens.shadowMd,
  ),
  child: Text(
    'Interface Admin',
    style: AdminTypography.headlineLarge.copyWith(
      color: AdminTokens.neutral900,
    ),
  ),
)
```

## Gestion des Erreurs

### Types d'Erreurs

**Erreurs Business** (codes standardisés)

- `Exception('CATEGORY_NOT_EMPTY')` : Tentative suppression catégorie non vide
- `Exception('MERGE_REQUIRED')` : Renommage vers catégorie existante

**Erreurs Firestore**

- `permission-denied` : Droits insuffisants
- `not-found` : Restaurant/document inexistant
- `unavailable` : Service temporairement indisponible

### Patterns de Gestion

**Validation Préventive**

```dart
// Avant appel API
if (newName.trim().isEmpty) {
  throw ArgumentError('Le nom ne peut pas être vide');
}

if (await _categoryExists(restaurantId, newName)) {
  throw Exception('MERGE_REQUIRED');
}
```

**Retry Pattern**

```dart
Future<T> withRetry<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: 1 << i)); // Backoff exponentiel
    }
  }
  throw StateError('Unreachable');
}
```

## Performance et Optimisations

### Optimisations Requêtes

**Limitation Results**

```dart
// Éviter over-fetching
.limit(100)
.where('visible', isEqualTo: true)
```

**Cache Local**

```dart
import 'package:flutter/foundation.dart';

// Stream avec distinctUntilChanged (évite rebuilds identiques)
stream.distinct((prev, next) =>
    listEquals(prev.order, next.order) &&
    setEquals(prev.hidden, next.hidden) &&
    mapEquals(prev.counts, next.counts)
)
```

### Batch Operations

**Groupage Modifications** (batches ≤ 500 documents)

```dart
final batch = FirebaseFirestore.instance.batch();

// Chunking automatique si > 500 items
for (final item in itemsToUpdate) {
  batch.update(item.reference, {'category': newName});
}

await batch.commit(); // Atomique
```

## Extensibilité

### Ajout de Nouveaux Services

**Pattern Service**

```dart
class NewManager {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  // Injection tests
  static void setFirestoreInstance(FirebaseFirestore instance) {
    _db = instance;
  }

  // Streams avec RxDart
  static Stream<NewState> getLiveState(String restaurantId) {
    return _db.collection('...').snapshots().map(...);
  }
}
```

### Extension Modèles

**Versioning Schema**

```dart
class CategoryLiveStateV2 extends CategoryLiveState {
  final Map<String, String> categoryColors;

  CategoryLiveStateV2({
    required super.order,
    required super.hidden,
    required super.counts,
    required this.categoryColors,
  });
}
```

Cette API documentation fournit tous les contrats nécessaires pour développer avec SmartMenu tout en maintenant la cohérence et la performance du système.
