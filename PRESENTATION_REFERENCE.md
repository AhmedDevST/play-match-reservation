# Play Match Reservation - Guide de Présentation

## 📌 Intro 

Play Match Reservation est une **plateforme de réservation sportive** complète : les utilisateurs peuvent découvrir des installations, réserver des créneaux, créer des équipes et gérer des matchs en temps réel.

**Architecture** : Backend Laravel 12 + Frontend Flutter pour une expérience seamless.

---

# 🔧 PARTIE 1 : BACKEND (Laravel 12)

## 1️⃣ Architecture Générale

```
Clients (Flutter)
        ↓ HTTP API
    [Laravel API]
        ├── Authentification (Sanctum)
        ├── Réservations
        ├── Matchs & Équipes
        ├── Notifications
        └── Installations sportives
        ↓
    [Base de Données]
```

**Stack** : Laravel 12 + Sanctum (API tokens) + Eloquent ORM

---

## 2️⃣ Authentification (Sanctum)

### Concept
Chaque utilisateur reçoit un **token unique** pour accéder à l'API sans sessions HTTP.

### Flux
```
1. POST /login → Vérifie email + password
2. Retourne API token
3. Client envoie token dans header : Authorization: Bearer {token}
4. Laravel valide le token → Accès autorisé
```

### Bonnes Pratiques Appliquées
✅ **Stateless** - Pas de sessions, scalable horizontalement  
✅ **Sécurisé** - Tokens hashés en BD, expiration possible  
✅ **Flexible** - Multi-device support (chaque device = 1 token)

### Middleware
```php
Route::middleware('auth:sanctum')->group(function () {
    // Toutes les routes protégées ici
});
```

---

## 3️⃣ Système de Réservation

### Modèle Relationnel
```
Utilisateur
    ↓
Réservation (1-Many)
    ├── sport_facility_id → Installation
    ├── time_slot_id → Créneau
    ├── status (pending, confirmed, cancelled)
    └── created_at
```

### Flux Principal
```
1. Utilisateur choisit installation + créneau
2. POST /reservations
3. Vérifier : créneau libre ? utilisateur authentifié ? paiement OK ?
4. Créer réservation → État pending
5. Notifier gestionnaire installation
```

### Choix Techniques
- **Atomicité** : Vérification + création en une transaction BD
- **Concurrence** : Lock pessimiste sur TimeSlot pour éviter overbooking
- **Audit Trail** : Chaque modification loggée (created_at, updated_at, deleted_at)

### Code Exemple
```php
// app/Models/Reservation.php
class Reservation extends Model {
    protected $fillable = ['user_id', 'facility_id', 'time_slot_id', 'status'];
    
    public function user() {
        return $this->belongsTo(User::class);
    }
    
    public function timeSlot() {
        return $this->belongsTo(TimeSlot::class);
    }
}
```

---

## 4️⃣ Système de Matchs & Équipes

### Architecture

```
Équipe
  ├── Owner (User)
  ├── Members (Many-to-Many)
  └── Matchs (1-Many)

Match
  ├── Équipe1
  ├── Équipe2
  ├── Installation + TimeSlot
  ├── Invitations (aux joueurs)
  └── Statut (scheduled, playing, finished, cancelled)
```

### Processus de Création Match
```
1. Leader crée match → attache équipe + créneau
2. Match généré avec status "scheduled"
3. Invitations créées pour chaque joueur
4. Notifications pushées aux joueurs
5. À la date, statut → "playing" → "finished"
```

### Gestion des Membres d'Équipe
**Pivot Table** : `team_player`
```php
class Team extends Model {
    public function players() {
        return $this->belongsToMany(User::class)
                    ->withPivot('role') // role: captain, player
                    ->withTimestamps();
    }
}
```

### Bonnes Pratiques
✅ **Polymorphism** : Equipes = réutilisables (friendly, ligue, club)  
✅ **Soft Delete** : Matchs conservés pour historique  
✅ **Timestamps** : Traçabilité complète

---

## 5️⃣ Système de Notifications

### Architecture Simple

```
Event Déclenché (ex: Match créé)
    ↓
NotificationService (Logic)
    ↓
Database (stocké + indexé)
    ↓
Flutter (récupère via GET /notifications)
```

### Types de Notifications
- 🎫 **Invitation** : "Tu es invité au match de football samedi"
- ✅ **Confirmation** : "Votre réservation est confirmée"
- 📢 **Rappel** : "Match dans 2 heures"
- ⚠️ **Annulation** : "Le match a été annulé"

### Modèle
```php
class Notification extends Model {
    protected $fillable = [
        'user_id', 'type', 'title', 'message', 'read_at', 'data'
    ];
    
    public function user() {
        return $this->belongsTo(User::class);
    }
}
```

### API Endpoints
```
GET /notifications              → Récupère toutes les notifs
GET /notifications?read=false   → Seulement non-lues
POST /notifications/{id}/read   → Marquer comme lue
DELETE /notifications/{id}      → Supprimer
```

### Bonnes Pratiques
✅ **Lazy Loading** : Pagination pour grandes listes  
✅ **Indexation** : Index sur `user_id` + `read_at`  
✅ **Archivage** : Old notifications (>90j) nettoyées

---

## 🎯 Résumé Backend

| Aspect | Solution | Bénéfice |
|--------|----------|----------|
| **Auth** | Sanctum (tokens) | Scalable, multi-device |
| **Data Integrity** | Transactions + Locks | Zéro overbooking |
| **Traçabilité** | Timestamps + Soft Delete | Historique complet |
| **Notifications** | Eager Design | Notifications centralisées |

---

---

# 📱 PARTIE 2 : FRONTEND (Flutter)

## 1️⃣ Architecture State Management

### Évolution : Provider → Riverpod
```
Provider (ancienne approche)
    └─ Rigide, pas de dépendance entre providers

Riverpod (approche moderne)
    └─ Flexible, dependency injection, meilleure testabilité
```

### Pourquoi Riverpod ?
✅ **Réactivité** : Auto-rebuild quand les dépendances changent  
✅ **Composabilité** : Providers dépendent d'autres providers  
✅ **Testing** : Facile de mocker les dépendances  

---

## 2️⃣ Modèles Flutter

### Architecture Dossier
```
lib/models/
  ├── user.dart
  ├── Sport.dart
  ├── SportFacility.dart
  ├── TimeSlot.dart
  ├── Reservation.dart
  ├── Team.dart
  ├── TeamPlayer.dart
  ├── Game.dart
  ├── Invitation.dart
  └── Notification.dart
```

### Modèles Clés (Code Simplifié)

#### User
```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final List<Team> teams;
}
```

#### Reservation
```dart
class Reservation {
  final String id;
  final User user;
  final SportFacility facility;
  final TimeSlot timeSlot;
  final ReservationStatus status; // pending, confirmed, cancelled
  final DateTime createdAt;
}
```

#### Team & TeamPlayer
```dart
class Team {
  final String id;
  final String name;
  final User owner;
  final List<TeamPlayer> members;
}

class TeamPlayer {
  final User user;
  final String role; // captain, player
  final DateTime joinedAt;
}
```

#### Game (Match)
```dart
class Game {
  final String id;
  final Team team1;
  final Team team2;
  final SportFacility facility;
  final TimeSlot timeSlot;
  final GameStatus status; // scheduled, playing, finished
  final DateTime createdAt;
}
```

#### Notification
```dart
class Notification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;
}
```

---

## 3️⃣ Providers Riverpod (⭐ Très Important)

### Architecture Providers

```
authProvider (User connecté)
    ↓
reservationsProvider
    ├─ Dépend de authProvider
    └─ Récupère réservations de l'user

gamesProvider
    ├─ Dépend de authProvider
    └─ Récupère matchs de l'user

teamsProvider
    ├─ Dépend de authProvider
    └─ Récupère équipes de l'user

notificationsProvider
    └─ Dépend de authProvider
```

### Exemple : Auth Provider
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

### Exemple : Réservations Provider
```dart
final reservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  final user = ref.watch(authProvider); // Dépendance !
  
  return user.when(
    data: (u) => ApiService.getReservations(u.id),
    loading: () => [],
    error: (err, stack) => throw err,
  );
});
```

### Exemple : État Mutable (StateNotifier)
```dart
final gameCreationProvider = StateNotifierProvider<GameNotifier, AsyncValue<Game?>>((ref) {
  return GameNotifier(ref);
});

class GameNotifier extends StateNotifier<AsyncValue<Game?>> {
  GameNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createGame(Game game) async {
    state = const AsyncValue.loading();
    try {
      final created = await ApiService.createGame(game);
      state = AsyncValue.data(created);
      ref.refresh(gamesProvider); // Refresh la liste des games
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
```

### Bonnes Pratiques Riverpod
✅ **Family Modifier** : Paramétrer un provider
```dart
final gameProvider = FutureProvider.family<Game, String>((ref, gameId) async {
  return ApiService.getGame(gameId);
});
```

✅ **Select** : Écouter uniquement une partie
```dart
final userNameProvider = ref.watch(authProvider.select((user) => user?.name));
```

✅ **Combine** : Dépendre de plusieurs providers
```dart
final userGamesProvider = FutureProvider((ref) async {
  final user = ref.watch(authProvider);
  final games = ref.watch(gamesProvider);
  return games.where((g) => g.team1.members.contains(user)).toList();
});
```

---

## 4️⃣ Pages & Widgets Clés

### Architecture Pages
```
lib/presentation/pages/
  ├── login_page.dart
  ├── home_page.dart
  ├── facilities_page.dart
  ├── reservation_detail_page.dart
  ├── team_page.dart
  ├── game_creation_page.dart
  ├── notifications_page.dart
  └── profile_page.dart
```

### Flow Navigation Principal
```
SplashScreen (Auth Check)
    ↓
LoginPage (Authentification)
    ↓
HomePage (Hub central)
    ├─ FacilitiesPage
    ├─ MyReservationsPage
    ├─ MyTeamsPage
    ├─ MyGamesPage
    └─ NotificationsPage
```

### Widget Exemple : ReservationListWidget
```dart
class ReservationListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservations = ref.watch(reservationsProvider);
    
    return reservations.when(
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (ctx, idx) => ReservationCard(items[idx]),
      ),
      loading: () => const LoadingShimmer(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

---

## 5️⃣ Bonnes Pratiques Flutter

### ✅ État & UI
- **AsyncValue** : Gère loading/data/error élégamment
- **ConsumerWidget** : Accès aux Riverpod providers
- **Séparation** : Logic en Notifier, UI en Widget

### ✅ Performance
- **Lazy Loading** : ListView.builder au lieu de ListView
- **Caching** : SharedPreferences pour données fréquentes
- **Image Caching** : CachedNetworkImage pour photos

### ✅ UX
- **Animations** : Lottie pour splashscreen fluide
- **Feedback** : Toasts + Snackbars pour confirmation
- **Offline Support** : Local cache quand réseau absent

---

## 🎯 Perspectives Flutter

### Court Terme
- ✅ Push Notifications (Firebase Cloud Messaging)
- ✅ Géolocalisation installations (Google Maps)
- ✅ Mode dark theme complet
- ✅ Tests unitaires (flutter test)

### Moyen Terme
- 🎬 Live Scoring des matchs
- 📊 Dashboard statistiques utilisateur
- 💬 Chat en temps réel (WebSocket)
- 🗓️ Sync Google Calendar

---

---

# 🔗 PARTIE 3 : Intégration Backend ↔ Frontend

## Architecture API Communication

```
Flutter                         Laravel
  │                                │
  ├─ HTTP Client ──────────────→ API REST
  │                                │
  ├─ Riverpod Providers ←─────── JSON Responses
  │                                │
  ├─ Local Cache ←──────────────── Data
  │                                │
  └─ UI Rebuild                    DB Storage
```

## Flux Complet : Créer une Réservation

### Étape 1 : Frontend (Flutter)
```dart
// 1. User clique "Réserver"
// 2. Riverpod appelle le provider de réservation
final result = await ref.read(createReservationProvider).createReservation(
  facilityId: '123',
  timeSlotId: '456',
);
```

### Étape 2 : Backend (Laravel)
```php
// 1. POST /api/reservations
// 2. Sanctum authentifie via token
// 3. Valide données
$validated = $request->validate([
    'facility_id' => 'required|exists:facilities',
    'time_slot_id' => 'required|exists:time_slots',
]);

// 4. Crée réservation en transaction
DB::transaction(function () {
    $reservation = Reservation::create($validated);
    Notification::create([
        'user_id' => auth()->id(),
        'type' => 'confirmation',
        'message' => 'Réservation confirmée !'
    ]);
});
```

### Étape 3 : Retour Frontend
```dart
// 1. Reçoit Reservation JSON
// 2. Riverpod parse et met en cache
// 3. UI se rebuild automatiquement
// 4. Confirmation affichée à l'user
```

---

## Sécurité de la Communication

### ✅ Authentification
- Token Sanctum en header `Authorization: Bearer {token}`
- Token révoqué à logout

### ✅ Validation
- **Backend** : Valide TOUTES les données (email, IDs, permissions)
- **Frontend** : Valide pour UX (format email, champs requis)

### ✅ Protection
- CORS configuré (only trusted origins)
- Rate limiting sur endpoints sensibles
- Soft delete pour audit trail

---

## Exemple : Récupérer Notifications

### Frontend Riverpod
```dart
final notificationsProvider = FutureProvider((ref) async {
  return ApiService.getNotifications();
});

// Widget
ref.watch(notificationsProvider).when(
  data: (notifs) => NotificationList(notifs),
  loading: () => Shimmer(),
  error: (err) => ErrorWidget(),
);
```

### Backend Laravel
```php
// GET /api/notifications
public function index(Request $request) {
    return $request->user()
        ->notifications()
        ->latest()
        ->paginate(20);
}
```

---

---

# 📊 Résumé Présentation

| Layer | Technologie | Rôle |
|-------|-------------|------|
| **API** | Laravel 12 + Sanctum | Authentification, Business Logic, BD |
| **State** | Riverpod | Gestion réactive de l'état |
| **Models** | Dart Classes | Représentation des données |
| **UI** | Flutter Widgets | Présentation & Interaction |

---

# 🎯 Points Clés à Retenir

1. **Architecture** : Clean separation entre business logic (Laravel) et UI (Flutter)
2. **État** : Riverpod pour dépendances automatiques et testabilité
3. **Sécurité** : Sanctum + Validation stricte backend
4. **Scalabilité** : Transactions, locks, indexation pour éviter les race conditions
5. **UX** : Notifications en temps réel, offline support, caching intelligent

---

**Durée présentation suggérée** : 15-20 minutes (adapter selon questions)

**Questions probables** :
- "Comment gérez-vous les race conditions ?" → Locks + Transactions
- "Pourquoi Riverpod ?" → Meilleure composabilité que Provider
- "Comment testiez-vous ?" → Unit tests (Pest), UI tests (Flutter test)
- "Scalabilité ?" → Caching, pagination, indexation BD, load balancing

---
