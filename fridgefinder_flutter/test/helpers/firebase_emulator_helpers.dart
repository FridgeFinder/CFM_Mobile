import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configuration for Firebase Emulator Suite
class FirebaseEmulatorConfig {
  static const String authEmulatorHost = '127.0.0.1';
  static const int authEmulatorPort = 9099;

  // Static flag to ensure Firebase is only initialized once
  static bool _isInitialized = false;
}

/// Initialize Firebase for testing with emulators
/// Call this in setUpAll() of your test files
/// Thread-safe initialization that prevents duplicate initialization
Future<void> initializeFirebaseEmulator() async {
  // Early return if already initialized
  if (FirebaseEmulatorConfig._isInitialized) {
    return;
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  // Double-check after binding is initialized
  if (FirebaseEmulatorConfig._isInitialized) {
    return;
  }

  // Check if Firebase is already initialized
  bool firebaseExists = false;
  try {
    Firebase.app();
    firebaseExists = true;
  } catch (e) {
    // Firebase not initialized yet
  }

  if (!firebaseExists) {
    // Firebase not initialized, so initialize it
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:123456789:android:test',
        messagingSenderId: '123456789',
        projectId: 'test-project',
      ),
    );
  }

  // Connect to Auth Emulator (only if not already connected)
  try {
    await FirebaseAuth.instance.useAuthEmulator(
      FirebaseEmulatorConfig.authEmulatorHost,
      FirebaseEmulatorConfig.authEmulatorPort,
    );
  } catch (e) {
    // Already connected to emulator, ignore
  }

  // Mark as initialized
  FirebaseEmulatorConfig._isInitialized = true;
}

/// Clean up Firebase emulator data between tests
/// Call this in tearDown() to ensure test isolation
Future<void> cleanupFirebaseEmulator() async {
  try {
    // Sign out any authenticated users
    await FirebaseAuth.instance.signOut();
  } catch (e) {
    // Ignore errors during cleanup
  }
}

/// Create a test user in the Firebase Auth emulator
/// Returns the User object
Future<User> createTestUser({
  String? email,
  String? phoneNumber,
  String? uid,
}) async {
  final auth = FirebaseAuth.instance;

  if (email != null) {
    // Create user with email
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: 'testPassword123',
    );
    return credential.user!;
  } else if (phoneNumber != null) {
    // For phone auth in tests, we can use a test phone number
    // The emulator allows any verification code
    throw UnimplementedError(
      'Phone auth testing requires manual verification code handling',
    );
  } else {
    // Sign in anonymously
    final credential = await auth.signInAnonymously();
    return credential.user!;
  }
}

/// Helper to sign in a test user with email
Future<User> signInTestUser(String email, String password) async {
  final auth = FirebaseAuth.instance;
  final credential = await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return credential.user!;
}

/// Helper to delete a test user
Future<void> deleteTestUser(User user) async {
  await user.delete();
}
