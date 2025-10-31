/// Fuzzy search utility for filtering text
class FuzzySearch {
  /// Performs fuzzy matching between a search query and a target string
  /// Returns true if the query matches the target (fuzzy match)
  ///
  /// Example:
  /// - "frdge" matches "fridge"
  /// - "sf" matches "san francisco"
  /// - "txt" matches "test"
  static bool isFuzzyMatch(String query, String target) {
    if (query.isEmpty) return true;
    if (target.isEmpty) return false;

    final queryLower = query.toLowerCase();
    final targetLower = target.toLowerCase();

    int queryIndex = 0;
    int targetIndex = 0;

    while (queryIndex < queryLower.length && targetIndex < targetLower.length) {
      if (queryLower[queryIndex] == targetLower[targetIndex]) {
        queryIndex++;
      }
      targetIndex++;
    }

    return queryIndex == queryLower.length;
  }

  /// Calculates a fuzzy match score between 0 and 1
  /// Higher score means better match
  /// Used for sorting results by relevance
  static double calculateScore(String query, String target) {
    if (query.isEmpty) return 1.0;
    if (target.isEmpty) return 0.0;

    if (!isFuzzyMatch(query, target)) return 0.0;

    final queryLower = query.toLowerCase();
    final targetLower = target.toLowerCase();

    // Exact match gets highest score
    if (queryLower == targetLower) return 1.0;

    // Substring match gets high score
    if (targetLower.contains(queryLower)) {
      // Bonus for match at start of word
      if (targetLower.startsWith(queryLower)) {
        return 0.9;
      }
      return 0.8;
    }

    // Fuzzy match score based on:
    // 1. How early the matches occur in the target
    // 2. How close the matches are together
    int queryIndex = 0;
    int targetIndex = 0;
    int totalDistance = 0;
    int matches = 0;

    while (queryIndex < queryLower.length && targetIndex < targetLower.length) {
      if (queryLower[queryIndex] == targetLower[targetIndex]) {
        totalDistance += targetIndex;
        queryIndex++;
        matches++;
      }
      targetIndex++;
    }

    if (matches == 0) return 0.0;

    // Score based on average position and length ratio
    final avgDistance = totalDistance / matches;
    final lengthRatio = queryLower.length / targetLower.length;
    final positionScore = 1.0 - (avgDistance / targetLower.length);
    final score = (positionScore * 0.7 + lengthRatio * 0.3) * 0.7;

    return score.clamp(0.0, 0.7);
  }

  /// Filters a list of strings by fuzzy search query
  /// Returns sorted results with best matches first
  static List<String> filterAndSort(String query, List<String> items) {
    if (query.isEmpty) return items;

    final matches = items.where((item) => isFuzzyMatch(query, item)).toList();

    // Sort by relevance score
    matches.sort((a, b) {
      final scoreA = calculateScore(query, a);
      final scoreB = calculateScore(query, b);
      return scoreB.compareTo(scoreA);
    });

    return matches;
  }
}
