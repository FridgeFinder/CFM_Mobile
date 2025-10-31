import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Common test setup for all widget and integration tests
Future<void> setupTests() async {
  // Initialize Hive for testing
  await Hive.initFlutter();

  // Ensure WidgetsFlutterBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();
}

/// Teardown for tests
Future<void> teardownTests() async {
  // Clean up Hive boxes
  await Hive.close();
}
