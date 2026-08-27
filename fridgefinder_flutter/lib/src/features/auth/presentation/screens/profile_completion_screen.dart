import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/notification_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/user_profile.dart';
import '../widgets/username_generator.dart';
import '../widgets/dice_roll_animation.dart';

/// Screen shown when user is authenticated but profile is incomplete
/// Forces user to complete required profile fields before accessing the app
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  String _username = '';
  bool _isSubmitting = false;
  bool _isRollingDice = false;
  String? _errorMessage;
  String? _emailOverride;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _username.isEmpty && !_isRollingDice) {
        _generateUsername();
      }
    });
  }

  Future<void> _createProfile() async {
    // Validate username
    if (_username.isEmpty) {
      setState(() => _errorMessage = 'Username is required');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final authUser = await ref.read(authUserProvider.future);

      if (authUser == null) {
        throw Exception('No authenticated user found');
      }

      // Create new profile
      final authEmail = authUser.email;
      final newProfile = UserProfile(
        userId: authUser.uid,
        email: authEmail ?? _emailOverride,
        phoneNumber: authUser.phoneNumber,
        username: _username,
        settings: const UserSettings(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await repository.createUserProfile(newProfile);

      // Refresh providers
      ref.invalidate(userProfileProvider);
      ref.invalidate(isProfileCompleteProvider);

      if (!mounted) return;

      // Navigate to home
      context.go('/');
    } catch (e) {
      logger.e('Error creating profile: $e');
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating profile: $e'),
          backgroundColor: const Color(0xFFFF7043), // M3E Vibrant CORAL
        ),
      );
    }
  }

  Future<void> _generateUsername() async {
    // Start dice roll animation
    setState(() => _isRollingDice = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final generator = UsernameGenerator(repository);
      final username = await generator.generateUniqueUsername();

      // Keep roll visible long enough to avoid abrupt state changes.
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _username = username;
          _isRollingDice = false;
        });
      }
    } catch (e) {
      logger.e('Error generating username: $e');
      if (mounted) {
        setState(() {
          _isRollingDice = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not generate a username. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    UserProfile? profile;
    profileAsync.when(
      data: (value) => profile = value,
      loading: () {},
      error: (_, _) {},
    );
    final profileLoadError = profileAsync.hasError;

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final confirmed = await DialogM3E.showConfirmation(
                context: context,
                title: 'Leave Profile Setup?',
                message:
                    'You will be signed out and need to sign in again to continue.',
                confirmText: 'Sign Out',
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                try {
                  final fcmService = ref.read(fcmServiceProvider);
                  await fcmService.deleteToken();
                  final repository = ref.read(authRepositoryProvider);
                  await repository.signOut();
                } finally {
                  if (context.mounted) {
                    context.go('/');
                  }
                }
              }
            },
          ),
          title: const Text('Complete Your Profile'),
        ),
        body: Builder(
          builder: (context) {
            // If profile is null, user authenticated but never completed sign-up
            // Show form to create their profile, even while profile fetch is in-flight.
            if (profile == null) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(M3ESpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (profileLoadError) ...[
                      CardM3E(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Still checking your profile. You can continue setup now.',
                              style: M3ETypography.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => ref.invalidate(userProfileProvider),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Profile Check'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Icon(
                      Icons.person_add,
                      size: 64,
                      color: Color(0xFF88B3FF),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please complete your profile to continue using the app.',
                      style: M3ETypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Username field with dice button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Username *',
                          style: M3ETypography.labelLarge.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  _username.isEmpty
                                      ? (_isRollingDice
                                            ? 'Generating...'
                                            : 'Tap dice to generate')
                                      : _username,
                                  style: M3ETypography.bodyLarge.copyWith(
                                    color: _username.isEmpty
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Dice button with animation
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _isRollingDice
                                    ? null
                                    : _generateUsername,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DiceRollAnimation(
                                    isRolling: _isRollingDice,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the dice to generate a username',
                          style: M3ETypography.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_username.isEmpty && !_isRollingDice) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _generateUsername,
                            icon: const Icon(Icons.casino_outlined),
                            label: const Text('Generate Username'),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Email field for phone-auth users (no Google email)
                    Builder(
                      builder: (context) {
                        final authEmail =
                            ref.read(authUserProvider).value?.email;
                        if (authEmail == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFieldM3E(
                                labelText: 'Email address (optional)',
                                hintText: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() => _emailOverride =
                                      value.isEmpty ? null : value);
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 4),
                    // Error message
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: M3ETypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Submit button
                    FilledButtonM3E(
                      onPressed: _isSubmitting ? null : _createProfile,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Create Profile'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(AppConstants.privacyPolicyUrl);
                        if (!await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        )) {
                          if (context.mounted) {
                            showSnackbarM3E(
                              context: context,
                              message: 'Could not open privacy policy',
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.privacy_tip_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      label: Text(
                        'Privacy Policy',
                        style: M3ETypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Profile exists and has username — already complete, redirect
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/');
              }
            });
            return const Center(child: LoadingIndicatorM3E());
          },
        ),
      ),
    );
  }
}
