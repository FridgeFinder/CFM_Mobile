import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/utils/firebase_helpers.dart';

void main() {
  group('convertFirebaseMap', () {
    test('converts simple Map<Object?, Object?> to Map<String, dynamic>', () {
      final input = <Object?, Object?>{
        'name': 'John',
        'age': 25,
      };

      final result = convertFirebaseMap(input);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['name'], 'John');
      expect(result['age'], 25);
    });

    test('recursively converts nested maps', () {
      final input = <Object?, Object?>{
        'userId': '123',
        'settings': <Object?, Object?>{
          'notificationsEnabled': true,
          'geofencingEnabled': false,
        },
      };

      final result = convertFirebaseMap(input);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['userId'], '123');
      expect(result['settings'], isA<Map<String, dynamic>>());
      expect(result['settings']['notificationsEnabled'], true);
      expect(result['settings']['geofencingEnabled'], false);
    });

    test('converts lists containing maps', () {
      final input = <Object?, Object?>{
        'items': [
          <Object?, Object?>{'id': '1', 'name': 'Item 1'},
          <Object?, Object?>{'id': '2', 'name': 'Item 2'},
        ],
      };

      final result = convertFirebaseMap(input);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['items'], isA<List>());
      expect(result['items'][0], isA<Map<String, dynamic>>());
      expect(result['items'][0]['id'], '1');
      expect(result['items'][1]['name'], 'Item 2');
    });

    test('handles deeply nested structures', () {
      final input = <Object?, Object?>{
        'level1': <Object?, Object?>{
          'level2': <Object?, Object?>{
            'level3': <Object?, Object?>{
              'value': 'deep',
            },
          },
        },
      };

      final result = convertFirebaseMap(input);

      expect(result['level1']['level2']['level3']['value'], 'deep');
    });
  });
}
