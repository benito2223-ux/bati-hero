# 📋 Bâti-Hero — Changelog

> App Flutter PWA — Comics/Pop Art aesthetic  
> 🌐 **Live** : https://bati-hero.surge.sh  
> 🛠️ Stack : Flutter 3.41.8 · Riverpod · go_router · fl_chart · shared_preferences

---

## [0.5.3] — 2026-07-07 · Fix articles non-ajoutables / non-cochables (mode connecté)

### 🐛 Bug critique corrigé
- **Symptôme** : une fois connecté avec Google, impossible d'ajouter un article ou de cocher une case dans Shop-Zap (et pareil en filigrane sur Money-Crunch, Projets, Prix-Hunter).
- **Cause racine** : tous les providers (`shopZapProvider`, `projectsProvider`, `moneyCrunchProvider`, `priceCompareProvider`) n'appliquaient les actions (ajout/suppression/toggle) **que sur le stream Firestore** quand un utilisateur est connecté — l'état local (`state`) n'était mis à jour qu'en réaction à l'écoute du listener Firestore. Or ce listener passe par un canal web ("Listen channel") qui peut rester instable (boucle de reconnexion) selon le réseau/proxy, empêchant toute mise à jour de revenir côté client — l'UI restait donc figée indéfiniment même si l'écriture avait réussi côté serveur.
- **Fix** : passage à une stratégie de **mise à jour optimiste** systématique dans les 4 providers — chaque action modifie l'état local ET la persistance locale immédiatement, puis déclenche l'écriture Firestore en tâche de fond (sans bloquer l'UI dessus). Le stream Firestore continue de tourner en arrière-plan pour la réconciliation multi-device, mais n'est plus le seul chemin vers une UI réactive.
- Confirmé en prod : ajout d'article et coche de checkbox instantanés (< 100ms), compteurs mis à jour immédiatement.

### 🔧 Technique
- `FirebaseFirestore.instance.settings` : `webExperimentalForceLongPolling: true` + `webExperimentalAutoDetectLongPolling: false` ajouté en prévention (fix standard FlutterFire pour les environnements réseau qui cassent l'auto-détection du canal Firestore Web)

---

## [0.5.2] — 2026-07-07 · Fix connexion Google (Firebase ne s'initialisait jamais)

### 🐛 Bug critique corrigé
- **Cause racine** : le fichier généré `web_plugin_registrant.dart` (`.dart_tool/`) était périmé — il datait d'avant l'ajout des dépendances Firebase et n'appelait jamais `FirebaseCoreWeb.registerWith(registrar)`. Résultat : Firebase ne s'initialisait JAMAIS sur le web (`PlatformException(channel-error, ... FirebaseCoreHostApi.initializeCore)`), et toute tentative de connexion Google échouait silencieusement (fallback vers mode local).
- **Fix** : `flutter clean` complet pour forcer la régénération de tous les fichiers de build, y compris le registrant des plugins web. Confirmé : `FirebaseCoreWeb`, `FirebaseAuthWeb`, `FirebaseFirestoreWeb`, `GoogleSignInPlugin` sont maintenant bien enregistrés.
- Log de confirmation en prod : `Initializing Firebase firebase_auth` (plus aucune erreur channel-error)

### 📝 Leçon
- Après tout ajout de dépendance Firebase/plugin natif, faire `flutter clean && flutter pub get` avant de rebuild — le cache incrémental de `.dart_tool/` peut ne pas régénérer le registrant de plugins web correctement.

---

## [0.5.1] — 2026-07-07 · Fix écran blanc / non-cliquable

### 🐛 Bug critique corrigé
- **Cause racine** : `appRouterProvider` était un `Provider<GoRouter>` qui se recréait entièrement à chaque changement de `authStateProvider` (StreamProvider). Ça détruisait tout l'arbre de navigation en cours — y compris le `SplashScreen` en pleine animation — provoquant `AnimationController.forward() called after dispose()`. L'app plantait silencieusement juste après l'ouverture, d'où "s'ouvre mais rien n'est cliquable".
- **Fix** : le `GoRouter` est maintenant créé UNE SEULE FOIS pour toute la durée de vie de l'app (`GoRouterRefreshStream` — un `ChangeNotifier` qui pilote `router.refresh()` sans jamais recréer l'objet `GoRouter`). L'état d'auth est lu via `ref.read` (jamais `.watch`) dans `redirect`.
- `authStateProvider` ne plante plus si Firebase échoue à s'initialiser (fallback `Stream.value(null)`)
- `main.dart` : `runZonedGuarded` + `FlutterError.onError` pour logger proprement toute erreur future au lieu de crasher silencieusement
- CanvasKit chargé depuis les fichiers locaux (`canvaskit/`) plutôt que le CDN externe gstatic.com — évite un blocage par pare-feu/bloqueur de pub qui empêcherait Flutter Web de peindre son premier frame

### 🔧 Technique
- `lib/router/app_router.dart` réécrit avec `GoRouterRefreshStream`
- `lib/features/auth/providers/auth_provider.dart` : `authChangesStream()` exposé en fonction brute (hors Riverpod) pour servir de `refreshListenable`
- `web/flutter_bootstrap.js` personnalisé : `canvasKitBaseUrl: "canvaskit/"`

---

## [0.5.0] — 2026-05-19 · Mode collaboratif Firebase 🔥

### ✅ Ajouté
- **Google Sign-In** avec écran de login Comics/Pop Art
- **Firebase Auth** — authStateProvider (StreamProvider) + AuthService
- **Firestore sync temps réel** sur tous les providers :
  - `projectsProvider` → `/users/{uid}/projects`
  - `shopZapProvider` → `/users/{uid}/shopItems`
  - `moneyCrunchProvider` → `/users/{uid}/expenses` + `/users/{uid}/meta/settings`
  - `priceCompareProvider` → `/users/{uid}/priceEntries`
- **Migration automatique** : données locales pushées vers Firestore au premier login
- **Déconnexion** : avatar + menu dans ProjectListScreen
- **Auth redirect** dans go_router : non connecté → `/login`, connecté → `/`

### 🔧 Technique
- Firebase v3.x (core ^3.4.1, auth ^5.1.0, firestore ^5.4.0) compatible geolocator v13
- `appRouter` migré en `appRouterProvider` (Provider<GoRouter>) pour lire authStateProvider
- `FirestoreService` centralisé avec streams + CRUD + migration batch
- `unawaited()` pour les initialisations async dans les constructeurs StateNotifier

---

## [0.4.0] — 2026-05-19 · Comparateur de prix PRIX-HUNTER 🎯

### ✅ Ajouté
- **PriceCompareScreen** — 5ème onglet "PRIX" dans la bottom nav
- Création de comparaison : scan code-barres ou saisie manuelle du nom produit
- Entrée de prix par magasin (Leroy Merlin, Castorama, Brico Dépôt, Mr Bricolage, Amazon)
- Bouton "ouvrir le site" par magasin → cherche le produit directement
- Bar chart fl_chart comparatif avec meilleur prix en vert
- Badge économies calculé automatiquement (pire prix - meilleur prix)
- Bannière stats : nb produits comparés + total économies potentielles
- Persistance locale via `LocalStorageService.kPriceEntries`
- `PriceEntry` model avec `StorePrice` + `toJson`/`fromJson`
- `PriceCompareNotifier` StateNotifier avec `setStorePrice`, `addEntry`, `removeEntry`

### 🔧 Technique
- Nouveau modèle `ComparatorStore` avec couleurs de marque + URLs de recherche
- 5ème branche dans `StatefulShellRoute.indexedStack` → `/price-hunter`
- Bottom nav mis à jour (5 onglets)

---

## [0.3.0] — 2026-05-19 · Persistance locale + sync préparée

### ✅ Ajouté
- **Persistance locale** (`shared_preferences`) sur tous les devices
  - Projets, articles de courses, dépenses, budget survivent aux rechargements
  - Dernier projet sélectionné restauré automatiquement au démarrage
- `LocalStorageService` — service centralisé avec clés typées
- `toJson` / `fromJson` sur tous les modèles (`Project`, `ShoppingItem`, `Expense`)
- `currentProjectProvider` migré en `StateNotifierProvider` avec persistence du dernier projet

### 🔧 Technique
- `LocalStorageService.init()` appelé dans `main()` avant `runApp`
- `.gitignore` mis à jour (Firebase secrets exclus)
- Repo GitHub initialisé

---

## [0.2.0] — 2026-05-19 · 5 features Tier 1/2/3

### ✅ Ajouté
- **Multi-projets** (Tier 1)
  - `ProjectListScreen` — grille de chantiers avec couleur/emoji/nom
  - Création de chantier : 18 emojis, 6 couleurs néon, nom libre
  - Bannière contexte dans chaque écran → tap pour changer de chantier
  - Suppression avec confirmation (long press)
- **Stats & Graphiques** (Tier 2) dans Money-Crunch
  - Tab "STATS" : pie chart par catégorie + bar chart 6 derniers mois (fl_chart)
  - Barres de progression par catégorie avec montants
  - Tab "TICKETS" : galerie photo des tickets avec vue plein écran interactive
- **Scan codes-barres** (Tier 3)
  - `BarcodeScannerScreen` avec MobileScanner
  - Lookup Open Food Facts API → fallback UPC Item DB
  - Résultat éditable avant ajout dans "Liste libre"
- **Localisation magasins** (Tier 3)
  - `StoreLocatorScreen` : 5 enseignes avec couleurs de marque
  - GPS via geolocator → ouvre Google Maps avec coordonnées
- **Photos tickets de caisse**
  - Bouton 📋 dédié dans Money-Crunch → caméra directe
  - Miniature visible dans la liste des dépenses
  - Galerie dans l'onglet "TICKETS"

### 🔧 Améliorations
- `ShopZapScreen` : bouton scanner 🔍 FAB + bouton magasins 🏪 dans l'AppBar
- `MoneyCrunchScreen` : transformé en `ConsumerStatefulWidget` avec TabController
- `MainScaffold` migré en `ConsumerWidget` pour afficher le projet courant
- Splash navigue vers `/` (ProjectListScreen) au lieu de `/shop-zap`
- Router : route `/` ajoutée pour `ProjectListScreen`

### 🐛 Bugs corrigés
- Import http mal formé dans `barcode_scanner_screen.dart`
- `AppColors.error` → `AppColors.danger`

---

## [0.1.0] — 2026-05-19 · MVP initial

### ✅ Fonctionnalités
- **Shop-Zap** : liste de courses par enseigne + liste libre, progress bar, swipe to delete, ComicCheckbox
- **Money-Crunch** : budget + jauge colorée, liste des dépenses par catégorie
- **Chrono-Planning** : calendrier semaine, cartes événements avec badge temps de séchage
- **Hero-Feed** : galerie photo avant/pendant/après chantier, filtres, image_picker

### 🎨 Design system
- Couleurs : `electricYellow #CCFF00` · `neonPink #FF00FF` · `neonCyan #00FFFF` · `bgDeep #0D0D12`
- Fonts : Bangers (titres) + Montserrat (corps) via google_fonts
- Widgets : `ComicCard`, `ComicButton`, `ComicCheckbox`, `PowerBadge`, `HeroAppBar`
- Splash screen animé avec halftone background painter

### 🏗️ Architecture
- Flutter Web (PWA installable)
- Riverpod `StateNotifierProvider` pour tous les états
- `go_router` avec `StatefulShellRoute.indexedStack` (4 branches)
- Firebase préparé (commenté — en attente de `flutterfire configure`)

### 🚀 Déploiement
- Build : `flutter build web --release --no-wasm-dry-run`
- Deploy : `npx surge build/web bati-hero.surge.sh`

---

## Roadmap

### 🔥 Prochain — Firebase sync temps réel
- `flutterfire configure` → génère `firebase_options.dart`
- Firestore collections : `projects`, `shopItems`, `expenses`
- Auth Google pour multi-utilisateurs
- Données sync entre tous les devices en temps réel

### 💡 Idées futures
- Saisie vocale (speech_to_text déjà installé)
- OCR tickets de caisse (ML Kit)
- Sync Google Calendar (chrono)
- Mode hors-ligne complet
- Notifications push (délais de séchage)
