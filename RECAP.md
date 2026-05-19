# 📋 Bâti-Hero — Changelog

> App Flutter PWA — Comics/Pop Art aesthetic  
> 🌐 **Live** : https://bati-hero.surge.sh  
> 🛠️ Stack : Flutter 3.41.8 · Riverpod · go_router · fl_chart · shared_preferences

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
