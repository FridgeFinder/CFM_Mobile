import 'dart:math';
import 'dart:async';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/app_logger.dart';

/// Service for generating unique usernames
class UsernameGenerator {
  final AuthRepository _authRepository;
  final Random _random = Random();

  static const List<String> adjectives = [
    'happy',
    'fresh',
    'tasty',
    'yummy',
    'crispy',
    'juicy',
    'sweet',
    'cool',
    'chill',
    'fresh',
    'bright',
    'cheerful',
    'delicious',
    'savory',
    'nutritious',
  ];

  static const List<String> nouns = [
    'fridge',
    'foodie',
    'feast',
    'meal',
    'snack',
    'bite',
    'treat',
    'dish',
    'plate',
    'kitchen',
    'pantry',
    'larder',
    'grocer',
    'market',
    'bounty',
  ];

  UsernameGenerator(this._authRepository);

  /// Generate a unique username.
  Future<String> generateUniqueUsername({int maxAttempts = 10}) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final username = _generateUsername();

      bool isUnique = false;
      try {
        isUnique = await _authRepository
            .isUsernameUnique(username)
            .timeout(const Duration(seconds: 2));
      } on TimeoutException {
        logger.w(
          'Username uniqueness check timed out for $username (attempt ${attempt + 1}/$maxAttempts)',
        );
        continue;
      }

      if (isUnique) {
        logger.d('Generated unique username: $username');
        return username;
      }

      logger.d('Username $username already exists, trying again...');
    }

    // If API checks are slow/unavailable, fall back to a locally unique-ish value.
    final username = generateOfflineUsername();

    logger.w('Using timestamp-based username: $username');
    return username;
  }

  /// Generate a local fallback username when API checks are slow/unavailable.
  String generateOfflineUsername() {
    final baseUsername = _generateUsername();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$baseUsername${timestamp.toString().substring(8)}';
  }

  /// Generate a single username (not checked for uniqueness)
  String _generateUsername() {
    final adjective = adjectives[_random.nextInt(adjectives.length)];
    final noun = nouns[_random.nextInt(nouns.length)];
    final number = _random.nextInt(999) + 1;

    return '$adjective$noun$number';
  }

  /// Generate multiple username options
  Future<List<String>> generateUsernameOptions({int count = 3}) async {
    final options = <String>[];
    final seen = <String>{};

    while (options.length < count) {
      final username = _generateUsername();
      if (!seen.contains(username)) {
        seen.add(username);
        final isUnique = await _authRepository
            .isUsernameUnique(username)
            .timeout(const Duration(seconds: 2), onTimeout: () => false);
        if (isUnique) {
          options.add(username);
        }
      }
    }

    return options;
  }
}

