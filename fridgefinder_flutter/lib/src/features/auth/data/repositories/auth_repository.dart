import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' hide generateNonce;
import '../../../../core/utils/app_logger.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/utils/firebase_helpers.dart';
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
/// PRODUCTION ENVIRONMENT ONLY
/// Firebase Auth always uses production (FirebaseAuth.instance).
/// Not affected by fridge data API environment setting.
class AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final DatabaseReference _database;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    firebase_auth.FirebaseAuth? auth,
    DatabaseReference? database,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _database = database ?? DatabaseProvider.databaseRef,
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
        throw Exception('Phone number must include country code (e.g., +1234567890)');
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
          logger.e('Phone verification failed: ${error.code} - ${error.message}');
          String errorMessage = 'Verification failed';
          
          // Provide user-friendly error messages
          switch (error.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format. Please include country code (e.g., +1234567890)';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = error.message ?? 'Verification failed. Please try again.';
          }
          
          verificationFailed(errorMessage);
        },
        codeSent: (verificationId, resendToken) {
          logger.i('Verification code sent to $phoneNumber');
          codeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          // Auto-retrieval timeout - user will need to enter code manually
          logger.d('Auto-retrieval timeout for verification ID: $verificationId');
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
      logger.i('Phone verification successful: ${userCredential.user?.phoneNumber}');
      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      logger.e('Firebase Auth error verifying code: ${e.code} - ${e.message}');
      
      String errorMessage = 'Verification failed';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code. Please check and try again.';
          break;
        case 'session-expired':
          errorMessage = 'Verification session expired. Please request a new code.';
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
      GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();
      
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
      logger.e('Firebase Auth error during Google sign-in: ${e.code} - ${e.message}');
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

  /// Create user profile in Realtime Database
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      final userRef = _database.child('users').child(profile.userId);
      await userRef.set(profile.toJson());
      logger.i('User profile created: ${profile.userId}');
    } catch (e) {
      logger.e('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile from Realtime Database
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, Object?>;
        return UserProfile.fromJson(
          convertFirebaseMap(data),
        );
      }
      return null;
    } catch (e) {
      logger.e('Error getting user profile: $e');
      return null;
    }
  }

  /// Find user profile by email or phone number (for existing user detection)
  Future<UserProfile?> findUserProfileByEmailOrPhone({
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final usersSnapshot = await _database.child('users').get();
      if (!usersSnapshot.exists) return null;

      final usersData = usersSnapshot.value as Map<Object?, Object?>;

      for (final entry in usersData.entries) {
        final userData = entry.value as Map<Object?, Object?>;
        final userMap = convertFirebaseMap(userData);

        // Check if email or phone matches
        if ((email != null && userMap['email'] == email) ||
            (phoneNumber != null && userMap['phoneNumber'] == phoneNumber)) {
          return UserProfile.fromJson(userMap);
        }
      }

      return null;
    } catch (e) {
      logger.e('Error finding user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      final userRef = _database.child('users').child(profile.userId);
      await userRef.update(profile.toJson());
      logger.i('User profile updated: ${profile.userId}');
    } catch (e) {
      logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String userId) async {
    try {
      await _database
          .child('users')
          .child(userId)
          .update({'lastLoginAt': DateTime.now().toIso8601String()});
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

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple only sends name on first sign-in; update display name if provided
      final givenName = appleCredential.givenName;
      final familyName = appleCredential.familyName;
      if (givenName != null || familyName != null) {
        final displayName = [givenName, familyName]
            .where((n) => n != null && n.isNotEmpty)
            .join(' ');
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
      logger.e('Firebase Auth error during Apple sign-in: ${e.code} - ${e.message}');
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

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
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
      GoogleSignInAccount? googleUser = await _googleSignIn.attemptLightweightAuthentication();

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

  /// Delete user account (requires recent authentication)
  Future<void> deleteAccount(String userId) async {
    try {
      logger.i('deleteAccount called for userId: $userId');

      // Delete from Realtime Database
      logger.i('Deleting user from Realtime Database...');
      await _database.child('users').child(userId).remove();
      logger.i('User deleted from Realtime Database');

      // Delete from Firebase Auth
      logger.i('Deleting user from Firebase Auth...');
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        logger.e('No current user found in Firebase Auth');
        throw Exception('No authenticated user found');
      }

      // Revoke Google access and clear cached account so the next sign-in
      // shows the account picker instead of silently reusing the credential.
      try {
        await _googleSignIn.disconnect();
        logger.i('Google account disconnected');
      } catch (e) {
        // Non-fatal: user may not have signed in with Google
        logger.w('Google disconnect skipped (not a Google user): $e');
      }

      logger.i('Current user ID: ${currentUser.uid}');
      await currentUser.delete();
      logger.i('User deleted from Firebase Auth');

      logger.i('User account deleted successfully: $userId');
    } catch (e) {
      logger.e('Error deleting account: $e');
      logger.e('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Check if username is unique
  Future<bool> isUsernameUnique(String username) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('username')
          .equalTo(username)
          .get();
      return !snapshot.exists;
    } catch (e) {
      logger.e('Error checking username uniqueness: $e');
      return false;
    }
  }
}

