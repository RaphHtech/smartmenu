# Changelog

### v2.7.1 - Gestion Catégories Premium (Septembre 2025)

**Modal CategoryManagerSheet enterprise :**

- **Interface responsive** : Dialog desktop + Bottom sheet mobile optimisé
- **Drag & drop fluide** : Réorganisation par poignées gauches uniquement
- **Actions complètes** : Masquer/afficher, renommer avec confirmation, suppression
- **Auto-sauvegarde** : Indicateur d'état temps réel (saving/saved/error)
- **Header adaptatif** : Layout mobile/desktop pour éviter overflow
- **Validation tactile** : Support clavier mobile + tap externe pour validation

**Architecture technique :**

- **SafeArea optimisé** : Gestion correcte des notches iOS/Android
- **Stream synchronisé** : État live partagé entre modal et dashboard
- **Gestion d'erreurs** : Rollback optimiste + feedback utilisateur
- **Performance** : Une seule zone scrollable, padding calculé dynamiquement

## [2.7.0] — 2025-09-18

### Added

- Interface de réorganisation des catégories (premium UX : drag & hide, feedback d'état).

### Changed

- README nettoyé (CORS/Bucket cohérents, backticks, badges, ToC).
- Nommage doc unifié `{restaurantId}`.

### Fixed

- Exemples CORS et bucket (`gs://<project-id>.appspot.com`) cohérents.

## [2.6.1] — 2025-09-xx

- Rollback stabilisation + optimisations performance.

## [2.6.0] — 2025-08-xx

- Branding professionnel (logo + fallback intelligent).
