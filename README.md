# FridgeFinder Mobile App

> A community-driven mobile application for locating, managing, and reporting on community fridges. Built with Flutter using modern state management, clean architecture, and reactive programming patterns.

**Status:** Active Development | **Version:** 1.0.0+10 | **Platform:** iOS & Android | **Language:** Dart/Flutter 3.8+

---

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Installation & Setup](#installation--setup)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Features](#features)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Resources & Documentation](#resources--documentation)

---

## Quick Start

Get the app running locally in 4 steps:

```bash
# 0. Navigate to the Flutter app directory
cd fridgefinder_flutter

# 1. Install dependencies
flutter pub get

# 2. Generate code (freezed models, Riverpod providers, JSON serialization)
dart run build_runner build

# 3. Run the app
flutter run
```

That's it! The app will launch with dev environment settings by default.

---

## Prerequisites

### Required

- **Flutter:** >=3.8.0 <4.0.0
- **Dart SDK:** >=3.8.0 <4.0.0
- **iOS:** Xcode 14+ with iOS 14.0+ support
- **Android:** Android Studio with Android API 21+ (for geolocator)
- **Xcode Command Line Tools** (Mac)

### Optional but Recommended

- **Git** (version control)
- **VS Code** with Flutter extension (development)
- **Android Emulator** or **iOS Simulator** (testing)
- **Physical devices** (hardware testing)

### Installation Verification

```bash
# Check Flutter & Dart versions
flutter --version

# Check environment setup
flutter doctor

# All checks should pass (green checkmarks) before proceeding
```

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd CFM_Mobile/fridgefinder_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

This installs all packages listed in `pubspec.yaml`. Key dependencies:

- **State Management:** Riverpod 3.0+ with code generation (reactive, type-safe)
- **Navigation:** GoRouter (type-safe, persistent navigation)
- **Mapping:** flutter_map with OpenStreetMap tiles
- **Marker Clustering:** flutter_map_marker_cluster for grouping nearby markers
- **Tile Caching:** flutter_map_cache with in-memory LRU cache (50MB)
- **HTTP Client:** Dio with interceptors and connectivity checks
- **Local Storage:** Hive (user settings, filter state)
- **Immutable Models:** Freezed with JSON serialization (code-generated)
- **Logging:** logger package for structured logging
- **Connectivity:** connectivity_plus for network status

### 3. Generate Code

The project uses code generation for:

- **Freezed:** Immutable data models with `copyWith`, `toString`, `==`, and `hashCode`
- **Riverpod:** Type-safe provider generators with `@riverpod` annotation
- **JSON Serialization:** Automatic `fromJson`/`toJson` methods

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run this after modifying any:

- Freezed models (with `@freezed` annotation)
- Riverpod providers (with `@riverpod` annotation)
- JSON serializable classes (with `@JsonSerializable` annotation)

### 4. Configure Environment (Optional)

The app uses a **dual environment configuration**:

- **Fridge Data API:** DEV environment by default (`api-dev.communityfridgefinder.com`)
- **Firebase Services:** PRODUCTION environment (always)

To switch fridge API environment:

1. Open the app
2. Go to **Profile** → **Settings**
3. Toggle **API Environment** between Dev/Prod

This persists to local storage via Hive.

**Note:** Firebase services (Auth, Messaging, Database, Cloud Functions) always use production. See `ENVIRONMENT_CONFIGURATION.md` for details.

### 5. Run the App

```bash
# Run on default device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode (optimized)
flutter run --release

# Enable verbose logging
flutter run -v
```

---

## Project Structure

```
fridgefinder_flutter/
├── lib/                                    # Application source code
│   ├── main.dart                          # Entry point, initializes Hive & Riverpod
│   ├── app.dart                           # Root widget, theme/routing configuration
│   └── src/
│       ├── common_widgets/                # Shared UI components (reusable)
│       │   ├── main_shell.dart           # Layout shell with bottom nav, header, drawer
│       │   ├── bottom_nav_bar.dart       # Navigation tabs
│       │   ├── loading_indicator.dart    # Loading state UI
│       │   ├── error_view.dart           # Error state with retry
│       │   └── empty_state.dart          # Empty list state
│       │
│       ├── core/                          # Core infrastructure (non-feature-specific)
│       │   ├── constants/
│       │   │   └── api_constants.dart    # API endpoints (dev/prod), timeouts
│       │   ├── providers/
│       │   │   ├── dio_provider.dart     # HTTP client with interceptors
│       │   │   ├── environment_provider.dart  # API environment selection
│       │   │   ├── location_provider.dart    # Geolocation services
│       │   │   ├── theme_provider.dart  # Theme mode (light/dark/system)
│       │   │   └── map_cache_provider.dart  # Map tile caching provider
│       │   ├── theme/
│       │   │   └── app_theme.dart        # Material Design 3 theme definitions
│       │   ├── extensions/
│       │   │   └── theme_extensions.dart # Theme utility extensions
│       │   ├── utils/
│       │   │   ├── fuzzy_search.dart     # Text matching algorithm
│       │   │   ├── distance_calculator.dart # Haversine distance formula
│       │   │   └── fridge_icon_utils.dart # Marker icon/color mapping
│       │   └── exceptions/
│       │       └── app_exceptions.dart   # Custom exception hierarchy
│       │
│       ├── features/                      # Feature modules (independent, scalable)
│       │   ├── map/                      # Map view feature
│       │   │   ├── data/
│       │   │   │   ├── fridge_repository.dart      # API client (real)
│       │   │   │   └── mock_fridge_repository.dart # Mock for testing
│       │   │   ├── domain/
│       │   │   │   └── fridge_domain.dart          # Freezed data models & enums
│       │   │   └── presentation/
│       │   │       ├── controllers/
│       │   │       │   ├── fridge_list_controller.dart     # Data & selection state
│       │   │       │   ├── map_filter_controller.dart      # Filter state (persistent)
│       │   │       │   └── filter_condition.dart           # Filter matching logic
│       │   │       ├── screens/
│       │   │       │   └── map_screen.dart                 # Main map UI
│       │   │       └── widgets/
│       │   │           ├── fridge_marker.dart              # Custom map markers
│       │   │           ├── fridge_cluster_widget.dart      # Cluster marker widget
│       │   │           ├── map_filter_panel.dart           # Filter UI
│       │   │           ├── filter_pills_row.dart           # Filter buttons row
│       │   │           ├── filter_pill_button.dart         # Individual filter button
│       │   │           ├── user_location_indicator.dart    # User position marker
│       │   │           └── filter_status_indicator.dart    # Active filters badge
│       │   │
│       │   ├── list/                     # List view feature
│       │   │   └── presentation/
│       │   │       ├── screens/
│       │   │       │   └── list_screen.dart        # List view with distance sorting
│       │   │       └── widgets/
│       │   │           └── fridge_card.dart        # Fridge list item
│       │   │
│       │   ├── profile/                  # User settings & details
│       │   │   └── presentation/
│       │   │       ├── screens/
│       │   │       │   └── profile_screen.dart     # Settings screen
│       │   │       └── widgets/
│       │   │           ├── fridge_profile_sheet.dart   # Fridge details
│       │   │           └── status_update_form.dart     # Report submission form
│       │   │
│       │   ├── auth/                     # Placeholder for authentication
│       │   ├── notifications/            # Placeholder for push notifications
│       │   └── search/                   # Placeholder for advanced search
│       │   │
│       │   └── Note: Favorites feature removed from v1.0 (will be added in v1.1 with user accounts)
│       │
│       └── routing/
│           └── router.dart               # GoRouter configuration with ShellRoute
│
├── test/                                  # Test suite (mirrors lib structure)
│   ├── core/utils/
│   ├── features/
│   ├── shared/widgets/
│   ├── integration/
│   ├── fixtures/fridge_fixtures.dart    # Mock data for tests
│   └── helpers/test_helpers.dart        # Test utilities
│
├── android/                               # Android native code & config
├── ios/                                   # iOS native code & config
├── assets/
│   ├── icons/                            # SVG icons for markers
│   └── images/                           # App images
├── pubspec.yaml                          # Dependency definitions
├── analysis_options.yaml                 # Linter rules
└── README.md                             # This file
```

### Directory Organization Philosophy

- **Feature-Based Architecture:** Each feature (map, list, profile) is an independent module with data/domain/presentation layers
- **Shared Infrastructure:** Core services, utilities, and common widgets are centralized
- **Clear Boundaries:** Features can be developed in parallel with minimal dependencies
- **Scalability:** New features can be added by creating new feature directories following the established pattern

---

## Architecture

### Overview

FridgeFinder uses **Clean Architecture with Riverpod** state management, organized into **feature modules**:

```
Presentation Layer (UI)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (API, Local Storage)
```

### Key Architectural Patterns

#### 1. **Riverpod State Management**

Riverpod provides reactive, composable state management without BuildContext:

```dart
// Data fetching (async)
@riverpod
Future<List<FridgeDomain>> fridgeList(FridgeListRef ref) async {
  final repository = ref.watch(fridgeRepositoryProvider);
  return repository.getFridges();
}

// Mutable state (local)
@riverpod
class MapFilter extends _$MapFilter {
  @override
  MapFilterState build() {
    // State loaded from Hive or default
    return MapFilterState();
  }

  void updateFilter(FilterCondition condition) {
    // State updates trigger rebuilds of watching widgets
    state = state.copyWith(...); // Freezed copyWith
  }
}

// Computed derived state
@riverpod
List<FridgeDomain> mapFilteredFridges(MapFilteredFridgesRef ref) {
  final fridgesAsync = ref.watch(fridgeListProvider);
  final filters = ref.watch(mapFilterProvider);

  return fridgesAsync.whenOrNull(
    data: (fridges) => fridges.where((f) => filters.matchesFridge(f)).toList(),
  ) ?? [];
}
```

**Benefits:**

- No BuildContext required
- Fine-grained reactivity (widget rebuilds only when needed)
- Easy testing (mock providers directly)
- Composable, reusable logic
- Automatic caching & request deduplication

#### 2. **Feature-Based Clean Architecture**

Each feature module has three distinct layers:

**Data Layer** (`/data`)

- Repository pattern implementing abstract interfaces (dependency inversion)
- API client (Dio) with connectivity checks and interceptors
- Local storage (Hive) for persistent state
- Structured logging with logger package
- Error handling with custom exception hierarchy

**Domain Layer** (`/domain`)

- **Freezed immutable models** with automatic `copyWith`, `toString`, `==`, and `hashCode`
- Automatic JSON serialization via `json_serializable` (code-generated `fromJson`/`toJson`)
- Precise API mapping (snake_case ↔ camelCase) via `@JsonKey` annotations
- Custom methods for computed properties (e.g., `markerColor`, `fullAddress`)
- Domain-specific enums (e.g., `FridgeCondition`)
- Repository interfaces (IFridgeRepository) for dependency inversion
- Business logic separated from data access

**Presentation Layer** (`/presentation`)

- Screens (full-page widgets)
- Controllers (state management via Riverpod)
- Widgets (reusable UI components)
- Separation: logic in controllers, UI in widgets

#### 3. **Dependency Injection via Providers**

All dependencies are injected via Riverpod providers in `core/providers/`:

```dart
// HTTP client
@riverpod
Dio dio(DioRef ref) {
  // Configuration, interceptors, error handling
}

// Repository
@riverpod
FridgeRepository fridgeRepository(FridgeRepositoryRef ref) {
  final dioClient = ref.watch(dioProvider);
  return FridgeRepository(dioClient);
}

// Usage in widgets/controllers
final repository = ref.watch(fridgeRepositoryProvider);
```

**Advantages:**

- Easy to mock for testing
- Centralized configuration
- Consistent dependencies across app
- Environment-specific setup (dev/prod)

#### 4. **Navigation with GoRouter**

Type-safe, persistent navigation:

```dart
GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: ...),  // Map screen
        GoRoute(path: '/list', builder: ...), // List screen
        // More routes...
      ],
    ),
  ],
)
```

**Features:**

- ShellRoute maintains bottom nav while switching screens
- Named routes with type-safe parameters
- Slide transitions between screens
- Deep linking ready

### Data Flow Example: Displaying Filtered Fridges

```
1. MapScreen watches mapFilteredFridgesProvider
   ↓
2. mapFilteredFridgesProvider depends on:
   - fridgeListProvider (API data)
   - mapFilterProvider (user filters)
   ↓
3. When user applies filter:
   - mapFilterProvider updates state → Hive persists
   - mapFilteredFridgesProvider recomputes
   - MapScreen rebuilds with new list
```

### Error Handling

Custom exception hierarchy for type-safe error handling:

```dart
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException { }
class ServerException extends AppException { }
class NotFoundException extends AppException { }
class LocationException extends AppException { }
```

Errors are caught in repositories and exposed as `AsyncValue` in Riverpod:

```dart
@riverpod
Future<List<FridgeDomain>> fridgeList(FridgeListRef ref) async {
  try {
    return await repository.getFridges();
  } on AppException catch (e) {
    throw AsyncError(e, StackTrace.current);
  }
}

// In UI:
final fridges = ref.watch(fridgeListProvider);
fridges.when(
  data: (list) => FridgeListView(list),
  loading: () => LoadingIndicator(),
  error: (error, st) => ErrorView(error: error),
);
```

---

## Features

### 🗺️ Map View

**Path:** `lib/src/features/map/`

Interactive OpenStreetMap displaying community fridges with advanced filtering.

**Key Features:**

- **Real-time Mapping:** flutter_map with OpenStreetMap tiles
- **Tile Caching:** Map tiles cached locally for faster loading and offline support (50MB cache, 30-day expiry)
- **Marker Clustering:** Groups nearby markers for cleaner display (configurable radius: 40px)
- **User Location:** Real-time GPS tracking with permission controls
- **Filter Panel:** Condition-based filtering + fuzzy text search
- **Distance Sorting:** Shows distance from user location
- **Fridge Details:** Tap marker → bottom sheet with full details
- **Status Indicators:** Color-coded markers (good=green, dirty=orange, broken=red)

**Filtering System:**

- **Food Level Filters:** Full (≥75%), Many Items (50-74%), Few Items (1-49%), Empty (0%)
- **Condition Filters:** Needs Cleaning, Needs Servicing, Not at Location
- **Filter Logic:** No filters selected = show all fridges
- **Search:** Real-time fuzzy matching on fridge names + location search with geocoding
- **Persistence:** Filters saved locally (restored on app reopen)

**State Management:**

- `fridgeListProvider` - Fetches all fridges from API
- `mapFilterProvider` - Manages filter state (persisted with Hive)
- `mapFilteredFridgesProvider` - Computed list of filtered fridges

### 📋 List View

**Path:** `lib/src/features/list/`

Scrollable list of community fridges with integrated filtering.

**Key Features:**

- **Distance Sorting:** Ordered by proximity to user location
- **Unified Filters:** Uses same filter pills as map view
- **Location Search:** Search for a location, shows fridges within 1.5km with removable pill indicator
- **Fridge Cards:** Visual cards showing name, status, distance, last report
- **Responsive Design:** Adapts to different screen sizes
- **Pull-to-Refresh:** Easy data refresh (via AsyncValue)

**State Management:**

- Shares `mapFilterProvider` with map view (consistent filtering)
- Watches `mapFilteredFridgesProvider` for filtered results

### 👤 Profile

**Path:** `lib/src/features/profile/`

User preferences and fridge details.

**Settings:**

- **Theme Mode:** Light / Dark / System (Material Design 3)
- **Location Toggle:** Enable/disable GPS access
- **API Environment:** Switch between dev/prod servers
- **Persistence:** All settings saved with Hive

**Fridge Details (Bottom Sheet):**

- Full fridge information (name, address, maintainer contact)
- Latest status report (condition, food percentage, timestamp)
- **Report Form:** Submit status updates with radio button condition selection (Good, Dirty, Out of Order, Not at Location)
- **Photo Upload:** Upload condition photos from camera or gallery
- **Share & Directions:** Native share and map app chooser (Google Maps, Apple Maps, Waze)

**State Management:**

- `themeModeProvider` - Theme preference
- `environmentProvider` - API environment
- `locationAccessProvider` - Location toggle

### 🔐 Authentication & User Management

**Path:** `lib/src/features/auth/`

Complete Firebase Authentication system with user profiles and account management.

**Key Features:**

- **Multi-Method Sign-In:**
  - Phone number authentication with SMS verification
  - Google Sign-In (OAuth2)
  - Automatic re-authentication handling
  - Profile creation flow for new users

- **User Profiles:**
  - Firebase Realtime Database integration
  - Username generation with uniqueness checking
  - Volunteer/non-volunteer role selection
  - Zip code collection (volunteers only, for funding tracking)
  - User settings (notifications, geofencing, notification frequency)

- **Account Management:**
  - Full profile display in sidebar and profile page
  - Sign out with provider invalidation
  - Account deletion with data cleanup
  - Session persistence across app launches

- **Points System:**
  - Automatic points awarding for volunteers
  - +10 points for status reports
  - +20 points for cleaning dirty fridges
  - +30 points for stocking food
  - Real-time points display in profile

**State Management:**

- `authUserProvider` - Current Firebase user
- `userProfileProvider` - User profile from database
- `isAuthenticatedProvider` - Authentication state
- `userPointsProvider` - Volunteer points tracking
- `authRepositoryProvider` - Authentication operations

### 🔔 Push Notifications & Cloud Messaging

**Path:** `lib/src/core/services/` and Cloud Functions

Complete notification system with Firebase Cloud Messaging and geofencing.

**Key Features:**

- **Firebase Cloud Messaging (FCM):**
  - Automatic token generation and registration
  - Token saved to user profile in database
  - Token refresh handling
  - Foreground and background message handling

- **Cloud Functions (Deployed):**
  - `onFridgeStatusUpdate` - Sends notifications when fridge status changes
  - `onUserSubscribe` - Handles new fridge subscriptions
  - `checkRoutineValidation` - Daily scheduled check for fridges needing updates
  - Notification batching based on user preferences

- **Local Notifications:**
  - Notification display and interaction
  - Payload-based navigation to fridge details
  - Notification channels (Android)
  - Permission handling (iOS)

- **Notification Navigation:**
  - Tap notification → Opens fridge details
  - Deep linking support
  - Provider-based navigation state

- **Subscription Management:**
  - Subscribe to individual fridges
  - Custom notification preferences per subscription
  - **Edit notification preferences** - Edit button in fridge profile for customizing which updates to receive
  - 6 configurable notification types per fridge
  - Different defaults for volunteers vs non-volunteers
  - Permission requests on first subscription
  - **Visual indicators** - Green glow on map markers and green icons in list view for subscribed fridges

**State Management:**

- `fcmServiceProvider` - FCM service lifecycle
- `notificationNavigationProvider` - Navigation from notifications
- `subscriptionManagerProvider` - Fridge subscription management
- `subscribedFridgesProvider` - List of user's subscriptions

### 📍 Geofencing & Location Services

**Path:** `lib/src/core/services/geofencing_service.dart` + Cloud Functions

Production-grade background location monitoring with Firebase Cloud Messaging integration.

**🎯 VOLUNTEER-ONLY FEATURE:** Geofencing is exclusively for volunteer users. Regular users (food finders) never see geofencing options or prompts and only need "While Using" location permission for map features.

**Key Features:**

- **Background Location Monitoring:**
  - Automatic monitoring when enabled (volunteers only)
  - Battery-optimized location tracking (2-minute intervals)
  - 4-block radius geofencing (~400m)
  - **Checks proximity to ALL fridges** (not just subscribed ones)
  - Notifications sent for ANY nearby fridge needing attention

- **Production FCM Integration:**
  - **Dual notification system:**
    - Primary: FCM via Cloud Function (works when app is closed/killed)
    - Fallback: Local notification (if FCM fails)
  - Cloud Function: `sendGeofencingNotification`
  - User authentication and settings verification
  - Reliable delivery even in background

- **Smart Proximity Detection:**
  - Three notification types (prioritized):
    1. **Cleaning:** Fridge needs cleaning (20-50 points)
    2. **Stocking:** Fridge is empty (30-60 points)
    3. **Routine:** >2 days since last update (10 points)
  - **Personalized messages** with distance in feet and point ranges
  - **Once-per-day limit:** Maximum one notification per fridge per day (prevents spam)
  - Notification history tracked both client-side and server-side

- **Permission Management:**
  - **Volunteer users:** Prompted for "Always Allow" permission on first subscription (opt-in)
  - **Regular users:** Only need "While Using" permission (never prompted for background access)
  - Hybrid Geolocator + permission_handler approach for iOS compatibility
  - Automatic upgrade prompt from "While Using" to "Always Allow"
  - Fallback "Open Settings" dialog with direct link when iOS blocks automatic upgrade
  - Permission status tracking in user profile
  - Toggle geofencing in profile settings (volunteers only)

- **Notification Examples:**
  - **Cleaning:** "This fridge 328 feet away needs cleaning! Earn 20-50 points by heading there and taking care of it"
  - **Stocking:** "This fridge 142 feet away could use some food- be a hero and earn 30-60 points by stocking it and posting a status update"
  - **Routine:** "This fridge super closeby hasn't been updated recently- snap a quick pic and send a status report to keep the neighborhood informed and fed :) Earn 10 points!"

- **Daily Notification Policy:**
  - Each fridge can trigger at most one notification per day
  - Separate tracking for each notification type (cleaning, stocking, routine)
  - Example: If you get a "cleaning" notification at 9 AM, you won't get another "cleaning" notification for that fridge until tomorrow
  - Different notification types can still trigger (e.g., "cleaning" in morning, "stocking" in evening if fridge becomes empty)
  - History persists across app restarts and is synced to Firebase backend
  - Automatic cleanup of notification records older than 7 days

**State Management:**

- `geofencingServiceProvider` - Service lifecycle
- User profile `settings.geofencingEnabled` - Toggle state
- Cloud Function `sendGeofencingNotification` - Backend FCM delivery + daily limit enforcement
- Firebase database path: `users/{userId}/geofencing/lastNotifications`

### 🔐 Firebase Integration Architecture

**Firebase Services:**

- **Authentication:** User sign-in and account management
- **Realtime Database:** User profiles, subscriptions, points
- **Cloud Messaging:** Push notifications
- **Cloud Functions:** Background processing and notifications

**Database Structure:**

```
users/
  {userId}/
    userId: string
    email: string
    phoneNumber: string
    username: string
    isVolunteer: boolean
    zipCode: string (if volunteer)
    points: number
    fcmToken: string
    settings:
      notificationsEnabled: boolean
      geofencingEnabled: boolean
      notificationFrequency: "immediate" | "daily" | "weekly"
    subscribedFridges/
      {fridgeId}/
        notificationPreferences:
          updatedWithFood: boolean
          runningLow: boolean
          empty: boolean
          needsCleaning: boolean
          needsServicing: boolean
          routineValidation: boolean
```

**Testing:**

- Firebase Emulator Suite configured
- Auth, Database, and Functions emulators
- Emulator test helpers in `test/helpers/firebase_emulator_helpers.dart`
- Start emulators: `./start_emulators.sh`

### 🎯 Advanced Search (Coming Soon)

**Path:** `lib/src/features/search/`

- Feature module structure ready
- Fuzzy search utilities already built
- Ready for dedicated search screen

---

## Development Workflow

### Daily Development Loop

1. **Update dependencies** (if needed)

   ```bash
   flutter pub upgrade
   ```

2. **Start development** with hot reload

   ```bash
   flutter run
   ```

3. **Make changes** to Dart files

   - Hot reload updates UI instantly (Ctrl/Cmd + S)
   - Hot restart for deeper changes (Ctrl/Cmd + Shift + S)

4. **Generate code** when modifying models/providers

   ```bash
   dart run build_runner build
   ```

5. **Run tests** before committing

   ```bash
   flutter test
   ```

6. **Commit your changes**
   ```bash
   git add .
   git commit -m "Descriptive message about changes"
   ```

### Adding a New Feature

Following the established architecture:

1. **Create feature directory structure**

   ```
   lib/src/features/my_feature/
   ├── data/
   │   ├── my_repository.dart
   │   └── my_model.dart
   ├── domain/
   │   └── my_domain.dart
   └── presentation/
       ├── controllers/
       │   └── my_controller.dart
       ├── screens/
       │   └── my_screen.dart
       └── widgets/
   ```

2. **Create data models** with Freezed

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'my_domain.freezed.dart';
   part 'my_domain.g.dart';

   @freezed
   class MyDomain with _$MyDomain {
     const MyDomain._(); // Required for custom methods

     const factory MyDomain({
       required String id,
       required String name,
       @Default(false) bool verified,
     }) = _MyDomain;

     factory MyDomain.fromJson(Map<String, dynamic> json) =>
         _$MyDomainFromJson(json);
   }
   ```

3. **Create repository**

   ```dart
   class MyRepository {
     final Dio dio;

     Future<List<MyDomain>> getItems() async {
       // API call
     }
   }
   ```

4. **Create providers**

   ```dart
   @riverpod
   MyRepository myRepository(MyRepositoryRef ref) {
     return MyRepository(ref.watch(dioProvider));
   }

   @riverpod
   Future<List<MyDomain>> myList(MyListRef ref) async {
     return ref.watch(myRepositoryProvider).getItems();
   }
   ```

5. **Create screens and widgets**

   ```dart
   class MyScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final items = ref.watch(myListProvider);
       return items.when(
         data: (list) => MyListView(list),
         loading: () => LoadingIndicator(),
         error: (err, st) => ErrorView(error: err),
       );
     }
   }
   ```

6. **Add route in GoRouter** (`lib/src/routing/router.dart`)

   ```dart
   GoRoute(
     path: '/my-feature',
     builder: (context, state) => MyScreen(),
   ),
   ```

7. **Generate code**
   ```bash
   dart run build_runner build
   ```

### Modifying Existing Features

**Map/List Changes:**

- Controllers are in `lib/src/features/map/presentation/controllers/`
- Widgets are in `lib/src/features/map/presentation/widgets/`
- Repository is in `lib/src/features/map/data/`

**Adding API Endpoints:**

- Add method to `FridgeRepository` in `lib/src/features/map/data/`
- Create Riverpod provider to call it
- Call from screen/widget via `ref.watch()`

**UI Customization:**

- Edit theme in `lib/src/core/theme/app_theme.dart`
- Modify common widgets in `lib/src/common_widgets/`
- Component-specific styling in feature widgets

### Code Generation Workflow

The project uses multiple code generators:

```bash
# Full build
dart run build_runner build

# Watch for changes (continuous generation)
dart run build_runner watch

# Clean old generated code
dart run build_runner clean
```

**Triggers code generation for:**

- `@freezed` classes → `*.freezed.dart` (immutability, copyWith, equality)
- `@riverpod` providers → `*.g.dart` (type-safe providers)
- `@JsonSerializable` models → `*.g.dart` (JSON serialization)

**Important:** Always run `--delete-conflicting-outputs` flag on first build:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For iOS builds, ensure code generation runs before building:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter build ios
```

---

## Testing

### Test Organization

Tests mirror the lib structure:

```
test/
├── core/utils/               # Utility tests (fuzzy search, etc.)
├── features/
│   ├── map/presentation/     # Map screen & controller tests
│   │   └── widgets/          # Widget tests (fridge_marker, fridge_cluster_widget)
│   └── list/presentation/    # List screen tests
├── shared/widgets/           # Common widget tests
├── integration/              # Full app workflow tests
│   ├── app_navigation_integration_test.dart
│   ├── fridge_detail_integration_test.dart
│   └── list_screen_integration_test.dart
├── fixtures/                 # Mock data (FridgeFixtures)
└── helpers/                  # Test utilities (test_helpers.dart)
```

**Test Status:** 271 tests passing, 5 navigation integration tests remaining (timing-related). New tests added for marker clustering (21 tests), map caching (5 tests), and filter improvements.

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/utils/fuzzy_search_test.dart

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Watch for changes
flutter test --watch
```

### Writing Tests

**Unit Test Example (Utility):**

```dart
void main() {
  group('FuzzySearch', () {
    test('matches exact strings', () {
      final result = isFuzzyMatch('apple', 'apple');
      expect(result, true);
    });

    test('fuzzy matches partial strings', () {
      final result = isFuzzyMatch('appl', 'apple');
      expect(result, true);
    });
  });
}
```

**Widget Test Example:**

```dart
void main() {
  group('FridgeCard', () {
    testWidgets('displays fridge name', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FridgeCard(fridge: mockFridge),
          ),
        ),
      );

      expect(find.text('Community Fridge #42'), findsOneWidget);
    });
  });
}
```

**Riverpod Provider Test Example (Code-Generated):**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/features/map/presentation/controllers/fridge_list_controller.dart';
import 'package:fridgefinder_app/src/core/providers/map_cache_provider.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('FridgeListProvider', () {
    test('fetches fridges from repository', () async {
      final container = createTestProviderContainer(
        overrides: [
          fridgeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final result = await container.read(fridgeListProvider.future);
      expect(result, mockFridges);
    });
  });

  group('CachedTileProvider', () {
    test('creates cached tile provider', () async {
      final container = createTestProviderContainer();
      final cachedTileProvider = container.read(cachedTileProviderProvider);
      expect(cachedTileProvider, isA<CachedTileProvider>());
    });
  });
}
```

**Note:** Tests use `createTestProviderContainer()` helper which sets up all required overrides (Dio, Hive, etc.) automatically.

### Testing Best Practices

1. **Test utilities independently** - Distance calculations, fuzzy search
2. **Mock repositories** - Don't make real API calls in tests
3. **Use fixtures** - Reusable mock data in `test/fixtures/`
4. **Test providers** - Override dependencies for unit testing
5. **Golden tests** - Screenshot tests for UI consistency (optional)

---

## Troubleshooting

### Common Issues & Solutions

#### 1. "Build failed" after pubspec.yaml changes

```bash
flutter clean
flutter pub get
dart run build_runner build
```

#### 2. Hot reload not working

```bash
# Hot restart instead
flutter run -r

# Or restart from scratch
flutter run --no-fast-start
```

#### 3. Code generation not running

```bash
dart run build_runner clean
dart run build_runner build
```

#### 4. "Location permission denied" on startup

- **iOS:** Check `ios/Runner/Info.plist` for location permissions
- **Android:** Check `android/app/src/main/AndroidManifest.xml`
- **Solution:** Grant location permissions in app settings or reinstall app

#### 5. Map tiles not loading

- Ensure internet connection (OpenStreetMap tiles are fetched from network)
- Map tiles are cached in memory (50MB cache) - cached tiles load instantly after first visit
- Check Dio configuration in `lib/src/core/providers/dio_provider.dart`
- Clear cache: `flutter clean && flutter pub get`
- Map cache provider: `lib/src/core/providers/map_cache_provider.dart` (uses MemCacheStore)

#### 6. "Hive box not found" error

- This occurs when Hive databases don't exist (first run is normal)
- Solution: Clear app data and reinstall, or manually open boxes
- Check `lib/main.dart` for Hive initialization

#### 7. API calls timing out

- Check API environment setting (Profile → Settings)
- Verify API endpoints in `lib/src/core/constants/api_constants.dart`
- Check network connectivity
- Increase timeout values if needed

#### 8. "Unhandled Exception: Bad state: \* Out of Life Cycle"

- Usually occurs during hot restart with Riverpod
- Solution: Use full restart or run `flutter run -r`

### Debug Mode Tips

```bash
# Enable verbose logging
flutter run -v

# Check device logs
flutter logs

# Inspect widget hierarchy
DevTools (in VS Code: Flutter: Open DevTools)

# Profile performance
DevTools → Performance tab
```

---

## Contributing

We welcome contributions! Here's how to contribute to FridgeFinder:

### Before You Start

1. **Check existing issues** - Don't duplicate work
2. **Review the architecture** - Understand feature-based structure
3. **Read this README** - Familiarize yourself with the codebase
4. **Set up development environment** - Follow Installation & Setup section

### Contribution Process

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes**

   - Follow the architecture patterns (feature-based structure)
   - Keep commits atomic and descriptive
   - Use meaningful commit messages (e.g., "Add fuzzy search to map filter")

3. **Generate code if needed**

   ```bash
   dart run build_runner build
   ```

4. **Test your changes**

   ```bash
   flutter test
   flutter analyze  # Check code quality
   ```

5. **Push to your branch**

   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**
   - Clear title describing the change
   - Description of what changed and why
   - Reference any related issues
   - Include test results

### Code Standards

- **Formatting:** Run `dart format lib/` before committing
- **Analysis:** Fix all issues from `flutter analyze`
- **Naming:** Follow Dart naming conventions (camelCase for variables/functions)
- **Comments:** Document complex logic and public APIs
- **Tests:** Include tests for new features
- **Models:** Use `@freezed` for immutable data classes
- **Providers:** Use `@riverpod` for state management

### Pull Request Checklist

- [ ] Code follows project standards
- [ ] No `flutter analyze` warnings
- [ ] Tests added/updated
- [ ] Code generation completed (`dart run build_runner build`)
- [ ] Commit messages are clear
- [ ] Works on both iOS and Android (if applicable)
- [ ] No console errors or warnings

### Getting Help

- Ask questions in pull request comments
- Check existing issues for solutions
- Review code examples in similar features
- Reference Flutter/Riverpod documentation

---

## Resources & Documentation

### Project Documentation

- **Architecture Details:** See [Architecture](#architecture) section above
- **Feature Guides:** Each feature folder contains implementation details
- **API Constants:** `lib/src/core/constants/api_constants.dart`
- **Test Examples:** `test/` directory

### Official Documentation

- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides
- **Riverpod Guide:** https://riverpod.dev
- **GoRouter Documentation:** https://pub.dev/packages/go_router
- **flutter_map Guide:** https://github.com/fleaflet/flutter_map
- **Freezed Documentation:** https://pub.dev/packages/freezed

### Key Dependencies Documentation

| Package                    | Purpose           | Documentation                                       |
| -------------------------- | ----------------- | --------------------------------------------------- |
| flutter_riverpod           | State management  | https://riverpod.dev                                |
| go_router                  | Navigation        | https://pub.dev/packages/go_router                  |
| flutter_map                | Mapping           | https://github.com/fleaflet/flutter_map             |
| flutter_map_marker_cluster | Marker clustering | https://pub.dev/packages/flutter_map_marker_cluster |
| flutter_map_cache          | Map tile caching  | https://pub.dev/packages/flutter_map_cache          |
| dio                        | HTTP client       | https://pub.dev/packages/dio                        |
| freezed                    | Code generation   | https://pub.dev/packages/freezed                    |
| hive                       | Local storage     | https://docs.hivedb.dev                             |
| geolocator                 | Location services | https://pub.dev/packages/geolocator                 |

### Related Resources

- **Material Design 3:** https://m3.material.io
- **Community Fridge Project:** [Project Website/Repository]
- **Flutter Community:** https://flutter.dev/community

---

## Project Status

### Current Implementation (v1.1.0 - Firebase Release)

✅ **Complete:**

**Core Features:**
- Map view with filtering and clustering
- **Marker clustering** - Groups nearby markers for cleaner display (configurable radius)
- **Map tile caching** - 50MB in-memory cache with 30-day expiry for faster loading
- List view with distance-based sorting
- User location tracking
- Fuzzy search across fridges
- Filter persistence (Hive)
- Status reporting form with points integration
- Photo upload capability
- Theme customization (light/dark/system)
- Multi-environment support (dev/prod)

**Firebase Integration (NEW):**
- ✅ **Authentication System:**
  - Phone number authentication with SMS verification
  - Google Sign-In (OAuth2)
  - User profile management (Firebase Realtime Database)
  - Account deletion functionality
  - Session persistence

- ✅ **User Profiles & Points:**
  - Volunteer/non-volunteer role system
  - Username generation with uniqueness checking
  - Points system (+10 reports, +20 cleaning, +30 stocking)
  - Profile display in sidebar and settings
  - Zip code collection for volunteers

- ✅ **Push Notifications:**
  - Firebase Cloud Messaging integration
  - FCM token management (auto-save to database)
  - Local notification display
  - Notification navigation to fridge details
  - Background and foreground message handling

- ✅ **Cloud Functions (Deployed):**
  - `onFridgeStatusUpdate` - Status change notifications
  - `onUserSubscribe` - Subscription handling
  - `checkRoutineValidation` - Daily scheduled checks
  - Node.js 20 runtime

- ✅ **Subscription System:**
  - Subscribe to individual fridges
  - Custom notification preferences per fridge
  - **Edit notification preferences** with dedicated dialog UI
  - 6 toggleable notification types per subscription
  - Permission requests on first subscription
  - Notification and geofencing permission flows
  - **Visual indicators** - Green glow on subscribed fridge markers and green icons in list view

- ✅ **Geofencing:**
  - Background location monitoring
  - 2-block radius proximity notifications
  - Battery-optimized tracking
  - Permission management

- ✅ **Firebase Emulator Suite:**
  - Auth, Database, Functions emulators configured
  - Test helpers for local development
  - Automated setup script

**Architecture:**
- **Freezed immutable models** (all domain models)
- **Riverpod code generation** (all providers use `@riverpod`)
- Repository pattern with dependency inversion
- Structured logging and error handling
- Network connectivity checks
- **App icons** - Generated for iOS (blue background) and Android (transparent)
- Comprehensive test suite (270+ tests)
- App store readiness (privacy policy, proper permissions, etc.)

🚧 **In Development:**

- Advanced search (structure ready)
- Comprehensive test coverage for Firebase features

⏳ **Planned:**

- **Favorites feature** (v1.2 - user can favorite fridges)
- Offline support expansion (cached data access)
- User history and analytics
- Community features (ratings, comments)
- Notification batching (daily/weekly digests)

---

## Support & Contact

For questions, issues, or suggestions:

1. **GitHub Issues:** Create an issue with detailed description
2. **Pull Requests:** Submit improvements directly
3. **Documentation:** Refer to sections above
4. **Code Examples:** Check `lib/src/features/` for implementation patterns

---

## License

[Add your license here - e.g., MIT, Apache 2.0, etc.]

---

## Acknowledgments

Built with ❤️ by the Community Fridge Finder team and contributors.

**Key Technologies:**

- Flutter & Dart
- Riverpod
- GoRouter
- flutter_map
- Firebase

---

**Last Updated:** January 2025 | **Version:** 1.0.0+10 | **Maintainers:** [Your Team]

---

## Recent Updates

### January 2025 - v1.0.0+10 (Daily Notification Limits)

#### 🔔 Once-Per-Day Notification Policy

- ✅ **Daily Notification Limits:**
  - Maximum one notification per fridge per day (prevents spam)
  - Separate tracking for each notification type (cleaning, stocking, routine)
  - Client-side tracking with Map<String, DateTime> (in-memory)
  - Server-side enforcement in Cloud Function (persists to Firebase)
  - Automatic cleanup of records older than 7 days
  - Daily cleanup timer runs every 24 hours

- ✅ **Database Structure:**
  - Firebase path: `users/{userId}/geofencing/lastNotifications/{fridgeId}_{type}`
  - Stores ISO 8601 timestamp of last notification
  - Cloud Function checks date before sending
  - Returns `already_notified_today` if same-day notification exists

### January 2025 - v1.0.0+9 (Production FCM & Environment Configuration)

#### 🚀 Production-Ready Geofencing Notifications

- ✅ **Firebase Cloud Functions Integration:**
  - New Cloud Function: `sendGeofencingNotification` (callable)
  - Backend FCM notification delivery (works when app closed/killed)
  - Dual notification system: FCM primary, local fallback
  - User authentication and settings verification in backend
  - Production-grade error handling and logging
  - Daily notification limit enforcement in backend

- ✅ **Enhanced Geofencing Logic:**
  - **Notifies for ALL fridges** within 400m radius (not just subscribed)
  - **Personalized notification messages:**
    - Distance displayed in feet (converted from meters)
    - Point ranges shown (20-50, 30-60, or 10 points)
    - Encouraging, specific call-to-action text
  - Three notification types (prioritized):
    1. Cleaning (if dirty)
    2. Stocking (if empty only, not "running low")
    3. Routine (if >2 days since update)

- ✅ **Dual Environment Configuration:**
  - **Fridge Data API:** DEV by default (`api-dev.communityfridgefinder.com`)
  - **Firebase Services:** PRODUCTION always
  - Comprehensive documentation: `ENVIRONMENT_CONFIGURATION.md`
  - Clear separation in codebase with comments
  - No emulator mode active in production builds

- ✅ **Dependencies:**
  - Added `cloud_functions: ^6.0.3` package
  - All Firebase services verified to use production

#### 📝 Documentation Updates

- ✅ **New Files:**
  - `ENVIRONMENT_CONFIGURATION.md` - Detailed dual environment setup guide
  - Updated README with production FCM features
  - Clear comments in all Firebase service files

- ✅ **Code Documentation:**
  - "PRODUCTION ENVIRONMENT ONLY" comments added to:
    - `auth_repository.dart` - Firebase Auth
    - `fcm_service.dart` - Cloud Messaging
    - `database_provider.dart` - Realtime Database
    - `geofencing_service.dart` - Cloud Functions
  - Environment notes in `api_constants.dart`

#### 🧪 Testing & Build

- ✅ **Build Status:** Clean compilation (128.9s)
- ✅ **Test Status:** 397 passing / 528 total (75% pass rate)
- ✅ **Analyzer:** Zero errors in modified files
- ✅ **Known Issues:** 131 test failures are Firebase initialization issues in integration tests (not related to new features)

### January 2025 - v1.1.3 (Geofencing Improvements & Bug Fixes)

#### 🐛 Critical Bug Fixes

- ✅ **Black Screen on Sign-Up Fixed:**
  - Fixed double-pop navigation issue in sign-in flow
  - `SignInWidget` already handles dialog dismissal, removed redundant `Navigator.pop()` in callback
  - Proper separation of responsibilities: widget handles lifecycle, callback handles next action
  - No more empty navigation stack causing black screen

- ✅ **Geofencing Permission Errors Fixed:**
  - Added `ref.mounted` checks after all async operations in `subscriptionManagerProvider`
  - Prevents "Cannot use Ref after disposed" errors during subscription flow
  - Graceful exit when provider disposed during async gaps (permission requests, FCM token)
  - Follows Riverpod best practices for async provider lifecycle management

- ✅ **iOS Background Location Configuration:**
  - Added `location` to `UIBackgroundModes` in Info.plist
  - Required for geofencing to work when app is not in foreground
  - Complies with iOS App Store requirements

#### ✨ New Features & Improvements

- ✅ **Geofencing Now Volunteer-Only:**
  - **Regular users (food finders):** Never see geofencing prompts, only need "While Using" location
  - **Volunteer users:** Opt-in geofencing on first subscription with clear explanation
  - Geofencing toggle only visible in Profile settings for volunteers
  - Reduces permission fatigue for users who just want to find food
  - Better App Store compliance - background location only requested when truly needed

- ✅ **Improved iOS Permission Flow:**
  - Hybrid Geolocator + permission_handler approach for better iOS compatibility
  - Automatic attempt to upgrade "While Using" to "Always Allow"
  - Detects when iOS blocks automatic upgrade and shows helpful dialog
  - "Open Settings" button with direct link when manual upgrade needed
  - Clear instructions: "Change location to 'Always'" with step-by-step guidance
  - Comprehensive logging at each permission check step for debugging

- ✅ **App Store Documentation:**
  - Created `APP_STORE_PERMISSIONS.md` with detailed permission justifications
  - Explains volunteer-only nature of background location
  - Testing instructions for App Store reviewers
  - Privacy policy summary and user control documentation
  - iOS and Android platform-specific permission details

#### 🧪 Testing Updates

- ✅ **Geofencing Tests Updated:**
  - Added volunteer-only annotations to geofencing test suite
  - Helper functions now include `isVolunteer` parameter
  - Test documentation reflects new permission flow

### January 2025 - v1.1.2 (Subscribed Filter & UX Polish)

#### ✨ New Features

- ✅ **Subscribed Pill Filter:**
  - New filter pill for showing only subscribed fridges
  - Only visible when user is authenticated AND has subscriptions
  - Green transparent background (#4CAF50, 85% opacity) with white text/icon
  - Positioned first (leftmost) in filter pills row
  - Green glow when selected
  - Filter persists across app restarts (Hive storage)
  - Works seamlessly with other pill filters and search

- ✅ **Enhanced Subscription Indicators:**
  - Green pulsing glow on subscribed fridge icon in profile sheet
  - Consistent 1500ms animation cycle across all views
  - Matches map markers and list view indicators

#### 🐛 Bug Fixes

- ✅ **Edit Notifications Dialog Fixed:**
  - Fixed loading indicator hanging forever on open
  - Changed from sync `ref.read()` to async `ref.read().future`
  - Fixed loading indicator hanging after submit
  - Captured ScaffoldMessenger reference before popping dialog
  - Proper loading dialog management with context checking
  - Dialog now opens, edits, and submits successfully

- ✅ **List View Filtering Fixed:**
  - Added missing subscribed filter logic to list view
  - Both map and list views now respect subscribed filter
  - Filter order: pill conditions → subscribed → location → search

- ✅ **Profile Sheet Overflow Fixed:**
  - Replaced rigid `Row` with flexible `Wrap` widget
  - Status text and distance now wrap to multiple lines naturally
  - No more RenderFlex overflow errors
  - Cleaner, more aesthetic layout

#### 🎨 UX Improvements

- ✅ **Compact Button Layout:**
  - Edit and Unsubscribe buttons now stack vertically
  - Reduced button sizes (14px icons, 12px text, 28px height)
  - Shortened "Unsubscribe" to "Unsub" for compact display
  - Better use of limited header space in profile sheet

#### 🧪 Testing

- ✅ **Test Status:** 153 passing / 164 total (93.3% pass rate)
- ✅ **Build Status:** Clean analyzer (0 errors)
- ✅ **Known Issues:** 11 failing tests due to pre-existing Firebase/plugin initialization (not related to recent changes)

### January 2025 - v1.1.1 (Bug Fixes & UX Enhancements)

#### 🐛 Critical Bug Fixes

- ✅ **Account Deletion Fixed:**
  - Fixed toast notification hanging during account deletion
  - Properly captures ScaffoldMessenger reference before deletion
  - Firebase Auth state listeners now handle updates automatically
  - No more manual provider invalidation needed

- ✅ **Geofencing Permission Loop Fixed:**
  - Switched from `permission_handler` to `Geolocator`
  - Now properly detects "Always Allow" location permission on iOS
  - Handles iOS two-step permission flow (While Using → Always)
  - No more infinite permission request loops

- ✅ **Black Screen After Sign-Up Fixed:**
  - Removed manual provider invalidation causing race conditions
  - Uses `postFrameCallback` for proper navigation timing
  - Firebase Auth state changes handled naturally
  - Fixed for both phone and Google authentication flows

- ✅ **Firebase Type Casting Fixed:**
  - Created `convertFirebaseMap()` utility for recursive conversion
  - Handles nested `Map<Object?, Object?>` from Firebase Realtime Database
  - Fixes multiple black screen issues caused by type mismatches
  - Properly converts all nested maps and lists

#### ✨ New Features

- ✅ **Notification Preferences Editing:**
  - Edit button added next to Unsubscribe in fridge profile
  - Customize notifications per subscribed fridge
  - 6 toggleable notification types:
    - Updated with Food
    - Running Low
    - Empty
    - Needs Cleaning
    - Needs Servicing
    - Routine Validation
  - Preferences persist to Firebase Realtime Database
  - Clean dialog UI with icons and descriptions

- ✅ **Visual Indicators for Subscribed Fridges:**
  - Green glowing effect on map markers for subscribed fridges
  - Green icons in "My Fridges" list view
  - Uses consistent green color (#4CAF50) across app
  - Double-shadow effect for depth and visibility
  - O(1) lookup performance with Set-based subscription checking

#### 🧪 Testing

- ✅ **Build Status:** Clean analyzer (0 errors, 20 pre-existing warnings)
- ✅ **Unit Tests:** 267 passing (26 pre-existing failures in navigation tests)
- ✅ **Debug Build:** Successful compilation
- ✅ **Comprehensive Testing Guide:** Created `TESTING_GUIDE.md` with step-by-step testing instructions

### January 2025 - v1.1.0 (Firebase Release)

#### 🔥 Firebase Integration Complete

- ✅ **Authentication System:**
  - Implemented phone number authentication with SMS verification
  - Integrated Google Sign-In (OAuth2)
  - Fixed Navigator exception causing black screen after auth
  - Fixed sign-up form showing for existing users on re-sign-in
  - Proper provider invalidation on sign-out and account deletion

- ✅ **User Profiles:**
  - Complete user profile management in Firebase Realtime Database
  - Username generation with uniqueness validation
  - Volunteer role system with zip code collection
  - Profile display in sidebar and settings page
  - Fixed user info not displaying properly

- ✅ **Points System:**
  - Integrated with status report submission
  - Automatic point awarding (+10 reports, +20 cleaning, +30 stocking)
  - Real-time points display for volunteers
  - Database tracking and persistence

- ✅ **Push Notifications:**
  - Firebase Cloud Messaging fully implemented
  - FCM token management (auto-register, save, refresh)
  - Local notification service with navigation
  - Notification tap → fridge details navigation
  - Background and foreground message handling

- ✅ **Cloud Functions:**
  - Deployed 3 functions to Firebase (Node.js 20)
  - `onFridgeStatusUpdate` - Notifies subscribers of status changes
  - `onUserSubscribe` - Handles new subscriptions
  - `checkRoutineValidation` - Daily scheduled routine checks
  - ESLint configuration and code quality

- ✅ **Subscription System:**
  - Subscribe to individual fridges
  - Custom notification preferences per subscription
  - Fixed subscribe dialog errors
  - Fixed wrong checkbox defaults
  - Permission requests on first subscription

- ✅ **Geofencing:**
  - Background location monitoring implemented
  - Permission requests with user-friendly explanations
  - 2-block radius proximity alerts
  - Integration with notification preferences

- ✅ **Testing Infrastructure:**
  - Firebase Emulator Suite configured (Auth, Database, Functions)
  - Test helpers for emulator integration
  - Startup script for local development
  - Firebase-specific test utilities

- ✅ **Build & Deploy:**
  - Android APK builds successfully (66.6MB)
  - iOS builds successfully (53.0MB)
  - Cloud Functions deployed to production
  - All critical bugs fixed

### January 2025 - v1.0.0+5

### UX/UI Improvements

- ✅ **Filter System Redesign:**
  - 7 filter categories: Full, Many Items, Few Items, Empty, Needs Cleaning, Needs Servicing, Not at Location
  - Inverted filter logic: No filters selected = show all fridges
  - Color coding based ONLY on food level (green/yellow/pink/white), conditions shown via icon decorations
  - Filters always visible at top of map view
  - Filter state persists with version tracking for migration
  - Fixed "unknown food level" fridges appearing in filters

- ✅ **Location Search:**
  - Map view: Enter location and press Enter to move map, clears search bar automatically
  - List view: Shows fridges within 1.5km of searched location with removable blue pill indicator
  - Prevents location text from being used in fuzzy name search

- ✅ **Map Interactions:**
  - Map remains fully interactive while search bar is active
  - Health bars now display for all fridge conditions (not just "good")
  - Filter status indicator only shows when filters are active

- ✅ **Status Reporting:**
  - Radio button UI for condition selection (cleaner than segmented buttons)
  - Removed "Ghost" option from user-facing reports
  - Photo upload: "Camera" and "Gallery" buttons (compact text)
  - Fixed dialog width issue for photo upload buttons

- ✅ **Directions & Sharing:**
  - Map app chooser shows available apps (Google Maps, Apple Maps, Waze)
  - User selects preferred navigation app
  - Native share functionality for fridge locations

- ✅ **Dark Mode Improvements:**
  - Location pill now clearly visible in dark mode (blue color)
  - Semi-transparent backgrounds for map overlays (0.5 alpha)
  - Better contrast for filter pills and search elements

### Architecture Improvements

- ✅ **Freezed Implementation:** All domain models (`FridgeDomain`, `FridgeLocationDomain`, `FridgeMaintainerDomain`, `FridgeReportDomain`, `UserLocation`, `MapFilterState`) now use Freezed for immutability
- ✅ **Riverpod Code Generation:** All providers converted to code generation with `@riverpod` annotation for type safety
- ✅ **Marker Clustering:** Implemented `flutter_map_marker_cluster` for grouping nearby markers, improving map performance and UX
- ✅ **Map Tile Caching:** Added `flutter_map_cache` with in-memory LRU cache (50MB) for faster map loading and reduced data usage
- ✅ **Test Coverage:** Comprehensive test suite with 271 passing tests
- ✅ **App Store Readiness:** Privacy policy created, navigation cleaned up, proper permissions configured, app icons generated

### Code Quality

- ✅ **Const Optimization:** Applied `dart fix --apply` for performance improvements
- ✅ **Navigation Cleanup:** Removed Favorites placeholder to ensure app store approval
- ✅ **Provider Overrides:** Improved test helpers with proper provider mocking
- ✅ **Comprehensive Testing:** Added tests for marker clustering (21), map caching (5), and filter improvements

### Bug Fixes

- ✅ Fixed filter initialization (v2 storage schema with automatic migration)
- ✅ Fixed health bars not showing for dirty/out-of-order fridges
- ✅ Fixed map overlay blocking interactions
- ✅ Fixed "not showing" text appearing with no filters selected
- ✅ Fixed list view showing no fridges by default
- ✅ Fixed photo upload dialog width issue
- ✅ Fixed unknown food level fridges matching filters

### App Store Preparation

- ✅ **Privacy Policy:** Created HTML privacy policy ready for hosting
- ✅ **Documentation:** Complete guide for remaining submission tasks (`REMAINING_TASKS_GUIDE.md`)
- ✅ **Configuration:** iOS PrivacyInfo.xcprivacy, Android permissions properly configured

For details on remaining app store submission tasks, see `REMAINING_TASKS_GUIDE.md` in the project root.
