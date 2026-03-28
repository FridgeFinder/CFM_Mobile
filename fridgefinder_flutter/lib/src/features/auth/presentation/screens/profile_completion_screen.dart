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
  String _zipCode = '';
  String _username = '';
  bool _isVolunteer = false;
  bool _isSubmitting = false;
  bool _isRollingDice = false;
  String? _errorMessage;

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
      final newProfile = UserProfile(
        userId: authUser.uid,
        email: authUser.email,
        phoneNumber: authUser.phoneNumber,
        username: _username,
        isVolunteer: _isVolunteer,
        zipCode: _isVolunteer ? _zipCode : null,
        points: 0,
        fcmToken: null,
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
      final username = await generator.generateUniqueUsername(
        isVolunteer: _isVolunteer,
      );

      // Wait for animation to complete before updating username
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
        setState(() => _isRollingDice = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating username: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

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
        body: profileAsync.when(
          loading: () => const Center(child: LoadingIndicatorM3E()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading profile: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProfileProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (profile) {
            // If profile is null, user authenticated but never completed sign-up
            // Show form to create their profile
            if (profile == null) {
              // Generate initial username if not set
              if (_username.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _generateUsername();
                  }
                });
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(M3ESpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                      ? 'Generating...'
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
                          'Tap the dice to generate a new username',
                          style: M3ETypography.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Volunteer checkbox
                    CheckboxM3E(
                      label: 'I am a volunteer',
                      value: _isVolunteer,
                      onChanged: (value) {
                        setState(() => _isVolunteer = value ?? false);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Zip code field (if volunteer)
                    if (_isVolunteer) ...[
                      TextFieldM3E(
                        labelText: 'Zip Code',
                        hintText: '12345',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _zipCode = value;
                            _errorMessage = null;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We collect zip codes for non-profit funding purposes and don\'t share data with anyone.',
                        style: M3ETypography.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
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
