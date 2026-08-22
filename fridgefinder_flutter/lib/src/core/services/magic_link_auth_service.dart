import 'dart:async';

import 'package:app_links/app_links.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../utils/app_logger.dart';

enum MagicLinkAuthEventType {
  signedIn,
  missingEmail,
  expiredOrInvalidLink,
  failure,
}

class MagicLinkAuthEvent {
  const MagicLinkAuthEvent({required this.type, this.message});

  final MagicLinkAuthEventType type;
  final String? message;
}

/// Listens for Firebase email-link deep links and completes sign-in in-app.
class MagicLinkAuthService {
  MagicLinkAuthService({
    required AuthRepository authRepository,
    AppLinks? appLinks,
  }) : _authRepository = authRepository,
       _appLinks = appLinks ?? AppLinks();

  final AuthRepository _authRepository;
  final AppLinks _appLinks;

  final StreamController<MagicLinkAuthEvent> _eventsController =
      StreamController<MagicLinkAuthEvent>.broadcast();

  StreamSubscription<Uri>? _uriSubscription;
  bool _initialized = false;
  String? _pendingEmailLink;

  Stream<MagicLinkAuthEvent> get events => _eventsController.stream;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingUri(initialUri);
      }
    } catch (e) {
      logger.w('Failed to read initial deep link: $e');
    }

    _uriSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleIncomingUri(uri),
      onError: (Object error, StackTrace stackTrace) {
        logger.e('Magic link stream error: $error', stackTrace: stackTrace);
        _eventsController.add(
          const MagicLinkAuthEvent(
            type: MagicLinkAuthEventType.failure,
            message: 'Failed to process authentication link.',
          ),
        );
      },
    );
  }

  Future<void> confirmPendingLinkWithEmail(String email) async {
    final pendingLink = _pendingEmailLink;
    if (pendingLink == null || pendingLink.isEmpty) {
      _eventsController.add(
        const MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.failure,
          message: 'No pending sign-in link found. Request a new link.',
        ),
      );
      return;
    }

    try {
      await _authRepository.completeEmailLinkSignIn(
        emailLink: pendingLink,
        emailOverride: email.trim(),
      );
      _pendingEmailLink = null;
      _eventsController.add(
        const MagicLinkAuthEvent(type: MagicLinkAuthEventType.signedIn),
      );
    } on MagicLinkExpiredException {
      _pendingEmailLink = null;
      _eventsController.add(
        const MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.expiredOrInvalidLink,
          message: 'This sign-in link is invalid or expired. Request a new one.',
        ),
      );
    } catch (e) {
      logger.e('Failed to confirm pending magic link sign-in: $e');
      _eventsController.add(
        MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.failure,
          message: 'Could not complete sign-in: $e',
        ),
      );
    }
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final link = uri.toString();
    if (!_authRepository.isSignInWithEmailLink(link)) {
      return;
    }

    try {
      await _authRepository.completeEmailLinkSignIn(emailLink: link);
      _pendingEmailLink = null;
      _eventsController.add(
        const MagicLinkAuthEvent(type: MagicLinkAuthEventType.signedIn),
      );
    } on MagicLinkEmailMissingException {
      _pendingEmailLink = link;
      _eventsController.add(
        const MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.missingEmail,
          message:
              'To finish sign-in, enter the email address used to request the link.',
        ),
      );
    } on MagicLinkExpiredException {
      _pendingEmailLink = null;
      _eventsController.add(
        const MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.expiredOrInvalidLink,
          message: 'This sign-in link is invalid or expired. Request a new one.',
        ),
      );
    } catch (e) {
      logger.e('Failed to process email sign-in link: $e');
      _pendingEmailLink = null;
      _eventsController.add(
        MagicLinkAuthEvent(
          type: MagicLinkAuthEventType.failure,
          message: 'Could not sign in with link: $e',
        ),
      );
    }
  }

  void dispose() {
    _uriSubscription?.cancel();
    _eventsController.close();
  }
}
