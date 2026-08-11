import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/common_widgets/loading_messages.dart';

void main() {
  group('LoadingMessages Tests', () {
    group('getRandomLoadingMessage', () {
      test('returns a valid message', () {
        final message = getRandomLoadingMessage();
        expect(message, isNotEmpty);
        expect(message, isA<String>());
      });

      test('returns one of the expected messages', () {
        final expectedMessages = [
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

        final message = getRandomLoadingMessage();
        expect(expectedMessages, contains(message));
      });

      test('returns different messages (tests randomness)', () {
        // Generate 50 messages and check that we get at least 3 different ones
        final messages = <String>{};
        for (var i = 0; i < 50; i++) {
          messages.add(getRandomLoadingMessage());
        }

        // With 14 possible messages and 50 calls, we should get multiple unique messages
        expect(
          messages.length,
          greaterThanOrEqualTo(3),
          reason: 'Expected at least 3 different messages out of 50 calls',
        );
      });

      test('returns different messages on consecutive calls', () {
        // Make 10 calls and ensure not all are the same
        final messages = <String>[];
        for (var i = 0; i < 10; i++) {
          messages.add(getRandomLoadingMessage());
        }

        final uniqueMessages = messages.toSet();
        expect(
          uniqueMessages.length,
          greaterThan(1),
          reason:
              'Expected at least 2 different messages over 10 consecutive calls',
        );
      });

      test('messages are all fridge/food related', () {
        // Verify the theme of messages by checking common keywords
        final keywords = [
          'loading',
          'defrost',
          'thaw',
          'chill',
          'cool',
          'stock',
          'expiration',
          'organiz',
          'marinat',
          'preserv',
          'fresh',
          'inventory',
          'ice',
          'freezer',
          'leftover',
        ];

        // Get all possible messages by calling multiple times
        final messages = <String>{};
        for (var i = 0; i < 100; i++) {
          messages.add(getRandomLoadingMessage());
        }

        // Check that each message contains at least one keyword (case insensitive)
        for (final message in messages) {
          final lowerMessage = message.toLowerCase();
          final hasKeyword = keywords.any(
            (keyword) => lowerMessage.contains(keyword),
          );
          expect(
            hasKeyword,
            isTrue,
            reason:
                'Message "$message" should contain fridge/food-related keywords',
          );
        }
      });

      test('messages end with ellipsis or period', () {
        // Get all possible messages
        final messages = <String>{};
        for (var i = 0; i < 100; i++) {
          messages.add(getRandomLoadingMessage());
        }

        // Check that each message ends appropriately
        for (final message in messages) {
          expect(
            message.endsWith('...') || message.endsWith('.'),
            isTrue,
            reason: 'Message "$message" should end with ellipsis or period',
          );
        }
      });

      test('no empty or whitespace-only messages', () {
        // Check 100 messages to ensure none are empty or whitespace-only
        for (var i = 0; i < 100; i++) {
          final message = getRandomLoadingMessage();
          expect(message.trim(), isNotEmpty);
          expect(message, isNot(matches(r'^\s*$')));
        }
      });

      test('messages have reasonable length', () {
        // Ensure messages are not too short or too long
        final messages = <String>{};
        for (var i = 0; i < 100; i++) {
          messages.add(getRandomLoadingMessage());
        }

        for (final message in messages) {
          expect(
            message.length,
            greaterThanOrEqualTo(5),
            reason: 'Message "$message" is too short',
          );
          expect(
            message.length,
            lessThanOrEqualTo(50),
            reason: 'Message "$message" is too long',
          );
        }
      });

      test('distribution is reasonably uniform', () {
        // Check that messages are distributed somewhat uniformly
        // Generate 1400 messages (100 per expected message)
        final messageCounts = <String, int>{};
        for (var i = 0; i < 1400; i++) {
          final message = getRandomLoadingMessage();
          messageCounts[message] = (messageCounts[message] ?? 0) + 1;
        }

        // With 14 messages and 1400 calls, we expect ~100 per message
        // Allow for variance: minimum 50, maximum 150
        for (final entry in messageCounts.entries) {
          expect(
            entry.value,
            greaterThanOrEqualTo(50),
            reason:
                'Message "${entry.key}" appears too infrequently (${entry.value} times)',
          );
          expect(
            entry.value,
            lessThanOrEqualTo(150),
            reason:
                'Message "${entry.key}" appears too frequently (${entry.value} times)',
          );
        }

        // Verify we got all 14 expected messages
        expect(
          messageCounts.length,
          equals(14),
          reason: 'Should have all 14 different messages',
        );
      });
    });
  });
}
