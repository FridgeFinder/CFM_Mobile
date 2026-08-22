import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/core/utils/phone_number_helper.dart';

void main() {
  group('PhoneNumberHelper', () {
    test('accepts 10-digit US/Canada numbers and adds +1', () {
      expect(
        PhoneNumberHelper.formatPhoneNumber('(234) 567-8900'),
        '+12345678900',
      );
      expect(
        PhoneNumberHelper.isValidPhoneNumber('(234) 567-8900'),
        isTrue,
      );
    });

    test('accepts 11-digit US/Canada numbers with leading 1', () {
      expect(
        PhoneNumberHelper.formatPhoneNumber('+1 234 567 8900'),
        '+12345678900',
      );
      expect(
        PhoneNumberHelper.isValidPhoneNumber('+1 234 567 8900'),
        isTrue,
      );
    });

    test('rejects non-US/Canada international numbers', () {
      expect(PhoneNumberHelper.formatPhoneNumber('+44 20 7946 0958'), isNull);
      expect(PhoneNumberHelper.isValidPhoneNumber('+44 20 7946 0958'), isFalse);
    });

    test('rejects unsupported digit lengths', () {
      expect(PhoneNumberHelper.formatPhoneNumber('234567890'), isNull);
      expect(PhoneNumberHelper.formatPhoneNumber('223456789000'), isNull);
      expect(PhoneNumberHelper.isValidPhoneNumber('223456789000'), isFalse);
    });
  });
}