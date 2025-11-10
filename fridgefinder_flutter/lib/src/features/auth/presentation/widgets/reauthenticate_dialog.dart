import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
      title: const Text('Verify Your Identity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'For security reasons, please verify your identity before proceeding.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isPhoneAuth && !_isCodeSent) ...[
              Text(
                'A verification code will be sent to:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                widget.user.phoneNumber ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _reauthenticateWithPhone,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Verification Code'),
              ),
            ] else if (_isPhoneAuth && _isCodeSent) ...[
              Text(
                'Enter the verification code sent to:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.phoneNumber ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
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
                    _errorMessage = null;
                  });
                },
                child: const Text('Resend code'),
              ),
            ] else if (_isGoogleAuth) ...[
              Text(
                'Signed in with:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.g_mobiledata, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.user.email ?? '',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _reauthenticateWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue with Google'),
              ),
            ] else ...[
              Text(
                'Unable to determine authentication method.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
