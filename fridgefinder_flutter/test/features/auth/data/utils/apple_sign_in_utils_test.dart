import 'package:flutter_test/flutter_test.dart';
import 'package:fridgefinder_app/src/features/auth/data/utils/apple_sign_in_utils.dart';

void main() {
  group('generateNonce', () {
    test('generates nonce with default length of 32', () {
      final nonce = generateNonce();
      expect(nonce.length, 32);
    });

    test('generates nonce with custom length', () {
      final nonce = generateNonce(length: 64);
      expect(nonce.length, 64);
    });

    test('generates unique nonces', () {
      final nonce1 = generateNonce();
      final nonce2 = generateNonce();
      expect(nonce1, isNot(equals(nonce2)));
    });

    test('generates nonce with valid charset (alphanumeric)', () {
      final nonce = generateNonce(length: 100);
      final validChars = RegExp(r'^[0-9a-zA-Z]+$');
      expect(validChars.hasMatch(nonce), isTrue);
    });
  });

  group('sha256ofString', () {
    test('produces known hash for "test"', () {
      final hash = sha256ofString('test');
      expect(
        hash,
        '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
      );
    });

    test('produces consistent hash for same input', () {
      final hash1 = sha256ofString('hello world');
      final hash2 = sha256ofString('hello world');
      expect(hash1, equals(hash2));
    });

    test('produces different hashes for different inputs', () {
      final hash1 = sha256ofString('input1');
      final hash2 = sha256ofString('input2');
      expect(hash1, isNot(equals(hash2)));
    });

    test('produces 64-character hex string', () {
      final hash = sha256ofString('anything');
      expect(hash.length, 64);
      final hexChars = RegExp(r'^[0-9a-f]+$');
      expect(hexChars.hasMatch(hash), isTrue);
    });
  });
}
