# FridgeFinder Mobile App

> A community-driven mobile application for locating, managing, and reporting on community fridges. Built with Flutter using modern state management, clean architecture, and reactive programming patterns.

**Status:** Active Development | **Version:** 1.0.0 | **Platform:** iOS & Android | **Language:** Dart/Flutter 3.8+

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

Get the app running locally in 3 steps:

```bash
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
- **State Management:** Riverpod (reactive, composable)
- **Navigation:** GoRouter (type-safe, persistent navigation)
- **Mapping:** flutter_map with marker clustering
- **HTTP Client:** Dio with interceptors
- **Local Storage:** Hive (user settings, filter state)

### 3. Generate Code

The project uses code generation for:
- **Freezed:** Immutable data models
- **Riverpod:** Provider generators
- **JSON Serialization:** Model to/from JSON conversion

```bash
dart run build_runner build
```

Run this after modifying any:
- Data models (with `@freezed`)
- Riverpod providers
- JSON serialization fields

### 4. Configure Environment (Optional)

By default, the app uses the **dev API environment**. To switch:

1. Open the app
2. Go to **Profile** → **Settings**
3. Toggle **API Environment** between Dev/Prod

This persists to local storage via Hive.

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
│       │   │   └── theme_provider.dart  # Theme mode (light/dark/system)
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
│       │   │   │   └── fridge_domain.dart          # Data models & enums
│       │   │   └── presentation/
│       │   │       ├── controllers/
│       │   │       │   ├── fridge_list_controller.dart     # Data & selection state
│       │   │       │   ├── map_filter_controller.dart      # Filter state (persistent)
│       │   │       │   └── filter_condition.dart           # Filter matching logic
│       │   │       ├── screens/
│       │   │       │   └── map_screen.dart                 # Main map UI
│       │   │       └── widgets/
│       │   │           ├── fridge_marker.dart              # Custom map markers
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
│       │   ├── favorites/                # Placeholder for future implementation
│       │   ├── auth/                     # Placeholder for authentication
│       │   ├── notifications/            # Placeholder for push notifications
│       │   └── search/                   # Placeholder for advanced search
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
  MapFilterState build() => MapFilterState();

  void updateFilter(FilterCondition condition) {
    // State updates trigger rebuilds of watching widgets
  }
}

// Computed derived state
@riverpod
List<FridgeDomain> mapFilteredFridges(MapFilteredFridgesRef ref) {
  final fridges = ref.watch(fridgeListProvider);
  final filters = ref.watch(mapFilterProvider);
  return fridges.where((f) => filters.matchesFridge(f)).toList();
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
- Repository pattern for data access
- API client (Dio) and local storage (Hive) integration
- Models with JSON serialization
- Error handling with custom exceptions

**Domain Layer** (`/domain`)
- Business logic models (freezed for immutability)
- Domain-specific enums (e.g., `FridgeCondition`)
- Repositories as interfaces (abstract)

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
- **Marker Clustering:** Groups nearby markers for cleaner display
- **User Location:** Real-time GPS tracking with permission controls
- **Filter Panel:** Condition-based filtering + fuzzy text search
- **Distance Sorting:** Shows distance from user location
- **Fridge Details:** Tap marker → bottom sheet with full details
- **Status Indicators:** Color-coded markers (good=green, dirty=orange, broken=red)

**Filtering System:**
- **Condition Filters:** Good (with/without food), Dirty, Out of Order, Ghost, Not at Location
- **Search:** Real-time fuzzy matching on fridge names
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
- **Report Form:** Submit status updates (condition + notes + optional photo)
- **Photo Upload:** Upload condition photos to server

**State Management:**
- `themeModeProvider` - Theme preference
- `environmentProvider` - API environment
- `locationAccessProvider` - Location toggle

### 🎯 Placeholder Features (Ready for Development)

**Favorites** (`/favorites`)
- Route structure ready
- UI shell in place
- Awaiting implementation

**Authentication** (`/auth`)
- Feature module structure ready
- Firebase Auth dependencies included
- Ready for user login/signup integration

**Notifications** (`/notifications`)
- Feature module structure ready
- Firebase Messaging dependencies included
- Placeholder for push notifications

**Advanced Search** (`/search`)
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

2. **Create data models** with freezed
   ```dart
   @freezed
   class MyDomain with _$MyDomain {
     const factory MyDomain({
       required String id,
       required String name,
     }) = _MyDomain;

     factory MyDomain.fromJson(Map<String, Object?> json) =>
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
- `@freezed` classes → `*.freezed.dart`
- `@riverpod` providers → `*.g.dart`
- `@JsonSerializable` models → `*.g.dart`

---

## Testing

### Test Organization

Tests mirror the lib structure:

```
test/
├── core/utils/               # Utility tests (fuzzy search, etc.)
├── features/
│   ├── map/presentation/     # Map screen & controller tests
│   └── list/presentation/    # List screen tests
├── shared/widgets/           # Common widget tests
├── integration/              # Full app workflow tests
├── fixtures/                 # Mock data
└── helpers/                  # Test utilities
```

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

**Riverpod Provider Test Example:**
```dart
void main() {
  group('FridgeListProvider', () {
    test('fetches fridges from repository', () async {
      final container = ProviderContainer(
        overrides: [
          fridgeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );

      final result = await container.read(fridgeListProvider.future);
      expect(result, mockFridges);
    });
  });
}
```

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
- Check Dio configuration in `lib/src/core/providers/dio_provider.dart`
- Clear cache: `flutter clean && flutter pub get`

#### 6. "Hive box not found" error
- This occurs when Hive databases don't exist (first run is normal)
- Solution: Clear app data and reinstall, or manually open boxes
- Check `lib/main.dart` for Hive initialization

#### 7. API calls timing out
- Check API environment setting (Profile → Settings)
- Verify API endpoints in `lib/src/core/constants/api_constants.dart`
- Check network connectivity
- Increase timeout values if needed

#### 8. "Unhandled Exception: Bad state: * Out of Life Cycle"
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

| Package | Purpose | Documentation |
|---------|---------|----------------|
| flutter_riverpod | State management | https://riverpod.dev |
| go_router | Navigation | https://pub.dev/packages/go_router |
| flutter_map | Mapping | https://github.com/fleaflet/flutter_map |
| dio | HTTP client | https://pub.dev/packages/dio |
| freezed | Code generation | https://pub.dev/packages/freezed |
| hive | Local storage | https://docs.hivedb.dev |
| geolocator | Location services | https://pub.dev/packages/geolocator |

### Related Resources

- **Material Design 3:** https://m3.material.io
- **Community Fridge Project:** [Project Website/Repository]
- **Flutter Community:** https://flutter.dev/community

---

## Project Status

### Current Implementation (v1.0.0)

✅ **Complete:**
- Map view with filtering and clustering
- List view with distance-based sorting
- User location tracking
- Fuzzy search across fridges
- Filter persistence (Hive)
- Status reporting form
- Photo upload capability
- Theme customization (light/dark/system)
- Multi-environment support (dev/prod)

🚧 **In Development:**
- Favorites feature (structure ready)
- Advanced search (structure ready)

⏳ **Planned:**
- User authentication (Firebase Auth structure ready)
- Push notifications (Firebase Messaging structure ready)
- Offline support (partial, structure ready)
- User history and analytics
- Community features (ratings, comments)

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

**Last Updated:** October 31, 2025 | **Version:** 1.0.0 | **Maintainers:** [Your Team]
