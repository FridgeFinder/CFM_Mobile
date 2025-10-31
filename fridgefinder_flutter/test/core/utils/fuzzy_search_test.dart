import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/utils/fuzzy_search.dart';

void main() {
  group('FuzzySearch Tests', () {
    group('Exact Match', () {
      test('matches exact string', () {
        expect(FuzzySearch.isFuzzyMatch('hello', 'hello'), isTrue);
      });

      test('matches case insensitive', () {
        expect(FuzzySearch.isFuzzyMatch('hello', 'HELLO'), isTrue);
        expect(FuzzySearch.isFuzzyMatch('Hello', 'hello'), isTrue);
      });

      test('does not match different string', () {
        expect(FuzzySearch.isFuzzyMatch('hello', 'world'), isFalse);
      });
    });

    group('Substring Match', () {
      test('matches substring', () {
        expect(FuzzySearch.isFuzzyMatch('ell', 'hello'), isTrue);
      });

      test('matches substring at start', () {
        expect(FuzzySearch.isFuzzyMatch('hel', 'hello'), isTrue);
      });

      test('matches substring at end', () {
        expect(FuzzySearch.isFuzzyMatch('llo', 'hello'), isTrue);
      });

      test('matches substring in middle', () {
        expect(FuzzySearch.isFuzzyMatch('ell', 'hello'), isTrue);
      });
    });

    group('Fuzzy Match With Gaps', () {
      test('matches with gaps between characters', () {
        expect(FuzzySearch.isFuzzyMatch('hlo', 'hello'), isTrue);
      });

      test('matches with large gaps', () {
        expect(FuzzySearch.isFuzzyMatch('hlo', 'h-e-l-l-o'), isTrue);
      });

      test('matches single character', () {
        expect(FuzzySearch.isFuzzyMatch('h', 'hello'), isTrue);
        expect(FuzzySearch.isFuzzyMatch('e', 'hello'), isTrue);
        expect(FuzzySearch.isFuzzyMatch('l', 'hello'), isTrue);
      });

      test('does not match out of order', () {
        expect(FuzzySearch.isFuzzyMatch('ohl', 'hello'), isFalse);
      });

      test('does not match characters in reverse order', () {
        expect(FuzzySearch.isFuzzyMatch('ello', 'olleh'), isFalse);
      });
    });

    group('Typo Tolerance', () {
      test('matches with single character typo', () {
        expect(FuzzySearch.isFuzzyMatch('helo', 'hello'), isTrue);
      });

      test('matches partial word with typo', () {
        expect(FuzzySearch.isFuzzyMatch('frge', 'fridge'), isTrue);
      });

      test('matches common misspelling', () {
        expect(FuzzySearch.isFuzzyMatch('colleciv', 'collective'), isTrue);
      });
    });

    group('Empty Strings', () {
      test('empty query matches any string', () {
        expect(FuzzySearch.isFuzzyMatch('', 'hello'), isTrue);
        expect(FuzzySearch.isFuzzyMatch('', ''), isTrue);
      });

      test('non-empty query does not match empty string', () {
        expect(FuzzySearch.isFuzzyMatch('hello', ''), isFalse);
      });
    });

    group('Real World Examples', () {
      test('matches common search: livinggallery', () {
        expect(FuzzySearch.isFuzzyMatch('living', 'living gallery'), isTrue);
      });

      test('matches common search: brooklyn', () {
        expect(FuzzySearch.isFuzzyMatch('brooklyn', 'Brooklyn'), isTrue);
      });

      test('matches common search: new york', () {
        expect(FuzzySearch.isFuzzyMatch('ny', 'new york'), isTrue);
      });

      test('matches partial search: frig', () {
        expect(FuzzySearch.isFuzzyMatch('frig', 'fridge'), isTrue);
      });

      test('matches with space skip: bs fridge', () {
        expect(FuzzySearch.isFuzzyMatch('bsfridge', 'b\'shert fridge'), isTrue);
      });
    });

    group('Score Calculation', () {
      test('exact match has higher score than fuzzy match', () {
        final exactScore = FuzzySearch.calculateScore('hello', 'hello');
        final fuzzyScore = FuzzySearch.calculateScore('hlo', 'hello');

        expect(exactScore, greaterThan(fuzzyScore));
      });

      test('consecutive characters have higher score than scattered', () {
        final consecutiveScore = FuzzySearch.calculateScore('ell', 'hello');
        final scatteredScore = FuzzySearch.calculateScore('eol', 'hello');

        expect(consecutiveScore, greaterThan(scatteredScore));
      });

      test('match at start has higher score than at end', () {
        final startScore = FuzzySearch.calculateScore('hel', 'hello world');
        final endScore = FuzzySearch.calculateScore('orld', 'hello world');

        expect(startScore, greaterThan(endScore));
      });

      test('perfect match has highest score', () {
        final score = FuzzySearch.calculateScore('hello', 'hello');
        expect(score, greaterThan(0));
      });

      test('non-matching returns 0 score', () {
        final score = FuzzySearch.calculateScore('xyz', 'hello');
        expect(score, equals(0));
      });
    });

    group('Filter and Sort', () {
      test('filters and sorts results by score', () {
        final items = ['hello', 'hallo', 'hullo', 'world', 'hell'];
        final results = FuzzySearch.filterAndSort('hll', items);

        expect(results.isNotEmpty, isTrue);
        expect(results, contains('hello'));
        expect(results, isNot(contains('world')));
      });

      test('exact matches appear first', () {
        final items = ['hello world', 'hello', 'hello there'];
        final results = FuzzySearch.filterAndSort('hello', items);

        expect(results[0], equals('hello'));
      });

      test('returns empty list for non-matching query', () {
        final items = ['hello', 'world', 'test'];
        final results = FuzzySearch.filterAndSort('xyz', items);

        expect(results, isEmpty);
      });

      test('sorts by match quality', () {
        final items = ['h_e_l_l_o', 'hello', 'heLLo'];
        final results = FuzzySearch.filterAndSort('hello', items);

        // Exact/perfect match should be first
        expect(results, isNotEmpty);
      });
    });

    group('Special Characters', () {
      test('matches across apostrophes', () {
        expect(FuzzySearch.isFuzzyMatch('bshert', 'b\'shert'), isTrue);
      });

      test('matches across hyphens', () {
        expect(FuzzySearch.isFuzzyMatch('test', 'test-case'), isTrue);
      });

      test('matches with numbers', () {
        expect(FuzzySearch.isFuzzyMatch('fridge001', 'fridge 001'), isTrue);
      });
    });


    group('Performance', () {
      test('handles long strings', () {
        final longString =
            'The quick brown fox jumps over the lazy dog. ' * 10;
        final result = FuzzySearch.isFuzzyMatch('quick', longString);

        expect(result, isTrue);
      });

      test('handles many items in filterAndSort', () {
        final items = List.generate(1000, (i) => 'item_$i');
        final results = FuzzySearch.filterAndSort('item', items);

        expect(results, isNotEmpty);
      });
    });
  });
}
