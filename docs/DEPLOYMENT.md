# Guide de Déploiement SmartMenu

Ce guide couvre le déploiement de SmartMenu en production avec Firebase Hosting, la configuration sécuritaire et le monitoring.

## Prérequis Production

### Infrastructure

- **Projet Firebase** configuré avec plan Blaze (pay-as-you-go)
- **Domaine personnalisé** configuré (optionnel)
- **SSL/TLS** automatique via Firebase Hosting
- **CDN global** Firebase pour performance

### Outils Requis

```bash
# Vérifications pré-déploiement
firebase --version     # ≥ 13.0
flutter --version      # ≥ 3.16
gcloud --version       # Pour CORS Storage
```

## Configuration Production

### 1. Variables d'Environnement

#### Configuration Firebase

```dart
// lib/firebase_options.dart (généré par flutterfire)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIza...",                    // Public API key
    appId: "1:123456789:web:abcdef",     // Firebase App ID
    messagingSenderId: "123456789",      // FCM Sender ID
    projectId: "smartmenu-production",   // Projet production
    authDomain: "smartmenu-production.firebaseapp.com",
    storageBucket: "smartmenu-production.appspot.com",
  );
}
```

#### Configuration Hosting

```json
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "/index.html",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      },
      {
        "source": "/flutter_service_worker.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache, no-store, must-revalidate"
          }
        ]
      },
      {
        "source": "**/assets/**",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=3600"
          }
        ]
      },
      {
        "source": "**/*.@(woff2|woff|ttf)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

### 2. Sécurité Firestore Production

#### RBAC Rules Complètes (Corrigées)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Lecture publique menus/infos (clients PWA)
    match /restaurants/{rid}/menus/{itemId} {
      // CORRIGÉ: Lecture pour membres ET public si visible
      allow read: if isMember(rid) || resource.data.visible == true;
    }

    match /restaurants/{rid}/info/{docId} {
      allow read: if true;
    }

    // Gestion restaurants (authentifié + membre)
    match /restaurants/{rid} {
      // Info restaurant
      match /info/{docId} {
        allow create: if request.auth != null &&
                         request.resource.data.owner_uid == request.auth.uid;
        allow update, delete: if isOwner(rid);
      }

      // Menus
      match /menus/{itemId} {
        allow create, update, delete: if isMember(rid);
      }

      // Équipe restaurant
      match /members/{uid} {
        // CORRIGÉ: Owner/Manager peuvent lister l'équipe
        allow read: if isOwner(rid) || isManagerOrOwner(rid) ||
                       (request.auth != null && request.auth.uid == uid);
        allow create: if isOwner(rid);
        allow update, delete: if isOwner(rid) ||
                                 (request.auth.uid == uid &&
                                  request.resource.data.role == resource.data.role);
      }
    }

    // Collections utilisateur
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Helper functions
    function isMember(rid) {
      return request.auth != null &&
             exists(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid));
    }

    function isOwner(rid) {
      return isMember(rid) &&
             get(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid)).data.role == "owner";
    }

    function isManagerOrOwner(rid) {
      return isMember(rid) &&
             get(/databases/$(database)/documents/restaurants/$(rid)/members/$(request.auth.uid)).data.role in ["owner", "manager"];
    }
  }
}
```

#### Storage Rules Production

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Images restaurant (lecture publique)
    match /restaurants/{rid}/menu/{file=**} {
      allow read: if true;
      allow write: if request.auth != null && isMember(rid);
    }

    match /restaurants/{rid}/branding/{file=**} {
      allow read: if true;
      allow write: if request.auth != null && isOwner(rid);
    }

    match /restaurants/{rid}/media/{file=**} {
      allow read: if true;
      allow write: if request.auth != null && isMember(rid);
    }

    // Helper functions (dupliquées - Storage rules isolées)
    function isMember(rid) {
      return firestore.exists(/databases/(default)/documents/restaurants/$(rid)/members/$(request.auth.uid));
    }

    function isOwner(rid) {
      return isMember(rid) &&
             firestore.get(/databases/(default)/documents/restaurants/$(rid)/members/$(request.auth.uid)).data.role == "owner";
    }
  }
}
```

### 3. Configuration CORS Production

#### Storage CORS Production (Corrigé)

```bash
# Créer cors-production.json avec deux profils
cat > cors-production.json << EOF
[
  {
    "origin": [
      "https://smartmenu.com",
      "https://www.smartmenu.com",
      "https://smartmenu-production.web.app",
      "https://smartmenu-production.firebaseapp.com"
    ],
    "method": ["GET", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 86400,
    "responseHeader": ["Content-Type", "Content-Length", "Date", "Server"]
  },
  {
    "origin": [
      "https://smartmenu.com",
      "https://www.smartmenu.com",
      "https://smartmenu-production.web.app"
    ],
    "method": ["GET", "POST", "PUT", "HEAD", "OPTIONS"],
    "maxAgeSeconds": 3600,
    "responseHeader": ["Content-Type", "Content-Length", "x-goog-resumable"]
  }
]
EOF

# Appliquer CORS
firebase storage:bucket
gsutil cors set cors-production.json gs://PRODUCTION_BUCKET
```

#### Vérification CORS

```bash
# Test CORS depuis browser console
fetch('https://firebasestorage.googleapis.com/v0/b/BUCKET/o/test.jpg', {
  method: 'GET',
  mode: 'cors'
}).then(r => console.log('CORS OK')).catch(e => console.error('CORS Error', e));
```

### 4. Authentication Production

#### Domaines Autorisés

**Console Firebase > Auth > Settings > Authorized domains :**

- `smartmenu.com`
- `www.smartmenu.com`
- `smartmenu-production.web.app`
- `smartmenu-production.firebaseapp.com`

#### Configuration Avancée

```dart
// Configuration Auth production
class AuthConfig {
  static Future<void> configureAuth() async {
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: false,
      forceRecaptchaFlow: true,
    );
  }
}
```

## Build et Déploiement

### 1. Build Production

#### Préparation Build

```bash
# Clean build
flutter clean
flutter pub get

# Vérifications pré-build
flutter analyze
flutter test

# Désactiver emulators si activés
# Commenter toutes les lignes useFirestoreEmulator/useAuthEmulator
```

#### Build Optimisé

```bash
# Build production avec optimisations
flutter build web \
  --release \
  --web-renderer canvaskit \
  --tree-shake-icons \
  --source-maps \
  --split-debug-info=symbols

# Alternative léger mobile
flutter build web \
  --release \
  --web-renderer html \
  --tree-shake-icons
```

#### Vérification Build

```bash
# Analyser taille bundle
flutter build web --analyze-size

# Vérifier structure output
ls -la build/web/
du -sh build/web/

# Test local
cd build/web
python3 -m http.server 8080
# Ouvrir http://localhost:8080
```

### 2. Déploiement Firebase

#### Déploiement Standard

```bash
# Deploy hosting + rules
firebase deploy

# Deploy sélectif
firebase deploy --only hosting
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

#### Déploiement Preview

```bash
# Channel preview (testing)
firebase hosting:channel:deploy preview-v2 --expires 7d

# Test preview URL
# https://smartmenu-production--preview-v2-abcdef.web.app
```

#### Déploiement Production

```bash
# Deploy final avec backup
firebase use production
firebase deploy --only hosting

# Vérifier déploiement
curl -I https://smartmenu-production.web.app
```

#### Post-déploiement Service Worker

**Note importante :** Après un gros déploiement, les utilisateurs doivent forcer l'update du Service Worker :

1. Ouvrir l'app
2. Hard refresh (Ctrl+Shift+R ou Cmd+Shift+R)
3. Attendre que le nouveau SW s'active
4. Rechargez une fois de plus si nécessaire

### 3. Configuration CDN

#### Cache Headers

Les headers de cache dans `firebase.json` configurent :

- **Page principale** : Pas de cache (mise à jour immédiate)
- **Service Worker** : Pas de cache (mise à jour immédiate)
- **Assets statiques** : 1 an cache (`Cache-Control: public, max-age=31536000`)
- **JavaScript/CSS** : 1h cache (`Cache-Control: public, max-age=3600`)
- **Fonts** : 1 an cache (`Cache-Control: public, max-age=31536000`)

## Monitoring Production

### 1. Analytics Firebase

#### Configuration

```dart
// Configuration Analytics production
class AnalyticsConfig {
  static Future<void> initializeAnalytics() async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // Configuration propriétés globales
    await FirebaseAnalytics.instance.setDefaultEventParameters({
      'app_version': '2.7.0',
      'environment': 'production',
    });
  }
}
```

#### Events Critiques

```dart
// Events business critiques
class BusinessAnalytics {
  static void logMenuOpen(String restaurantId, {String? tableId}) {
    FirebaseAnalytics.instance.logEvent(
      name: 'menu_open',
      parameters: {
        'restaurant_id': restaurantId,
        'table_id': tableId ?? 'unknown',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  static void logOrderPlaced(String restaurantId, double total, int itemCount) {
    FirebaseAnalytics.instance.logEvent(
      name: 'order_placed',
      parameters: {
        'restaurant_id': restaurantId,
        'order_total': total,
        'item_count': itemCount,
        'currency': 'ILS',
      },
    );
  }
}
```

### 2. Performance Monitoring

#### Configuration

```dart
// Performance monitoring
class PerformanceConfig {
  static Future<void> initializePerformance() async {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

    // Traces custom
    final menuLoadTrace = FirebasePerformance.instance.newTrace('menu_load');
    menuLoadTrace.start();
    // ... opération
    menuLoadTrace.stop();
  }
}
```

#### Métriques Clés

- **Time to First Paint** : < 1.5s
- **First Contentful Paint** : < 2s
- **Largest Contentful Paint** : < 2.5s
- **Cumulative Layout Shift** : < 0.1

### 3. Error Reporting

#### Error Reporting

**Crashlytics (Mobile only - pas supporté Flutter Web)**

```dart
// Configuration Crashlytics
class ErrorReporting {
  static Future<void> initialize() async {
    // Web : utiliser Sentry ou autre service
    if (kIsWeb) {
      debugPrint('Crashlytics non supporté sur web - utiliser Sentry');
      return;
    }

    // Mobile uniquement
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void logError(dynamic error, StackTrace? stack, {String? context}) {
    if (kIsWeb) {
      // Web fallback
      debugPrint('ERROR: $error\nStack: $stack\nContext: $context');
      return;
    }

    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      context: context,
      fatal: false,
    );
  }
}
```

## Sécurité Production

### 1. Audit Sécurité

#### Checklist Pré-Production

```bash
# Audit rules Firestore
firebase firestore:rules:test --test-suite tests/firestore-rules.test.js

# Scan dépendances
flutter pub deps --style=list | grep -E "(CRITICAL|HIGH)"

# Audit JavaScript
npm audit --audit-level high
```

#### Validation Endpoints

```bash
# Test accès anonyme (doit fonctionner)
curl https://smartmenu-production.web.app/r/demo-restaurant

# Test admin sans auth (doit échouer)
curl https://smartmenu-production.web.app/admin
```

### 2. Backup et Recovery

#### Backup Firestore (Corrigé)

```bash
# Export automatique (configurer via Console)
gcloud firestore export gs://smartmenu-backups/$(date +%Y%m%d)

# Export manuel
gcloud firestore export gs://smartmenu-backups/manual-backup-$(date +%Y%m%d)
```

#### Recovery Plan

1. **Rollback Hosting** : `firebase hosting:rollback`
2. **Restore Firestore** : Import depuis backup le plus récent
3. **Notification** : Status page utilisateurs
4. **Post-mortem** : Analyse cause + prévention

### 3. Rate Limiting

#### Client-side Protection

```dart
// Throttling requêtes côté client
class RateLimiter {
  static final Map<String, DateTime> _lastCalls = {};

  static bool canMakeRequest(String key, Duration cooldown) {
    final now = DateTime.now();
    final lastCall = _lastCalls[key];

    if (lastCall == null || now.difference(lastCall) > cooldown) {
      _lastCalls[key] = now;
      return true;
    }

    return false;
  }
}

// Usage
if (RateLimiter.canMakeRequest('category_update', Duration(seconds: 2))) {
  await CategoryManager.updateCategory(...);
}
```

## Maintenance Production

### 1. Updates et Rollbacks

#### Stratégie Déploiement

```bash
# 1. Deploy sur preview channel
firebase hosting:channel:deploy staging --expires 24h

# 2. Tests complets sur staging
# - Smoke tests automatisés
# - Tests manuels fonctionnalités critiques
# - Performance benchmarks

# 3. Deploy production pendant heures creuses
firebase deploy --only hosting

# 4. Monitoring post-deploy (30 min)
# - Error rates
# - Performance metrics
# - User feedback

# 5. Rollback si nécessaire
firebase hosting:rollback
```

#### Rollback d'Urgence

```bash
# Rollback immédiat
firebase hosting:rollback

# Communication
echo "Service temporairement indisponible" > maintenance.html
firebase hosting:deploy --only maintenance.html

# Investigation
firebase projects:list
firebase use production
firebase hosting:releases:list
```

### 2. Scaling et Performance

#### Optimisations Firestore

```dart
// Connexions persistantes
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Batch operations pour bulk updates
Future<void> bulkUpdateMenus(List<MenuItem> items) async {
  final batch = FirebaseFirestore.instance.batch();

  for (int i = 0; i < items.length; i += 500) {
    final chunk = items.skip(i).take(500);
    for (final item in chunk) {
      batch.update(item.reference, item.toJson());
    }

    await batch.commit();
    batch = FirebaseFirestore.instance.batch(); // Nouveau batch
  }
}
```

#### Monitoring Coûts

```bash
# Monitoring quotas Firebase
firebase projects:info

# Alertes budget Google Cloud
gcloud alpha billing budgets list
```

### 3. Support Utilisateur

#### Logs Debug Production

```dart
// Logs structurés pour support
class ProductionLogging {
  static void logUserAction(String action, Map<String, dynamic> context) {
    FirebaseAnalytics.instance.logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
        'timestamp': DateTime.now().toIso8601String(),
        ...context,
      },
    );
  }
}
```

#### Debugging Production

```dart
// Remote config pour debug flags
class DebugConfig {
  static Future<bool> isDebugEnabled() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getBool('debug_mode_enabled');
  }
}
```

## Checklist Go-Live

### Pré-lancement

- [ ] Firestore rules RBAC complètes déployées
- [ ] Storage rules restrictives appliquées
- [ ] CORS production configuré
- [ ] Domaines autorisés configurés
- [ ] Build production testé localement
- [ ] Preview deploy validé par équipe
- [ ] Monitoring configuré (Analytics, Performance, Crashlytics)
- [ ] Backup automatique configuré
- [ ] Plan de rollback documenté

### Post-lancement

- [ ] Monitoring 30 min post-deploy
- [ ] Tests fumée sur fonctionnalités critiques
- [ ] Vérification métriques performance
- [ ] Documentation mise à jour
- [ ] Équipe support informée
- [ ] Status page mise à jour
- [ ] Service Worker mis à jour (hard refresh)

Cette documentation couvre tous les aspects critiques du déploiement production de SmartMenu avec un focus sur la sécurité, la performance et la maintenabilité.
