import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../../../core/utils/phone_number_helper.dart';

/// Sign-in widget supporting phone and Gmail authentication
class SignInWidget extends ConsumerStatefulWidget {
  final VoidCallback? onSignInSuccess;

  const SignInWidget({super.key, this.onSignInSuccess});

  @override
  ConsumerState<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends ConsumerState<SignInWidget> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  String? _verificationId;
  bool _isLoading = false;

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
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _signInWithPhone() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    // Format phone number to E.164 format
    final formattedPhone = PhoneNumberHelper.formatPhoneNumber(phoneNumber);
    if (formattedPhone == null ||
        !PhoneNumberHelper.isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid phone number (e.g., +1234567890)',
          ),
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent')),
          );
        },
        verificationFailed: (error) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: $error')),
          );
        },
      );
    } catch (e) {
      logger.e('Error signing in with phone: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
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

        // New users now complete setup on the dedicated profile completion route.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      } else {
        setState(() => _isLoading = false);

        // Use post-frame callback for navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      }
    } catch (e) {
      logger.e('Error verifying code: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error verifying code: $e')));
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      } else {
        setState(() => _isLoading = false);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      }
    } on SignInCancelledException {
      // User cancelled Apple sign-in — silently reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } on AppleSignInNotAvailableException {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Apple Sign-In is not available on this device'),
          ),
        );
      }
    } catch (e) {
      logger.e('Error signing in with Apple: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Apple Sign-In error: $e')));
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

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      } else {
        setState(() => _isLoading = false);

        // Use post-frame callback for navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final navigator = Navigator.of(context, rootNavigator: true);
            if (navigator.canPop()) {
              navigator.pop();
            }
            widget.onSignInSuccess?.call();
          }
        });
      }
    } on SignInCancelledException {
      // User cancelled Google sign-in — silently reset loading state
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Google Sign-In error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardM3E(
      child: Padding(
        padding: M3ESpacing.all(M3ESpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sign In', style: M3ETypography.titleLarge),
            M3ESpacing.verticalMD,

            if (!_isCodeSent) ...[
              TextFieldM3E(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: '+1234567890 or (234) 567-8900',
                prefixIcon: Icons.phone,
                helperText: 'Include country code (e.g., +1 for US)',
                keyboardType: TextInputType.phone,
              ),
              M3ESpacing.verticalMD,
              FilledButtonM3E(
                icon: Icons.phone,
                onPressed: _isLoading ? null : _signInWithPhone,
                child: const Text('Sign In with Phone'),
              ),
              M3ESpacing.verticalXS,
              OutlinedButtonM3E(
                icon: Icons.g_mobiledata,
                onPressed: _isLoading ? null : _signInWithGoogle,
                child: const Text('Sign In with Gmail'),
              ),
              M3ESpacing.verticalXS,
              OutlinedButtonM3E(
                icon: Icons.apple,
                onPressed: _isLoading ? null : _signInWithApple,
                child: const Text('Sign In with Apple'),
              ),
            ] else ...[
              Text('Enter verification code', style: M3ETypography.titleMedium),
              M3ESpacing.verticalXS,
              TextFieldM3E(
                controller: _codeController,
                labelText: 'Verification Code',
                hintText: '123456',
                prefixIcon: Icons.lock,
                keyboardType: TextInputType.number,
                maxLines: 1,
                autofillHints: const [AutofillHints.oneTimeCode],
              ),
              M3ESpacing.verticalMD,
              FilledButtonM3E(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicatorM3E.small(),
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
    );
  }
}
