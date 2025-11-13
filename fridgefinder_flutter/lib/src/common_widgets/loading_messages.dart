import 'dart:math';

/// Get a random loading message related to fridges and food
String getRandomLoadingMessage() {
  final messages = [
    'Loading...',
    'Defrosting...',
    'Thawing...',
    'Chilling...',
    'Cooling down...',
    'Stocking up...',
    'Checking expiration dates...',
    'Organizing shelves...',
    'Marinating...',
    'Preserving freshness...',
    'Keeping it cool...',
    'Inspecting inventory...',
    'Refilling ice trays...',
    'Defrosting freezer...',
    'Sorting leftovers...',
  ];

  final random = Random();
  return messages[random.nextInt(messages.length)];
}
