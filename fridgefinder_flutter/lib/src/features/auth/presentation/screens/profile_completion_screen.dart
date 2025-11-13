import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/user_profile.dart';
import '../widgets/username_generator.dart';

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
  String? _errorMessage;

  Future<void> _createProfile() async {
    // Validate username
    if (_username.isEmpty) {
      setState(() => _errorMessage = 'Username is required');
      return;
    }

    // Validate zip code if volunteer
    if (_isVolunteer) {
      if (_zipCode.isEmpty) {
        setState(() => _errorMessage = 'Zip code is required for volunteers');
        return;
      }
      if (_zipCode.length < 5) {
        setState(() => _errorMessage = 'Please enter a valid zip code');
        return;
      }
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

  Future<void> _updateZipCode() async {
    // Validate zip code
    if (_zipCode.isEmpty) {
      setState(() => _errorMessage = 'Zip code is required for volunteers');
      return;
    }
    if (_zipCode.length < 5) {
      setState(() => _errorMessage = 'Please enter a valid zip code');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(authRepositoryProvider);
      final profileAsync = await ref.read(userProfileProvider.future);

      if (profileAsync == null) {
        throw Exception('Profile not found');
      }

      // Update profile with zipCode
      final updatedProfile = profileAsync.copyWith(
        zipCode: _zipCode,
      );

      await repository.updateUserProfile(updatedProfile);

      // Refresh providers
      ref.invalidate(userProfileProvider);
      ref.invalidate(isProfileCompleteProvider);

      if (!mounted) return;

      // Navigate to home
      context.go('/');
    } catch (e) {
      logger.e('Error updating profile: $e');
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: const Color(0xFFFF7043), // M3E Vibrant CORAL
        ),
      );
    }
  }

  Future<void> _generateUsername() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final generator = UsernameGenerator(repository);
      final username = await generator.generateUniqueUsername(
        isVolunteer: _isVolunteer,
      );
      setState(() => _username = username);
    } catch (e) {
      logger.e('Error generating username: $e');
      if (mounted) {
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
          automaticallyImplyLeading: false, // Remove back button
          title: const Text('Complete Your Profile'),
        ),
        body: profileAsync.when(
          loading: () => const Center(
            child: LoadingIndicatorM3E(),
          ),
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
                    const SizedBox(height: 24),
                    Text(
                      'Complete Your Profile',
                      style: M3ETypography.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please complete your profile to continue using the app.',
                      style: M3ETypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Volunteer checkbox
                    CheckboxM3E(
                      label: 'I am a volunteer',
                      value: _isVolunteer,
                      onChanged: (value) {
                        setState(() => _isVolunteer = value ?? false);
                      },
                    ),
                    const SizedBox(height: 24),
                    // Username field
                    TextFieldM3E(
                      labelText: 'Username *',
                      hintText: _username.isEmpty ? 'Generating...' : _username,
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                          _errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _generateUsername,
                        child: const Text('Generate New Username'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Zip code field (if volunteer)
                    if (_isVolunteer) ...[
                      TextFieldM3E(
                        labelText: 'Zip Code *',
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
                        'We collect zip codes for non-profit funding purposes.',
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Create Profile'),
                    ),
                  ],
                ),
              );
            }

            // Check if volunteer needs to provide zip code
            final needsZipCode = profile.isVolunteer &&
                (profile.zipCode == null || profile.zipCode!.isEmpty);

            if (!needsZipCode) {
              // Profile is actually complete, redirect to home
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.go('/');
                }
              });
              return const Center(child: LoadingIndicatorM3E());
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
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, ${profile.username}!',
                    style: M3ETypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'As a volunteer, we need your zip code to help coordinate community fridge efforts.',
                    style: M3ETypography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFieldM3E(
                    labelText: 'Zip Code *',
                    hintText: '12345',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _zipCode = value;
                        _errorMessage = null;
                      });
                    },
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: M3ETypography.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'We collect zip codes for non-profit funding purposes and do not share this information with any third parties.',
                    style: M3ETypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButtonM3E(
                    onPressed: _isSubmitting ? null : _updateZipCode,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text('Complete Profile'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
