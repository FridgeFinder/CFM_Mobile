import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/app_logger.dart';

/// Service for generating unique usernames
class UsernameGenerator {
  final AuthRepository _authRepository;

  UsernameGenerator(this._authRepository);

  /// Fetch one unique username suggestion from the Users API.
  Future<String> generateUniqueUsername() async {
    final suggestions = await generateUsernameOptions(count: 1);
    final username = suggestions.first;
    logger.d('Generated unique username from API: $username');
    return username;
  }

  /// Fetch multiple unique username options from the Users API.
  Future<List<String>> generateUsernameOptions({int count = 3}) async {
    final suggestions = await _authRepository.getUsernameSuggestions(
      count: count,
    );
    if (suggestions.length < count) {
      logger.w(
        'Requested $count username suggestions, received ${suggestions.length}',
      );
    }
    return suggestions;
  }
}

