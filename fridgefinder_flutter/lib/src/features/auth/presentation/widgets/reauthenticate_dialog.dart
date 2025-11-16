import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';

/// Dialog for re-authenticating user before sensitive operations
class ReauthenticateDialog extends ConsumerStatefulWidget {
  final firebase_auth.User user;

  const ReauthenticateDialog({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<ReauthenticateDialog> createState() => _ReauthenticateDialogState();
}

class _ReauthenticateDialogState extends ConsumerState<ReauthenticateDialog> {
  final _codeController = TextEditingController();
  bool _isCodeSent = false;
  String? _verificationId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  bool get _isPhoneAuth => widget.user.phoneNumber != null;
  bool get _isGoogleAuth => widget.user.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );

  Future<void> _reauthenticateWithPhone() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = widget.user.phoneNumber;
      if (phoneNumber == null) {
        throw Exception('Phone number not available');
      }

      final repository = ref.read(authRepositoryProvider);
      await repository.reauthenticateWithPhone(
        phoneNumber: phoneNumber,
        codeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
            _isLoading = false;
          });
        },
        verificationFailed: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e) {
      logger.e('Error during phone re-authentication: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to send verification code: $e';
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _verificationId == null) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      logger.i('Attempting phone re-authentication with code: ${code.substring(0, 2)}***');
      final repository = ref.read(authRepositoryProvider);
      await repository.completePhoneReauthentication(
        verificationId: _verificationId!,
        code: code,
      );

      logger.i('Phone re-authentication successful, closing dialog with result: true');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      logger.e('Error verifying code: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid verification code. Please try again.';
      });
    }
  }

  Future<void> _reauthenticateWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      logger.i('Attempting Google re-authentication');
      final repository = ref.read(authRepositoryProvider);
      await repository.reauthenticateWithGoogle();

      logger.i('Google re-authentication successful, closing dialog with result: true');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      logger.e('Error during Google re-authentication: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to re-authenticate with Google: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: M3EShapes.dialog,
      title: Text('Verify Your Identity', style: M3ETypography.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'For security reasons, please verify your identity before proceeding.',
              style: M3ETypography.bodyMedium,
            ),
            M3ESpacing.verticalXL,

            if (_errorMessage != null) ...[
              Container(
                padding: M3ESpacing.all(M3ESpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(M3EShapes.small),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    M3ESpacing.horizontalXS,
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: M3ETypography.bodySmall.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              M3ESpacing.verticalMD,
            ],

            if (_isPhoneAuth && !_isCodeSent) ...[
              Text(
                'A verification code will be sent to:',
                style: M3ETypography.bodySmall,
              ),
              M3ESpacing.verticalXS,
              Text(
                widget.user.phoneNumber ?? '',
                style: M3ETypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              M3ESpacing.verticalXL,
              FilledButtonM3E(
                onPressed: _isLoading ? null : _reauthenticateWithPhone,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicatorM3E.small(),
                      )
                    : const Text('Send Verification Code'),
              ),
            ] else if (_isPhoneAuth && _isCodeSent) ...[
              Text(
                'Enter the verification code sent to:',
                style: M3ETypography.bodySmall,
              ),
              M3ESpacing.verticalXXS,
              Text(
                widget.user.phoneNumber ?? '',
                style: M3ETypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              M3ESpacing.verticalMD,
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
                    _errorMessage = null;
                  });
                },
                child: const Text('Resend code'),
              ),
            ] else if (_isGoogleAuth) ...[
              Text(
                'Signed in with:',
                style: M3ETypography.bodySmall,
              ),
              M3ESpacing.verticalXS,
              Row(
                children: [
                  const Icon(Icons.g_mobiledata, size: 32),
                  M3ESpacing.horizontalXS,
                  Expanded(
                    child: Text(
                      widget.user.email ?? '',
                      style: M3ETypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              M3ESpacing.verticalXL,
              FilledButtonM3E(
                icon: Icons.g_mobiledata,
                onPressed: _isLoading ? null : _reauthenticateWithGoogle,
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicatorM3E.small(),
                      )
                    : const Text('Continue with Google'),
              ),
            ] else ...[
              Text(
                'Unable to determine authentication method.',
                style: M3ETypography.bodyMedium.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButtonM3E(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
