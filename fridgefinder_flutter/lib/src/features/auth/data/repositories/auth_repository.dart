import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide generateNonce;
import '../../../../core/utils/app_logger.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/models/user_profile.dart';
import '../utils/apple_sign_in_utils.dart';

/// Thrown when the user cancels sign-in (dismisses the picker).
class SignInCancelledException implements Exception {
  const SignInCancelledException();
}

/// Thrown when Apple Sign-In is not available on the device.
class AppleSignInNotAvailableException implements Exception {
  const AppleSignInNotAvailableException();
}

/// Repository for authentication operations
///
/// Uses the currently selected Firebase environment (dev/prod)
/// initialized during app bootstrap in main.dart.
class AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    firebase_auth.FirebaseAuth? auth,
    Dio? dio,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _dio = dio ?? Dio(),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  /// Get current user
  firebase_auth.User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with phone number
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    try {
      // Verify phone number is in E.164 format
      if (!phoneNumber.startsWith('+')) {
        throw Exception(
          'Phone number must include country code (e.g., +1234567890)',
        );
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          // Auto-verification completed (usually on Android with SMS retriever)
          try {
            await _auth.signInWithCredential(credential);
            logger.i('Phone verification completed automatically');
          } catch (e) {
            logger.e('Error during auto-verification: $e');
            verificationFailed('Auto-verification failed: $e');
          }
        },
        verificationFailed: (error) {
          logger.e(
            'Phone verification failed: ${error.code} - ${error.message}',
          );
          String errorMessage = 'Verification failed';

          // Provide user-friendly error messages
          switch (error.code) {
            case 'invalid-phone-number':
              errorMessage =
                  'Invalid phone number format. Please include country code (e.g., +1234567890)';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMessage =
                  error.message ?? 'Verification failed. Please try again.';
          }

          verificationFailed(errorMessage);
        },
        codeSent: (verificationId, resendToken) {
          logger.i('Verification code sent to $phoneNumber');
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval timeout - user will need to enter code manually
          logger.d(
            'Auto-retrieval timeout for verification ID: $verificationId',
          );
        },
        timeout: const Duration(seconds: 60),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      verificationFailed(e.message ?? 'Authentication error');
      rethrow;
    } catch (e) {
      logger.e('Error signing in with phone: $e');
      verificationFailed('Unexpected error: $e');
      rethrow;
    }
  }

  /// Verify phone code
  Future<firebase_auth.UserCredential> verifyPhoneCode({
    required String verificationId,
    required String code,
  }) async {
    try {
      if (code.length != 6) {
        throw Exception('Verification code must be 6 digits');
      }

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      logger.i(
        'Phone verification successful: ${userCredential.user?.phoneNumber}',
      );
      final signedInUserId = userCredential.user?.uid;
      if (signedInUserId != null) {
        unawaited(updateLastLogin(signedInUserId));
      }
      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('Firebase Auth error verifying code: ${e.code} - ${e.message}');

      String errorMessage = 'Verification failed';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage =
              'Invalid verification code. Please check and try again.';
          break;
        case 'session-expired':
          errorMessage =
              'Verification session expired. Please request a new code.';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }

      throw Exception(errorMessage);
    } catch (e) {
      logger.e('Error verifying phone code: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In if not already initialized
      await _googleSignIn.initialize();

      // Attempt lightweight authentication first (no UI)
      GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      // If lightweight auth fails, use authenticate() which shows native UI
      googleUser ??= await _googleSignIn.authenticate();

      // Get authentication tokens
      final googleAuth = googleUser.authentication;

      // Create a new credential (using only idToken as accessToken is not available in new API)
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final signedInUserId = userCredential.user?.uid;
      if (signedInUserId != null) {
        unawaited(updateLastLogin(signedInUserId));
      }

      logger.i('Google sign-in successful: ${userCredential.user?.email}');
      return userCredential;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        logger.i('Google sign-in cancelled by user');
        throw const SignInCancelledException();
      }
      logger.e('Google Sign-In error: ${e.code} - $e');
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e(
        'Firebase Auth error during Google sign-in: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign out (handles both Firebase Auth and Google Sign-In)
  Future<void> signOut() async {
    try {
      // Sign out from Firebase Auth
      await _auth.signOut();

      // Sign out from Google Sign-In
      await _googleSignIn.signOut();

      logger.i('User signed out');
    } catch (e) {
      logger.e('Error signing out: $e');
      rethrow;
    }
  }

  /// Create user profile in Users API
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _dio.post('/users', data: _toCreateUserRequest(profile));
      logger.i('User profile created: ${profile.userId}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create user profile');
    } catch (e) {
      logger.e('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from Users API
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      final userPayload = _extractUserPayload(response.data);
      if (userPayload == null) {
        logger.w(
          'User profile response had no user payload for $userId: '
          '${response.data.runtimeType}',
        );
        return null;
      }

      final normalized = _normalizeUserPayload(userPayload);
      try {
        return UserProfile.fromJson(normalized);
      } catch (e) {
        // Legacy profile payloads may still carry points in non-numeric formats.
        // Points are no longer authoritative for app logic, so fall back safely.
        logger.w('User profile parse fallback for $userId: $e');
        final fallbackPayload = Map<String, dynamic>.from(normalized)
          ..remove('points');
        return UserProfile.fromJson(fallbackPayload);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        logger.w(
          'User profile lookup returned $statusCode for $userId; '
          'treating as no existing profile so sign-in can continue.',
        );
        return null;
      }
      throw _handleDioError(e, 'Failed to load user profile');
    } catch (e) {
      logger.e('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _dio.patch(
        '/users/${profile.userId}',
        data: _toUpdateUserRequest(profile),
      );
      logger.i('User profile updated: ${profile.userId}');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update user profile');
    } catch (e) {
      logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _dio.patch(
        '/users/$userId',
        data: {'lastLoginAt': DateTime.now().toIso8601String()},
      );
    } on DioException catch (e) {
      logger.e('Error updating last login: ${e.message}');
    } catch (e) {
      logger.e('Error updating last login: $e');
      // Don't rethrow - this is not critical
    }
  }

  /// Re-authenticate user with phone number
  Future<void> reauthenticateWithPhone({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(String error) verificationFailed,
  }) async {
    return signInWithPhoneNumber(
      phoneNumber: phoneNumber,
      codeSent: codeSent,
      verificationFailed: verificationFailed,
    );
  }

  /// Complete phone re-authentication with code
  Future<void> completePhoneReauthentication({
    required String verificationId,
    required String code,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      logger.i('Phone re-authentication successful');
    } catch (e) {
      logger.e('Error during phone re-authentication: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<firebase_auth.UserCredential> signInWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw const AppleSignInNotAvailableException();
      }

      final rawNonce = generateNonce();
      final hashedNonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
            idToken: appleCredential.identityToken,
            rawNonce: rawNonce,
            accessToken: appleCredential.authorizationCode,
          );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final signedInUserId = userCredential.user?.uid;
      if (signedInUserId != null) {
        unawaited(updateLastLogin(signedInUserId));
      }

      // Apple only sends name on first sign-in; update display name if provided
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      if (givenName != null || familyName != null) {
        final displayName = [
          givenName,
          familyName,
        ].where((n) => n != null && n.isNotEmpty).join(' ');
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
        }
      }

      logger.i('Apple sign-in successful: ${userCredential.user?.email}');
      return userCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        logger.i('Apple sign-in cancelled by user');
        throw const SignInCancelledException();
      }
      logger.e('Apple Sign-In authorization error: ${e.code} - ${e.message}');
      rethrow;
    } on AppleSignInNotAvailableException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e(
        'Firebase Auth error during Apple sign-in: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      logger.e('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Re-authenticate user with Apple
  Future<void> reauthenticateWithApple() async {
    try {
      final rawNonce = generateNonce();
      final hashedNonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com')
          .credential(
            idToken: appleCredential.identityToken,
            rawNonce: rawNonce,
            accessToken: appleCredential.authorizationCode,
          );

      await _auth.currentUser?.reauthenticateWithCredential(oauthCredential);

      logger.i('Apple re-authentication successful');
    } catch (e) {
      logger.e('Error during Apple re-authentication: $e');
      rethrow;
    }
  }

  /// Re-authenticate user with Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      // Initialize Google Sign-In if not already initialized
      await _googleSignIn.initialize();

      // Attempt lightweight authentication first (no UI)
      GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();

      // If lightweight auth fails, use authenticate() which shows native UI
      googleUser ??= await _googleSignIn.authenticate();

      // Get authentication tokens
      final googleAuth = googleUser.authentication;

      // Create credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Re-authenticate with Firebase
      await _auth.currentUser?.reauthenticateWithCredential(credential);

      logger.i('Google re-authentication successful');
    } catch (e) {
      logger.e('Error during Google re-authentication: $e');
      rethrow;
    }
  }

  /// Delete user account via backend-owned deletion flow.
  Future<void> deleteAccount(String userId) async {
    try {
      logger.i('deleteAccount called for userId: $userId');

      // Delete from Users API
      logger.i('Deleting user from Users API...');
      await _dio.delete('/users/$userId');
      logger.i('User deleted from Users API');

      // Backend handles Firebase account deletion. Best-effort local cleanup
      // ensures UI state is reset immediately on this device.
      try {
        await _googleSignIn.disconnect();
        logger.i('Google account disconnected');
      } catch (e) {
        logger.w('Google disconnect skipped (not a Google user): $e');
      }

      try {
        await _auth.signOut();
      } catch (e) {
        logger.w('Local auth sign-out failed after backend delete: $e');
      }

      logger.i('User account deleted successfully: $userId');
    } on DioException catch (e) {
      logger.e('Error deleting user from Users API: ${e.message}');
      rethrow;
    } catch (e) {
      logger.e('Error deleting account: $e');
      logger.e('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Check if username is unique
  Future<bool> isUsernameUnique(String username) async {
    try {
      final response = await _dio.get('/users/check-username/$username');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['available'] == true;
      }
      return false;
    } on DioException catch (e) {
      logger.e('Error checking username uniqueness: ${e.message}');
      return false;
    } catch (e) {
      logger.e('Error checking username uniqueness: $e');
      return false;
    }
  }

  Future<void> registerUserDevice({
    required String userId,
    required String installationId,
    required String token,
    required String platform,
  }) async {
    try {
      await _dio.post(
        '/users/$userId/user-devices/$installationId',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to register user device');
    }
  }

  Future<Map<String, dynamic>?> getUserDevice({
    required String userId,
    required String installationId,
  }) async {
    try {
      final response = await _dio.get(
        '/users/$userId/user-devices/$installationId',
        options: Options(
          // A missing device row is a valid state for first-time users/devices.
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 404) {
        return null;
      }

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data['device'] is Map<String, dynamic>) {
        return data['device'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioError(e, 'Failed to fetch user device');
    }
  }

  Future<void> updateUserDevice({
    required String userId,
    required String installationId,
    bool? notificationsEnabled,
    DateTime? invalidAt,
    DateTime? lastSeenAt,
    DateTime? lastDeliveredAt,
  }) async {
    final data = <String, dynamic>{
      'notificationsEnabled': notificationsEnabled,
      'invalidAt': invalidAt?.toIso8601String(),
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'lastDeliveredAt': lastDeliveredAt?.toIso8601String(),
    }..removeWhere((_, value) => value == null);

    if (data.isEmpty) return;

    try {
      await _dio.patch(
        '/users/$userId/user-devices/$installationId',
        data: data,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to update user device');
    }
  }

  Future<void> unregisterUserDevice({
    required String userId,
    required String installationId,
  }) async {
    try {
      await _dio.delete('/users/$userId/user-devices/$installationId');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to unregister user device');
    }
  }

  Map<String, dynamic> _toCreateUserRequest(UserProfile profile) {
    final request = {
      'userId': profile.userId,
      'username': profile.username,
      'email': profile.email,
      'phoneNumber': profile.phoneNumber,
      'zipcode': profile.zipcode,
    };

    request.removeWhere((_, value) => value == null);
    return request;
  }

  Map<String, dynamic> _normalizeUserPayload(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);

    // Normalize API payload fields to app model keys.
    final normalizedUserType = _normalizeUserType(normalized);
    if (normalizedUserType != null) {
      normalized['userType'] = normalizedUserType;
    } else {
      normalized.remove('userType');
    }

    final pointsRaw = normalized['points'];
    if (pointsRaw is String) {
      final parsedPoints = int.tryParse(pointsRaw);
      if (parsedPoints != null) {
        normalized['points'] = parsedPoints;
      } else {
        normalized.remove('points');
      }
    } else if (pointsRaw is num) {
      normalized['points'] = pointsRaw.toInt();
    } else if (pointsRaw != null) {
      normalized.remove('points');
    }

    normalized['createdAt'] =
        _toIsoDateString(
          normalized['createdAt'],
        );
    normalized['lastUpdated'] = _toIsoDateString(
      normalized['lastUpdated'],
    );
    normalized['lastLoginAt'] = _toIsoDateString(
      normalized['lastLoginAt'],
    );

    final settingsRaw = normalized['settings'];
    if (settingsRaw is Map<String, dynamic>) {
      final settings = {
        'emailNotificationEnabled': _boolFromJson(
          settingsRaw['emailNotificationEnabled'],
          defaultValue: false,
        ),
        'geofencingEnabled': _boolFromJson(
          settingsRaw['geofenceEnabled'],
          defaultValue: false,
        ),
      };
      normalized['settings'] = settings;
    } else {
      normalized.remove('settings');
    }

    return normalized;
  }

  String? _normalizeUserType(Map<String, dynamic> normalized) {
    final explicitType = normalized['userType'];

    final explicitTypeString = explicitType?.toString().trim().toLowerCase();
    if (explicitTypeString == 'organizer' ||
        explicitTypeString == 'host' ||
        explicitTypeString == 'volunteer' ||
        explicitTypeString == 'neighbor') {
      return explicitTypeString;
    }
    if (explicitTypeString != null && explicitTypeString.isNotEmpty) {
      return explicitTypeString;
    }

    return null;
  }

  bool _boolFromJson(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return defaultValue;
  }

  Map<String, dynamic>? _extractUserPayload(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    if (data['user'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['user'] as Map<String, dynamic>);
    }

    if (data['data'] is Map<String, dynamic>) {
      final nested = data['data'] as Map<String, dynamic>;
      if (nested['user'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(
          nested['user'] as Map<String, dynamic>,
        );
      }
      if (nested.containsKey('userId')) {
        return Map<String, dynamic>.from(nested);
      }
    }

    if (data.containsKey('userId')) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  String? _toIsoDateString(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return DateTime.tryParse(value)?.toIso8601String();
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is int) {
      // Handle both seconds and milliseconds unix timestamps.
      final isMilliseconds = value > 1000000000000;
      final dt = DateTime.fromMillisecondsSinceEpoch(
        isMilliseconds ? value : value * 1000,
      );
      return dt.toIso8601String();
    }

    return null;
  }

  Map<String, dynamic> _toUpdateUserRequest(UserProfile profile) {
    return {
      'username': profile.username,
      'email': profile.email,
      'phoneNumber': profile.phoneNumber,
      'zipcode': profile.zipcode,
      'settings': {
        'emailNotificationEnabled':
            profile.settings.emailNotificationEnabled,
        'geofenceEnabled': profile.settings.geofencingEnabled,
      },
      if (profile.lastLoginAt != null)
        'lastLoginAt': profile.lastLoginAt?.toIso8601String(),
    };
  }

  AppException _handleDioError(DioException e, String defaultMessage) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    String? apiErrorMessage;
    if (responseData is Map<String, dynamic>) {
      final errorObject = responseData['error'];
      if (errorObject is Map<String, dynamic>) {
        apiErrorMessage = errorObject['message'] as String?;
      }
      apiErrorMessage ??=
          responseData['message'] as String? ??
          responseData['error'] as String?;
    } else if (responseData is String) {
      apiErrorMessage = responseData;
    }

    if (statusCode == 401 || statusCode == 403) {
      return AuthException(
        apiErrorMessage ?? 'Authentication failed.',
        originalError: e,
      );
    }

    if (statusCode == 404) {
      return NotFoundException(
        apiErrorMessage ?? defaultMessage,
        originalError: e,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ServerException(
        apiErrorMessage ?? defaultMessage,
        statusCode: statusCode,
        originalError: e,
      );
    }

    return NetworkException(
      apiErrorMessage ?? defaultMessage,
      originalError: e,
    );
  }
}
