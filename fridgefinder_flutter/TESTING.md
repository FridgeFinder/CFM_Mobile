# FridgeFinder Testing Guide

Complete guide for running and writing E2E tests for the FridgeFinder Flutter app.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Firebase Emulator Setup](#firebase-emulator-setup)
- [Running Tests](#running-tests)
- [Writing New Tests](#writing-new-tests)
- [Test Structure](#test-structure)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
1. **Flutter SDK** (3.0+)
   ```bash
   flutter --version
   ```

2. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

3. **Node.js** (16+) - Required for Firebase emulator
   ```bash
   node --version
   ```

4. **Java JDK** (11+) - Required for Firebase emulator
   ```bash
   java -version
   ```

### Install Dependencies
```bash
cd fridgefinder_flutter
flutter pub get
```

---

## Quick Start

### 1. Start Firebase Emulator
```bash
# From project root
firebase emulators:start
```

The emulator UI will be available at: http://localhost:4000

### 2. Run All Integration Tests
```bash
# In a new terminal
cd fridgefinder_flutter
flutter test test/integration/
```

### 3. Run Specific Test File
```bash
flutter test test/integration/signup_integration_test.dart
```

---

## Firebase Emulator Setup

### Configuration

The Firebase emulator is already configured in `firebase.json`:

```json
{
  "emulators": {
    "auth": { "port": 9099, "host": "127.0.0.1" },
    "database": { "port": 9000, "host": "127.0.0.1" },
    "functions": { "port": 5001, "host": "127.0.0.1" },
    "ui": { "enabled": true, "port": 4000, "host": "127.0.0.1" }
  }
}
```

### Start Emulator

#### Option 1: Standard Start
```bash
firebase emulators:start
```

#### Option 2: Import/Export Data
```bash
# Export data after tests
firebase emulators:start --export-on-exit=./emulator-data

# Import data on start
firebase emulators:start --import=./emulator-data
```

#### Option 3: Specific Emulators Only
```bash
# Start only Auth and Database
firebase emulators:start --only auth,database
```

### Emulator Endpoints

| Service | Port | URL |
|---------|------|-----|
| Auth | 9099 | http://localhost:9099 |
| Database | 9000 | http://localhost:9000 |
| Functions | 5001 | http://localhost:5001 |
| Emulator UI | 4000 | http://localhost:4000 |

### Verify Emulator is Running

1. Open http://localhost:4000 in your browser
2. You should see the Firebase Emulator Suite UI
3. Check that Auth and Realtime Database tabs are available

---

## Running Tests

### Run All Integration Tests
```bash
flutter test test/integration/
```

### Run Specific Test File
```bash
# Sign-up tests
flutter test test/integration/signup_integration_test.dart

# Subscription tests
flutter test test/integration/subscribe_variations_test.dart

# Notification tests
flutter test test/integration/notification_variations_test.dart

# Geofencing tests
flutter test test/integration/geofencing_variations_test.dart

# Status report tests
flutter test test/integration/status_report_variations_test.dart
```

### Run Specific Test by Name
```bash
flutter test test/integration/signup_integration_test.dart --name "SU-001"
```

### Run with Verbose Output
```bash
flutter test --reporter expanded test/integration/
```

### Run with Coverage
```bash
flutter test --coverage test/integration/
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Watch Mode (Re-run on changes)
```bash
# Install fswatch (macOS)
brew install fswatch

# Watch and re-run tests
fswatch -o test/integration/ | xargs -n1 -I{} flutter test test/integration/
```

---

## Writing New Tests

### Test File Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/test_helpers.dart';
import '../helpers/firebase_emulator_helpers.dart';
import '../test_helpers.dart';

void main() {
  setUpAll(() async {
    await initHiveForTesting();
    await initializeFirebaseEmulator();
  });

  tearDownAll(() async {
    await cleanupHive();
  });

  group('Feature Name Tests', () {
    testWidgets('TEST-001: Description', (WidgetTester tester) async {
      // Arrange: Set up test data and mocks
      final testUser = TestUser(uid: 'test-user-1', email: 'test@example.com');

      await tester.pumpWidget(createTestApp(
        authenticatedUser: testUser,
      ));

      // Act: Perform actions
      await tester.pump(const Duration(milliseconds: 200));

      // Assert: Verify expectations
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

### Best Practices

1. **Use Descriptive Test Names**
   ```dart
   testWidgets('REP-001: Submit Valid Status Report - Anonymous User', ...)
   ```

2. **Follow AAA Pattern**
   - **Arrange:** Set up test data
   - **Act:** Perform user actions
   - **Assert:** Verify expected behavior

3. **Use Test Helpers**
   ```dart
   // Use shared test helpers
   final fridgesWithDistance = FridgeFixtures.allFridges
       .map((fridge) => FridgeWithDistance(fridge: fridge, distanceKm: null))
       .toList();
   ```

4. **Mock External Dependencies**
   ```dart
   // Override providers with test implementations
   overrides: [
     ...getBaseTestOverrides(),
     authRepositoryProvider.overrideWithValue(mockAuthRepository),
   ]
   ```

5. **Clean Up After Tests**
   ```dart
   tearDown(() async {
     await cleanupFirebaseEmulator();
   });
   ```

6. **Wait for Async Operations**
   ```dart
   // Wait for animations to complete
   await tester.pumpAndSettle();

   // Wait for specific duration
   await tester.pump(const Duration(milliseconds: 200));
   ```

### Common Widget Finders

```dart
// By type
find.byType(TextField)
find.byType(ElevatedButton)

// By text
find.text('Submit')
find.textContaining('Error')

// By icon
find.byIcon(Icons.add)

// By key
find.byKey(Key('submit-button'))

// By widget
find.byWidget(MyCustomWidget())
```

### Common Assertions

```dart
// Widget presence
expect(find.text('Hello'), findsOneWidget);
expect(find.text('Error'), findsNothing);
expect(find.byType(Card), findsWidgets);
expect(find.byType(Card), findsNWidgets(5));

// Widget properties
final widget = tester.widget<TextField>(find.byType(TextField));
expect(widget.enabled, isTrue);
expect(widget.decoration?.hintText, equals('Enter text'));
```

### Test Data Fixtures

Located in `test/fixtures/fridge_fixtures.dart`:

```dart
// Available fixtures
FridgeFixtures.verifiedFridgeWithFood
FridgeFixtures.notAtLocationFridge
FridgeFixtures.fridgeDirty
FridgeFixtures.fridgeOutOfOrder
FridgeFixtures.ghostFridge
FridgeFixtures.allFridges
```

---

## Test Structure

### Current Test Files

| File | Tests | Coverage |
|------|-------|----------|
| `signup_integration_test.dart` | 22 | Authentication flows |
| `subscribe_variations_test.dart` | 25 | Subscription management |
| `notification_variations_test.dart` | 30 | Push notifications |
| `geofencing_variations_test.dart` | 25 | Location-based alerts |
| `status_report_variations_test.dart` | 20 | Status reporting |

### Test Helpers

#### `test_helpers.dart`
- `initHiveForTesting()` - Initialize Hive for tests
- `cleanupHive()` - Clean up Hive after tests
- `getBaseTestOverrides()` - Common provider overrides
- `createTestProviderContainer()` - Create test container
- `MockFridgeRepository` - Mock fridge data repository

#### `firebase_emulator_helpers.dart`
- `initializeFirebaseEmulator()` - Connect to Firebase emulator
- `cleanupFirebaseEmulator()` - Clean up Firebase data
- `createTestUser()` - Create test user in emulator
- `createTestDatabaseData()` - Seed test data
- `getTestDatabaseData()` - Read test data

### Provider Overrides

Common overrides for tests:

```dart
overrides: [
  // Dio instance without connectivity checks
  dioProvider.overrideWithValue(createTestDio()),

  // Mock repository
  fridgeRepositoryProvider.overrideWithValue(mockRepository),

  // Environment settings
  environmentProvider.overrideWithValue(ApiEnvironment.prod),

  // Authentication state
  currentAuthUserProvider.overrideWith(
    (ref) => AsyncValue.data(testUser),
  ),

  // Subscription data
  subscribedFridgesProvider.overrideWith(
    (ref) => Stream.value(subscriptions),
  ),
]
```

---

## Troubleshooting

### Common Issues

#### 1. Firebase Not Initialized Error
```
[core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solution:** Start Firebase emulator before running tests
```bash
firebase emulators:start
```

#### 2. Port Already in Use
```
Port 9099 is already in use
```

**Solution:** Kill the process using the port
```bash
lsof -ti:9099 | xargs kill -9
lsof -ti:9000 | xargs kill -9
lsof -ti:5001 | xargs kill -9
```

#### 3. Hive Box Already Open Error
```
Box 'app_settings' is already open
```

**Solution:** Ensure proper cleanup in tearDown
```dart
tearDown(() async {
  await Hive.deleteBoxFromDisk('app_settings');
});
```

#### 4. Test Timeout
```
Test timed out after 30 seconds
```

**Solution:** Increase timeout or optimize test
```bash
flutter test --timeout=60s test/integration/
```

#### 5. Widget Not Found in Test
```
Expected to find exactly one widget with text 'Submit'
```

**Solution:** Wait for widget to appear
```dart
await tester.pumpAndSettle();
await tester.pump(const Duration(milliseconds: 200));
```

### Debug Tips

#### 1. Print Widget Tree
```dart
debugDumpApp(); // Print entire widget tree
```

#### 2. Take Screenshot
```dart
await expectLater(
  find.byType(MaterialApp),
  matchesGoldenFile('golden/test-screenshot.png'),
);
```

#### 3. Check Firebase Emulator Logs
- Open http://localhost:4000
- View Auth users
- View Database data
- Check Logs tab

#### 4. Verbose Test Output
```bash
flutter test --verbose test/integration/
```

---

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Integration Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Firebase CLI
        run: npm install -g firebase-tools

      - name: Install dependencies
        run: flutter pub get
        working-directory: fridgefinder_flutter

      - name: Start Firebase Emulator
        run: firebase emulators:start --only auth,database &
        working-directory: fridgefinder_flutter

      - name: Wait for emulator
        run: sleep 10

      - name: Run integration tests
        run: flutter test test/integration/
        working-directory: fridgefinder_flutter

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: fridgefinder_flutter/coverage/lcov.info
```

---

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
- [Integration Testing Best Practices](https://docs.flutter.dev/cookbook/testing/integration/introduction)

---

## Contributing

When adding new tests:

1. Follow the existing test structure
2. Use descriptive test names with test IDs
3. Add test to appropriate category
4. Update this documentation
5. Ensure tests pass locally before committing

---

**Last Updated:** January 2025
