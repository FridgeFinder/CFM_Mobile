import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

/// Setup Hive for testing with temporary directory
Future<void> initHiveForTesting() async {
  // Initialize Hive in test environment
  try {
    // Create a temporary directory for this test run
    final testDir = Directory.systemTemp.createTempSync('hive_test_');

    // Initialize Hive with test directory
    Hive.init(testDir.path);
  } catch (e) {
    // Already initialized or unable to init - that's fine for some test scenarios
    // In unit tests, providers may gracefully handle Hive not being initialized
  }
}

/// Clean up Hive after tests
Future<void> cleanupHive() async {
  try {
    // Close all boxes
    await Hive.close();
  } catch (e) {
    // Hive may not be open, that's fine
  }
}
