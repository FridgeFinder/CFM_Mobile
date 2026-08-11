# Integration Tests

End-to-end integration tests for the FridgeFinder Flutter app.

## 📊 Test Coverage

| Category | File | Tests | Status |
|----------|------|-------|--------|
| Sign-Up | `signup_integration_test.dart` | 22 | ✅ |
| Follows | `subscribe_variations_test.dart` | 25 | ✅ |
| Notifications | `notification_variations_test.dart` | 30 | ✅ |
| Geofencing | `geofencing_variations_test.dart` | 25 | ✅ |
| Status Reports | `status_report_variations_test.dart` | 20 | ✅ |
| **Total** | **5 files** | **122** | **52%** |

## 🚀 Quick Start

### 1. Start Firebase Emulator
```bash
# From project root
firebase emulators:start
```

### 2. Run Tests
```bash
# Run all tests
./scripts/run_tests.sh

# Or manually
flutter test test/integration/
```

## 📁 Test Files

### signup_integration_test.dart
Tests user authentication flows:
- Phone authentication (SU-001 to SU-007)
- Google Sign-In (SU-008 to SU-011)
- Profile creation (SU-012 to SU-020)
- Re-authentication (SU-021 to SU-022)

**Key Scenarios:**
- ✅ Valid phone number authentication
- ✅ Invalid phone formats
- ✅ Verification code handling
- ✅ Google Sign-In flow
- ✅ Profile validation
- ✅ Username uniqueness

### subscribe_variations_test.dart
Tests follow management:
- First follow flow (SUB-001 to SUB-002E)
- Permission handling (SUB-003 to SUB-005)
- Multiple follows (SUB-006 to SUB-010)
- Notification preferences (SUB-011 to SUB-017)
- Edge cases (SUB-018 to SUB-025)

**Key Scenarios:**
- ✅ Permission request timing
- ✅ FCM token management
- ✅ Notification preferences
- ✅ Follow/unfollow flows
- ✅ Network error handling

### notification_variations_test.dart
Tests push notification system:
- Notification delivery (NOT-001 to NOT-007)
- Notification types (NOT-008 to NOT-013)
- Settings interactions (NOT-014 to NOT-018)
- FCM token management (NOT-019 to NOT-026)
- Navigation (NOT-027 to NOT-030)

**Key Scenarios:**
- ✅ Foreground/background/killed delivery
- ✅ All 6 notification types
- ✅ Deep linking
- ✅ FCM token lifecycle
- ✅ Navigation provider state

### geofencing_variations_test.dart
Tests location-based proximity alerts:
- Setup scenarios (GEO-001 to GEO-006)
- Geofence triggers (GEO-007 to GEO-011)
- Platform-specific (GEO-012 to GEO-016)
- Notification delivery (GEO-017 to GEO-025)

**Key Scenarios:**
- ✅ Permission flows (While Using vs Always)
- ✅ Enter/exit geofence triggers
- ✅ iOS/Android differences
- ✅ Notification cooldown (30 min)
- ✅ Multiple fridges in proximity

### status_report_variations_test.dart
Tests fridge status reporting:
- Basic reports (REP-001 to REP-010)
- Bonus points (REP-011 to REP-020)

**Key Scenarios:**
- ✅ Anonymous vs authenticated reports
- ✅ Volunteer vs non-volunteer
- ✅ Photo upload (camera/gallery)
- ✅ Cleaning bonus (+50 points)
- ✅ Stocking bonus (+50 points)
- ✅ Combined bonuses (+110 points)

## 🛠️ Test Utilities

### Test Helpers (`../helpers/test_helpers.dart`)
```dart
// Initialize Hive for tests
await initHiveForTesting();

// Get base provider overrides
final overrides = getBaseTestOverrides();

// Create test provider container
final container = createTestProviderContainer();
```

### Firebase Helpers (`../helpers/firebase_emulator_helpers.dart`)
```dart
// Initialize Firebase emulator
await initializeFirebaseEmulator();

// Clean up Firebase data
await cleanupFirebaseEmulator();

// Create test user
final user = await createTestUser(email: 'test@example.com');

// Seed test data
await createTestDatabaseData(
  path: '/users/test-user',
  data: {'name': 'Test User'},
);
```

### Fixtures (`../fixtures/fridge_fixtures.dart`)
```dart
// Pre-defined test fridges
FridgeFixtures.verifiedFridgeWithFood
FridgeFixtures.notAtLocationFridge
FridgeFixtures.fridgeDirty
FridgeFixtures.fridgeOutOfOrder
FridgeFixtures.ghostFridge
FridgeFixtures.allFridges
```

## 📝 Writing Tests

### Basic Test Structure
```dart
testWidgets('TEST-001: Description', (WidgetTester tester) async {
  // Arrange
  final testUser = TestUser(uid: 'test-user', email: 'test@example.com');

  await tester.pumpWidget(createTestApp(
    authenticatedUser: testUser,
  ));

  // Act
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(find.text('Button'));
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Expected Result'), findsOneWidget);
});
```

### Common Patterns

#### Wait for Async Operations
```dart
// Wait for animations to complete
await tester.pumpAndSettle();

// Wait for specific duration
await tester.pump(const Duration(milliseconds: 200));

// Wait for condition
await tester.pumpAndSettle(const Duration(seconds: 5));
```

#### Find Widgets
```dart
// By text
find.text('Submit')
find.textContaining('Error')

// By type
find.byType(TextField)
find.byType(ElevatedButton)

// By icon
find.byIcon(Icons.add)

// By key
find.byKey(Key('my-widget'))
```

#### Interact with Widgets
```dart
// Tap
await tester.tap(find.text('Button'));
await tester.pumpAndSettle();

// Enter text
await tester.enterText(find.byType(TextField), 'Hello');
await tester.pumpAndSettle();

// Drag/scroll
await tester.drag(find.byType(ListView), Offset(0, -200));
await tester.pumpAndSettle();
```

## 🐛 Debugging

### Print Widget Tree
```dart
debugDumpApp();
```

### Check Widget Properties
```dart
final widget = tester.widget<TextField>(find.byType(TextField));
print('Enabled: ${widget.enabled}');
print('Text: ${widget.controller?.text}');
```

### View Firebase Emulator Data
1. Open http://localhost:4000
2. Navigate to Auth or Database tab
3. View test data in real-time

### Verbose Test Output
```bash
flutter test --verbose test/integration/signup_integration_test.dart
```

## 🔧 Troubleshooting

### Firebase Not Initialized
```bash
# Start emulator first
firebase emulators:start
```

### Port Already in Use
```bash
# Kill processes on emulator ports
lsof -ti:9099 | xargs kill -9
lsof -ti:9000 | xargs kill -9
```

### Test Timeout
```bash
# Increase timeout
flutter test --timeout=60s test/integration/
```

### Widget Not Found
```dart
// Add more pumps
await tester.pump(const Duration(milliseconds: 200));
await tester.pump(const Duration(milliseconds: 200));
await tester.pumpAndSettle();
```

## 📚 Resources

- [Parent Testing Guide](../../TESTING.md) - Comprehensive testing documentation
- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [E2E Test Plan](../../../E2E_TESTING_PLAN_EXPANDED.md) - Full test scenarios

## 🤝 Contributing

When adding new tests:

1. Follow naming convention: `CATEGORY-###: Description`
2. Use appropriate test file (or create new one)
3. Add test to this README
4. Include setup/teardown as needed
5. Document any new test patterns

---

**Last Updated:** January 2025
