import 'dart:math';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/app_logger.dart';

/// Service for generating unique usernames
class UsernameGenerator {
  final AuthRepository _authRepository;
  final Random _random = Random();

  // Food-themed words for non-volunteers
  static const List<String> foodAdjectives = [
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

  static const List<String> foodNouns = [
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

  // Volunteer-themed words
  static const List<String> volunteerAdjectives = [
    'hero',
    'brave',
    'kind',
    'helpful',
    'caring',
    'generous',
    'dedicated',
    'committed',
    'passionate',
    'inspiring',
    'amazing',
    'super',
    'awesome',
    'stellar',
    'stellar',
  ];

  static const List<String> volunteerNouns = [
    'volunteer',
    'helper',
    'champion',
    'supporter',
    'ally',
    'friend',
    'neighbor',
    'citizen',
    'activist',
    'advocate',
    'guardian',
    'protector',
    'defender',
    'warrior',
    'star',
  ];

  UsernameGenerator(this._authRepository);

  /// Generate a unique username based on volunteer status
  Future<String> generateUniqueUsername({
    required bool isVolunteer,
    int maxAttempts = 10,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final username = _generateUsername(isVolunteer: isVolunteer);
      
      final isUnique = await _authRepository.isUsernameUnique(username);
      if (isUnique) {
        logger.d('Generated unique username: $username');
        return username;
      }
      
      logger.d('Username $username already exists, trying again...');
    }
    
    // If we can't generate a unique one, append timestamp
    final baseUsername = _generateUsername(isVolunteer: isVolunteer);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final username = '$baseUsername${timestamp.toString().substring(8)}';
    
    logger.w('Using timestamp-based username: $username');
    return username;
  }

  /// Generate a single username (not checked for uniqueness)
  String _generateUsername({required bool isVolunteer}) {
    final adjectives = isVolunteer ? volunteerAdjectives : foodAdjectives;
    final nouns = isVolunteer ? volunteerNouns : foodNouns;
    
    final adjective = adjectives[_random.nextInt(adjectives.length)];
    final noun = nouns[_random.nextInt(nouns.length)];
    final number = _random.nextInt(999) + 1;

    return '$adjective$noun$number';
  }

  /// Generate multiple username options
  Future<List<String>> generateUsernameOptions({
    required bool isVolunteer,
    int count = 3,
  }) async {
    final options = <String>[];
    final seen = <String>{};
    
    while (options.length < count) {
      final username = _generateUsername(isVolunteer: isVolunteer);
      if (!seen.contains(username)) {
        seen.add(username);
        final isUnique = await _authRepository.isUsernameUnique(username);
        if (isUnique) {
          options.add(username);
        }
      }
    }
    
    return options;
  }
}

