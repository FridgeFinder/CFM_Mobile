import 'package:flutter/material.dart' hide StepperType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/user_profile.dart';
import 'username_generator.dart';

/// Multi-step sign-up form with fade-in animations
class SignUpForm extends ConsumerStatefulWidget {
  final firebase_auth.UserCredential userCredential;

  const SignUpForm({super.key, required this.userCredential});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String? _selectedUsername;
  bool _isGeneratingUsername = false;
  String? _emailOverride;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: M3EMotion.emphasized,
    );
    _fadeController.forward();
    _generateInitialUsername();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateInitialUsername() async {
    setState(() => _isGeneratingUsername = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final generator = UsernameGenerator(repository);
      final username = await generator.generateUniqueUsername();
      setState(() {
        _selectedUsername = username;
        _isGeneratingUsername = false;
      });
    } catch (e) {
      logger.e('Error generating username: $e');
      setState(() => _isGeneratingUsername = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating username: $e')),
        );
      }
    }
  }

  Future<void> _rollDice() async {
    setState(() => _isGeneratingUsername = true);
    try {
      final repository = ref.read(authRepositoryProvider);
      final generator = UsernameGenerator(repository);
      final username = await generator.generateUniqueUsername();
      setState(() {
        _selectedUsername = username;
        _isGeneratingUsername = false;
      });
    } catch (e) {
      logger.e('Error rolling dice: $e');
      setState(() => _isGeneratingUsername = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating username: $e')),
        );
      }
    }
  }

  void _nextStep() {
    if (_selectedUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a username')),
      );
      return;
    }
    _completeSignUp();
  }

  void _previousStep() {}

  Future<void> _completeSignUp() async {
    try {
      final user = widget.userCredential.user;
      if (user == null) {
        throw Exception('User credential is null');
      }

      final repository = ref.read(authRepositoryProvider);
      final authEmail = user.email;
      final profile = UserProfile(
        userId: user.uid,
        email: authEmail ?? _emailOverride,
        phoneNumber: user.phoneNumber,
        username: _selectedUsername!,
        createdAt: DateTime.now(),
      );

      await repository.createUserProfile(profile);

      // Profile was just created — invalidate so the FutureProvider
      // re-fetches it. Auth state didn't change, so no need to
      // invalidate authUserProvider or isAuthenticatedProvider.
      ref.invalidate(userProfileProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      logger.e('Error completing sign up: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error completing sign up: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back navigation during profile setup
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StepperM3E(
                currentStep: _currentStep,
                type: StepperType.horizontal,
                steps: [
                  StepperStepM3E(
                    title: 'Username',
                    content: _buildUsernameStep(),
                  ),
                ],
                onStepTapped: (index) {
                  if (index <= _currentStep) {
                    setState(() {
                      _currentStep = index;
                      _fadeController.reset();
                      _fadeController.forward();
                    });
                  }
                },
                onStepContinue: _nextStep,
                onStepCancel: _previousStep,
              ),
              M3ESpacing.verticalMD,
              _buildPrivacyPolicyLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final uri = Uri.parse(AppConstants.privacyPolicyUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open privacy policy')),
            );
          }
        }
      },
      child: Text(
        'Privacy Policy',
        style: M3ETypography.bodySmall.copyWith(
          decoration: TextDecoration.underline,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose your username', style: M3ETypography.titleLarge),
        M3ESpacing.verticalXS,
        Text('Your username', style: M3ETypography.titleMedium),
        M3ESpacing.verticalXS,
        Container(
          padding: M3ESpacing.all(M3ESpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(M3EShapes.medium),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedUsername ?? 'Generating...',
                  style: M3ETypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (_isGeneratingUsername)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicatorM3E.small(),
                )
              else
                InteractiveIconButtonM3E(
                  icon: Icons.casino,
                  tooltip: 'Roll dice for new username',
                  onPressed: _rollDice,
                ),
            ],
          ),
        ),
        M3ESpacing.verticalXS,
        Text(
          'Click the dice icon to generate a new username',
          style: M3ETypography.bodySmall,
        ),
        M3ESpacing.verticalMD,
        // Privacy Policy reminder
        Container(
          padding: M3ESpacing.all(M3ESpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(M3EShapes.small),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              M3ESpacing.horizontalXS,
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: M3ETypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(
                              AppConstants.privacyPolicyUrl,
                            );
                            if (!await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            )) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
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
                            style: M3ETypography.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
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
        M3ESpacing.verticalMD,
        // Email field for phone-auth users (no Google email available)
        if (widget.userCredential.user?.email == null) ...[
          TextFieldM3E(
            labelText: 'Email address (optional)',
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              setState(() => _emailOverride = value.isEmpty ? null : value);
            },
          ),
          M3ESpacing.verticalSM,
        ],
      ],
    );
  }
}
