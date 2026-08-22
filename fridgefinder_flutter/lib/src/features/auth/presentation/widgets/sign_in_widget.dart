import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/environment_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../../../core/utils/phone_number_helper.dart';

/// Sign-in widget supporting phone and Gmail authentication
class SignInWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onClose;

  const SignInWidget({super.key, this.onSignInSuccess, this.onClose});

  @override
  ConsumerState<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends ConsumerState<SignInWidget> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  OverlayEntry? _overlaySnackBarEntry;
  Timer? _overlaySnackBarTimer;
  bool _isCodeSent = false;
  String? _verificationId;
  bool _isLoading = false;
  String _signInType = 'email';

  bool get _isPhoneFlow => _signInType == 'phone';

  void _dismissOverlaySnackBar() {
    _overlaySnackBarTimer?.cancel();
    _overlaySnackBarTimer = null;
    _overlaySnackBarEntry?.remove();
    _overlaySnackBarEntry = null;
  }

  void _showOverlaySnackBar(
    String message, {
    Widget? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    SnackbarDuration duration = SnackbarDuration.short_,
  }) {
    if (!mounted) {
      return;
    }

    _dismissOverlaySnackBar();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    final entry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: IgnorePointer(
          ignoring: true,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: SnackbarM3E(
                  message: message,
                  icon: icon,
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  margin: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    _overlaySnackBarEntry = entry;
    _overlaySnackBarTimer = Timer(duration.duration, _dismissOverlaySnackBar);
  }

  Future<UserProfile?> _getExistingProfileOrNull({
    required AuthRepository repository,
    required String userId,
    required String provider,
  }) async {
    try {
      return await repository.getUserProfile(userId);
    } catch (e) {
      // Sign-in itself succeeded; treat profile lookup issues as "new user" flow.
      logger.w(
        'Continuing $provider sign-in without existing profile due to lookup error: $e',
      );
      return null;
    }
  }

  @override
  void dispose() {
    _dismissOverlaySnackBar();
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _closeSignIn() {
    if (widget.onClose != null) {
      widget.onClose!.call();
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  void _completeSignIn() {
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    widget.onSignInSuccess?.call();
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showOverlaySnackBar('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final env = ref.read(environmentProvider);

      await repository.sendEmailSignInLink(
        email: email,
        magicLinkUrl: env.magicLinkUrl,
        appBundleId: env.appBundleId,
        androidPackageName: env.androidPackageName,
      );

      if (!mounted) {
        return;
      }

      _showOverlaySnackBar(
        'Magic sign-in link sent. Check your email and open it on this device.',
      );
    } catch (e) {
      logger.e('Error sending email sign-in link: $e');
      if (!mounted) {
        return;
      }
      _showOverlaySnackBar('Could not send sign-in link: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithPhone() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showOverlaySnackBar('Please enter your phone number');
      return;
    }

    // Format phone number to E.164 format
    final formattedPhone = PhoneNumberHelper.formatPhoneNumber(phoneNumber);
    if (formattedPhone == null ||
        !PhoneNumberHelper.isValidPhoneNumber(phoneNumber)) {
      _showOverlaySnackBar(
        'Please enter a valid US or Canada phone number',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signInWithPhoneNumber(
        phoneNumber: formattedPhone,
        codeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
          });
          _showOverlaySnackBar('Verification code sent');
        },
        verificationFailed: (error) {
          setState(() => _isLoading = false);
          _showOverlaySnackBar('Verification failed: $error');
        },
      );
    } catch (e) {
      logger.e('Error signing in with phone: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        _showOverlaySnackBar('Error: $e');
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) {
      _showOverlaySnackBar('Please enter the verification code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final credential = await repository.verifyPhoneCode(
        verificationId: _verificationId!,
        code: code,
      );

      if (!mounted) return;

      // Check if profile exists for the authenticated Firebase user.
      final existingProfile = await _getExistingProfileOrNull(
        repository: repository,
        userId: credential.user!.uid,
        provider: 'phone',
      );

      if (existingProfile == null) {
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _completeSignIn();
        }
      });
    } catch (e) {
      logger.e('Error verifying code: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showOverlaySnackBar('Error verifying code: $e');
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final credential = await repository.signInWithApple();

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if profile exists for the authenticated Firebase user.
      final existingProfile = await _getExistingProfileOrNull(
        repository: repository,
        userId: credential.user!.uid,
        provider: 'apple',
      );

      if (existingProfile == null) {
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _completeSignIn();
        }
      });
    } on SignInCancelledException {
      // User cancelled Apple sign-in — silently reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } on AppleSignInNotAvailableException {
      if (mounted) {
        setState(() => _isLoading = false);
        _showOverlaySnackBar('Apple Sign-In is not available on this device');
      }
    } catch (e) {
      logger.e('Error signing in with Apple: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showOverlaySnackBar('Apple Sign-In error: $e');
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final credential = await repository.signInWithGoogle();

      if (!mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if profile exists for the authenticated Firebase user.
      final existingProfile = await _getExistingProfileOrNull(
        repository: repository,
        userId: credential.user!.uid,
        provider: 'google',
      );

      if (existingProfile == null) {
        setState(() => _isLoading = false);
      } else {
        setState(() => _isLoading = false);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _completeSignIn();
        }
      });
    } on SignInCancelledException {
      // User cancelled Google sign-in — silently reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showOverlaySnackBar('Google Sign-In error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: M3ESpacing.sm,
                  right: M3ESpacing.sm,
                ),
                child: IconButton(
                  onPressed: _closeSignIn,
                  tooltip: 'Close sign in',
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed) ||
                          states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.focused)) {
                        return const Color.fromRGBO(0, 0, 0, 0.15);
                      }

                      return const Color.fromRGBO(0, 0, 0, 0.08);
                    }),
                    foregroundColor: WidgetStatePropertyAll(
                      colorScheme.onSurfaceVariant,
                    ),
                    fixedSize: const WidgetStatePropertyAll(Size(36, 36)),
                    shape: const WidgetStatePropertyAll(CircleBorder()),
                  ),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  M3ESpacing.md,
                  M3ESpacing.xs,
                  M3ESpacing.md,
                  M3ESpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Welcome!',
                          textAlign: TextAlign.center,
                          style: M3ETypography.displaySmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: M3ESpacing.sm),
                        Text(
                          'Start getting notified when your local fridges are stocked, need support, or are moved.',
                          textAlign: TextAlign.center,
                          style: M3ETypography.bodyLarge,
                        ),
                        SizedBox(height: M3ESpacing.xl),
                        CardM3E(
                          child: Padding(
                            padding: M3ESpacing.all(M3ESpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (!_isCodeSent) ...[
                                  Text(
                                    'Sign in with',
                                    style: M3ETypography.labelLarge,
                                  ),
                                  SizedBox(height: M3ESpacing.sm),
                                  SegmentedButton<String>(
                                    segments: const [
                                      ButtonSegment<String>(
                                        value: 'email',
                                        label: Text('Email'),
                                      ),
                                      ButtonSegment<String>(
                                        value: 'phone',
                                        label: Text('Phone'),
                                      ),
                                    ],
                                    selected: <String>{_signInType},
                                    showSelectedIcon: false,
                                    onSelectionChanged: _isLoading
                                        ? null
                                        : (value) {
                                            if (value.isEmpty) {
                                              return;
                                            }

                                            setState(() {
                                              _signInType = value.first;
                                              _codeController.clear();
                                              _verificationId = null;
                                              _isCodeSent = false;
                                            });
                                          },
                                  ),
                                  SizedBox(height: M3ESpacing.lg),
                                  if (!_isPhoneFlow) ...[
                                    TextFieldM3E(
                                      controller: _emailController,
                                      labelText: 'Email Address',
                                      hintText: 'you@example.com',
                                      prefixIcon: Icons.email,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    SizedBox(height: M3ESpacing.md),
                                    FilledButtonM3E(
                                      onPressed: _isLoading
                                          ? null
                                          : _sendMagicLink,
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicatorM3E.small(),
                                            )
                                          : const Text('Continue'),
                                    ),
                                  ] else ...[
                                    TextFieldM3E(
                                      controller: _phoneController,
                                      labelText: 'Phone Number',
                                      prefixIcon: Icons.phone,
                                      helperText:
                                          'US/Canada numbers only.',
                                      keyboardType: TextInputType.phone,
                                    ),
                                    SizedBox(height: M3ESpacing.md),
                                    FilledButtonM3E(
                                      icon: Icons.phone,
                                      onPressed: _isLoading
                                          ? null
                                          : _signInWithPhone,
                                      child: _isLoading
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicatorM3E.small(),
                                            )
                                          : const Text('Continue'),
                                    ),
                                  ],
                                  SizedBox(height: M3ESpacing.lg),
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: M3ESpacing.sm,
                                        ),
                                        child: Text(
                                          'OR',
                                          style: M3ETypography.labelSmall,
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  SizedBox(height: M3ESpacing.lg),
                                  OutlinedButtonM3E(
                                    icon: Icons.g_mobiledata,
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithGoogle,
                                    child: const Text('Sign In with Google'),
                                  ),
                                  M3ESpacing.verticalXS,
                                  OutlinedButtonM3E(
                                    icon: Icons.apple,
                                    onPressed: _isLoading
                                        ? null
                                        : _signInWithApple,
                                    child: const Text('Sign In with Apple'),
                                  ),
                                ] else ...[
                                  Text(
                                    'Enter verification code',
                                    style: M3ETypography.titleMedium,
                                  ),
                                  M3ESpacing.verticalXS,
                                  TextFieldM3E(
                                    controller: _codeController,
                                    labelText: 'Verification Code',
                                    hintText: '123456',
                                    prefixIcon: Icons.lock,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode,
                                    ],
                                  ),
                                  M3ESpacing.verticalMD,
                                  FilledButtonM3E(
                                    onPressed: _isLoading ? null : _verifyCode,
                                    child: _isLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicatorM3E.small(),
                                          )
                                        : const Text('Verify Code'),
                                  ),
                                  M3ESpacing.verticalXS,
                                  TextButtonM3E(
                                    onPressed: () {
                                      setState(() {
                                        _isCodeSent = false;
                                        _verificationId = null;
                                        _codeController.clear();
                                      });
                                    },
                                    child: const Text('Change phone number'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: M3ESpacing.md),
                        Container(
                          padding: M3ESpacing.all(M3ESpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              M3EShapes.small,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                              M3ESpacing.horizontalXS,
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: M3ETypography.bodySmall.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text:
                                            'By continuing, you agree to our ',
                                      ),
                                      WidgetSpan(
                                        alignment:
                                            PlaceholderAlignment.baseline,
                                        baseline: TextBaseline.alphabetic,
                                        child: GestureDetector(
                                          onTap: () async {
                                            final uri = Uri.parse(
                                              AppConstants.privacyPolicyUrl,
                                            );
                                            if (!await launchUrl(
                                              uri,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            )) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Could not open privacy policy',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            'Privacy Policy',
                                            style: M3ETypography.bodySmall
                                                .copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
