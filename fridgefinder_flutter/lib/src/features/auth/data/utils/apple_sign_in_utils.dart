import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Generates a cryptographically secure random nonce for Apple Sign-In.
String generateNonce({int length = 32}) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

/// Returns the SHA-256 hash of [input] as a lowercase hex string.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
