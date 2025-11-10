import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/phone_number_helper.dart';
import 'sign_up_form.dart';

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
    if (formattedPhone == null || !PhoneNumberHelper.isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (e.g., +1234567890)'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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

      // Invalidate providers to refresh auth state
      ref.invalidate(authUserProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(isAuthenticatedProvider);

      // Check if user profile exists by phone number (not userId!)
      final existingProfile = await repository.findUserProfileByEmailOrPhone(
        phoneNumber: credential.user!.phoneNumber,
      );

      if (existingProfile == null) {
        // New user - show sign-up form
        if (!mounted) {
          setState(() => _isLoading = false);
          return;
        }

        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SignUpForm(userCredential: credential),
            ),
          ),
        );

        if (result == true) {
          setState(() => _isLoading = false);

          // Close dialogs using a post-frame callback to ensure UI is stable
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Close the sign-in dialog
              Navigator.of(context).pop();

              // Let Firebase Auth state listeners handle provider updates naturally
              // No need to manually invalidate - the auth state change will trigger updates
              widget.onSignInSuccess?.call();
            }
          });
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      } else {
        // Existing user - update profile with new userId if needed
        if (existingProfile.userId != credential.user!.uid) {
          logger.i('Migrating profile from ${existingProfile.userId} to ${credential.user!.uid}');
          final updatedProfile = existingProfile.copyWith(
            userId: credential.user!.uid,
          );
          await repository.updateUserProfile(updatedProfile);
          // Delete old profile (migration cleanup)
          await repository.deleteAccount(existingProfile.userId);
          ref.invalidate(userProfileProvider);
        }

        setState(() => _isLoading = false);

        // Use post-frame callback for navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onSignInSuccess?.call();
          }
        });
      }
    } catch (e) {
      logger.e('Error verifying code: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying code: $e')),
        );
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

      // Invalidate providers to refresh auth state
      ref.invalidate(authUserProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(isAuthenticatedProvider);

      // Check if user profile exists by email (not userId!)
      final existingProfile = await repository.findUserProfileByEmailOrPhone(
        email: credential.user!.email,
      );

      if (existingProfile == null) {
        // New user - show sign-up form
        if (!mounted) {
          setState(() => _isLoading = false);
          return;
        }

        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SignUpForm(userCredential: credential),
            ),
          ),
        );

        if (result == true) {
          setState(() => _isLoading = false);

          // Close dialogs using a post-frame callback to ensure UI is stable
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Close the sign-in dialog
              Navigator.of(context).pop();

              // Let Firebase Auth state listeners handle provider updates naturally
              // No need to manually invalidate - the auth state change will trigger updates
              widget.onSignInSuccess?.call();
            }
          });
        } else {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      } else {
        // Existing user - update profile with new userId if needed
        if (existingProfile.userId != credential.user!.uid) {
          logger.i('Migrating profile from ${existingProfile.userId} to ${credential.user!.uid}');
          final updatedProfile = existingProfile.copyWith(
            userId: credential.user!.uid,
          );
          await repository.updateUserProfile(updatedProfile);
          // Delete old profile (migration cleanup)
          await repository.deleteAccount(existingProfile.userId);
          ref.invalidate(userProfileProvider);
        }

        setState(() => _isLoading = false);

        // Use post-frame callback for navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onSignInSuccess?.call();
          }
        });
      }
    } catch (e) {
      logger.e('Error signing in with Google: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign In',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (!_isCodeSent) ...[
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+1234567890 or (234) 567-8900',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  helperText: 'Include country code (e.g., +1 for US)',
                ),
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithPhone,
                icon: const Icon(Icons.phone),
                label: const Text('Sign In with Phone'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Sign In with Gmail'),
              ),
            ] else ...[
              Text(
                'Enter verification code',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify Code'),
              ),
              const SizedBox(height: 8),
              TextButton(
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

