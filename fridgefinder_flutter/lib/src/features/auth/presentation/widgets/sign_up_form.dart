import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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
      curve: Curves.easeIn,
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
              const SizedBox(width: 8),
              _buildStepIndicator(1, _isVolunteer ? 'Zip Code' : 'Username'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Step content
          if (_currentStep == 0) _buildVolunteerStep(),
          if (_currentStep == 1) _buildUsernameStep(),
          
          const SizedBox(height: 24),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Back'),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Volunteers help maintain and stock community fridges',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        CheckboxListTile(
          title: const Text('I am a volunteer'),
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (_isVolunteer) ...[
          Text(
            'We collect zip codes for non-profit funding purposes and do not share this information with any third parties.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Zip Code',
              hintText: '12345',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _zipCode = value);
            },
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Your username',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (_isGeneratingUsername)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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
        const SizedBox(height: 8),
        Text(
          'Click the dice icon to generate a new username',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

