import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/user_profile.dart';
import 'username_generator.dart';

/// Multi-step sign-up form with fade-in animations
class SignUpForm extends ConsumerStatefulWidget {
  final firebase_auth.UserCredential userCredential;

  const SignUpForm({
    super.key,
    required this.userCredential,
  });

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isVolunteer = false;
  String? _zipCode;
  String? _selectedUsername;
  bool _isGeneratingUsername = false;

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
      final username = await generator.generateUniqueUsername(
        isVolunteer: _isVolunteer,
      );
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
      final username = await generator.generateUniqueUsername(
        isVolunteer: _isVolunteer,
      );
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
    if (_currentStep == 0) {
      // Volunteer status step
      setState(() {
        _currentStep = 1;
        _fadeController.reset();
        _fadeController.forward();
      });
      if (_isVolunteer) {
        // Generate new username for volunteer
        _generateInitialUsername();
      }
    } else if (_currentStep == 1) {
      // Username step
      if (_selectedUsername == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a username')),
        );
        return;
      }
      if (_isVolunteer && (_zipCode == null || _zipCode!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your zip code')),
        );
        return;
      }
      _completeSignUp();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _fadeController.reset();
        _fadeController.forward();
      });
    }
  }

  Future<void> _completeSignUp() async {
    try {
      final user = widget.userCredential.user;
      if (user == null) {
        throw Exception('User credential is null');
      }

      final repository = ref.read(authRepositoryProvider);
      final profile = UserProfile(
        userId: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        username: _selectedUsername!,
        isVolunteer: _isVolunteer,
        zipCode: _isVolunteer ? _zipCode : null,
        points: 0,
        createdAt: DateTime.now(),
      );

      await repository.createUserProfile(profile);
      
      // Invalidate providers to refresh UI
      ref.invalidate(authUserProvider);
      ref.invalidate(userProfileProvider);
      ref.invalidate(isAuthenticatedProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      logger.e('Error completing sign up: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing sign up: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Row(
            children: [
              _buildStepIndicator(0, 'Volunteer'),
              M3ESpacing.horizontalXS,
              _buildStepIndicator(1, _isVolunteer ? 'Zip Code' : 'Username'),
            ],
          ),
          M3ESpacing.verticalXL,

          // Step content
          if (_currentStep == 0) _buildVolunteerStep(),
          if (_currentStep == 1) _buildUsernameStep(),

          M3ESpacing.verticalXL,

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButtonM3E(
                  onPressed: _previousStep,
                  child: const Text('Back'),
                )
              else
                const SizedBox.shrink(),
              FilledButtonM3E(
                onPressed: _nextStep,
                child: Text(_currentStep == 1 ? 'Complete' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: M3ETypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          M3ESpacing.verticalXXS,
          Text(
            label,
            style: M3ETypography.labelSmall.copyWith(
              color: isActive || isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you a volunteer?',
          style: M3ETypography.titleLarge,
        ),
        M3ESpacing.verticalXS,
        Text(
          'Volunteers help maintain and stock community fridges',
          style: M3ETypography.bodyMedium,
        ),
        M3ESpacing.verticalXL,
        CheckboxM3E(
          label: 'I am a volunteer',
          value: _isVolunteer,
          onChanged: (value) {
            setState(() => _isVolunteer = value ?? false);
          },
        ),
      ],
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isVolunteer ? 'Enter your zip code' : 'Choose your username',
          style: M3ETypography.titleLarge,
        ),
        M3ESpacing.verticalXS,
        if (_isVolunteer) ...[
          Text(
            'We collect zip codes for non-profit funding purposes and do not share this information with any third parties.',
            style: M3ETypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          M3ESpacing.verticalMD,
          TextFieldM3E(
            labelText: 'Zip Code',
            hintText: '12345',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _zipCode = value);
            },
          ),
          M3ESpacing.verticalXL,
        ],
        Text(
          'Your username',
          style: M3ETypography.titleMedium,
        ),
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
                IconButton(
                  icon: const Icon(Icons.casino),
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
      ],
    );
  }
}

