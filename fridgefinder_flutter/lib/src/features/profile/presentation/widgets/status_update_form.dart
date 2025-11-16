import 'dart:io';
import 'package:flutter/material.dart' hide StepperType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/data/repositories/fridge_repository.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/points_provider.dart';

/// Form for reporting fridge status updates
class StatusUpdateForm extends ConsumerStatefulWidget {
  final FridgeDomain fridge;

  const StatusUpdateForm({super.key, required this.fridge});

  @override
  ConsumerState<StatusUpdateForm> createState() => _StatusUpdateFormState();
}

class _StatusUpdateFormState extends ConsumerState<StatusUpdateForm> {
  bool _isSubmitting = false;
  int _currentStep = 0;
  FridgeCondition? _selectedCondition;
  late double _foodPercentage;
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Condition is now optional - don't set a default
    _selectedCondition = null;
    _foodPercentage = widget.fridge.latestFridgeReport?.foodPercentage ?? 0.5;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: const Color(
            0xFFFFB300,
          ), // M3E Vibrant AMBER for warning
        ),
      );
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(fridgeRepositoryProvider);

      // Get photo bytes if selected (will be base64 encoded in the API call)
      List<int>? photoBytes;
      if (_selectedImage != null) {
        photoBytes = await _selectedImage!.readAsBytes();
      }

      // Use current condition as default if user didn't select one
      // This keeps the field optional in UI but satisfies API requirements
      final conditionToSubmit =
          _selectedCondition ??
          widget.fridge.latestFridgeReport?.condition ??
          FridgeCondition.good;

      // Submit report with optional photo bytes (will be base64 encoded)
      await repository.submitFridgeReport(
        widget.fridge.id,
        conditionToSubmit,
        _foodPercentage,
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photoBytes,
      );

      // Invalidate fridge data providers to refresh UI
      ref.invalidate(fridgeListProvider);
      ref.invalidate(singleFridgeProvider(widget.fridge.id));

      // Award points if user is a volunteer
      final userProfile = ref.read(userProfileProvider).value;
      if (userProfile?.isVolunteer == true) {
        final previousCondition = widget.fridge.latestFridgeReport?.condition;
        final previousFoodPercentage =
            widget.fridge.latestFridgeReport?.foodPercentage ?? 0.0;

        final pointsManager = ref.read(pointsManagerProvider.notifier);
        await pointsManager.awardPointsForStatusReport(
          wasDirty: previousCondition == FridgeCondition.dirty,
          isNowGood: conditionToSubmit == FridgeCondition.good,
          previousFoodPercentage: previousFoodPercentage,
          newFoodPercentage: _foodPercentage,
          isVolunteer: true,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status update submitted for ${widget.fridge.name}'),
          backgroundColor: const Color(
            0xFF5FD65F,
          ), // M3E Vibrant GREEN for success
        ),
      );

      // Wait for next frame to ensure all provider rebuilds complete before navigation
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit update: ${e.toString()}'),
          backgroundColor: const Color(
            0xFFFF7043,
          ), // M3E Vibrant CORAL for errors
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StepperM3E(
      currentStep: _currentStep,
      type: StepperType.horizontal,
      steps: [
        StepperStepM3E(title: 'Condition', content: _buildConditionStep()),
        StepperStepM3E(title: 'Food Level', content: _buildFoodLevelStep()),
        StepperStepM3E(title: 'Details', content: _buildDetailsStep()),
      ],
      onStepTapped: (index) {
        if (index <= _currentStep) {
          setState(() => _currentStep = index);
        }
      },
      onStepContinue: _nextStep,
      onStepCancel: _previousStep,
      controlsBuilder: (context, details) {
        return Padding(
          padding: M3ESpacing.all(M3ESpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButtonM3E(
                onPressed: _isSubmitting ? null : details.onStepCancel,
                child: Text(
                  details.stepIndex == 0 ? 'Cancel' : 'Back',
                  style: M3ETypography.labelLarge,
                ),
              ),
              FilledButtonM3E(
                onPressed: _isSubmitting ? null : details.onStepContinue,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicatorM3E.small(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        details.stepIndex == 2 ? 'Submit Update' : 'Next',
                        style: M3ETypography.labelLarge,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConditionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fridge Condition (Optional)', style: M3ETypography.labelLarge),
          SizedBox(height: M3ESpacing.xs),
          ...FridgeCondition.values
              .where((condition) => condition != FridgeCondition.ghost)
              .map(
                (condition) => RadioM3E<FridgeCondition?>(
                  value: condition,
                  groupValue: _selectedCondition,
                  onChanged: (FridgeCondition? value) {
                    setState(() => _selectedCondition = value);
                  },
                  label: _conditionLabel(condition),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFoodLevelStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Food Level', style: M3ETypography.labelLarge),
          // Fixed height container to prevent layout shifts when tooltip appears
          SizedBox(
            child: SliderM3E(
              value: _foodPercentage,
              onChanged: (value) {
                setState(() => _foodPercentage = value);
              },
              min: 0,
              max: 1,
              divisions: 3,
              showValueLabel: false, // Remove the number above the slider
              activeColor: _getFoodLevelColor(_foodPercentage),
              thumbColor: _getFoodLevelColor(_foodPercentage),
            ),
          ),
          SizedBox(height: M3ESpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Empty', style: M3ETypography.bodySmall),
              Text('Few Items', style: M3ETypography.bodySmall),
              Text('Many Items', style: M3ETypography.bodySmall),
              Text('Full', style: M3ETypography.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photo of Fridge Contents', style: M3ETypography.labelLarge),
          SizedBox(height: M3ESpacing.xs),
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InteractiveIconButtonM3E(
                    icon: Icons.close,
                    iconSize: 20,
                    iconColor: Colors.white,
                    backgroundColor: Colors.black54,
                    onPressed: _removeImage,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButtonM3E(
                    icon: Icons.camera_alt,
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Camera', style: M3ETypography.labelLarge),
                  ),
                ),
                SizedBox(width: M3ESpacing.xs),
                Expanded(
                  child: OutlinedButtonM3E(
                    icon: Icons.photo_library,
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Gallery', style: M3ETypography.labelLarge),
                  ),
                ),
              ],
            ),
          SizedBox(height: M3ESpacing.md),
          Text('Additional Notes (Optional)', style: M3ETypography.labelLarge),
          SizedBox(height: M3ESpacing.xs),
          TextFieldM3E(
            controller: _notesController,
            maxLines: 3,
            hintText: 'Any additional information...',
            filled: true,
          ),
        ],
      ),
    );
  }

  /// Get the color for the slider based on food percentage
  /// Colors transition smoothly between food level colors matching the map markers
  Color _getFoodLevelColor(double percentage) {
    // M3E vibrant semantic colors matching FridgeIconUtils
    const emptyColor = Color(0xFFFFFFFF); // White - empty
    const fewItemsColor = Color(0xFFFF6B9D); // Vibrant pink - few items
    const manyItemsColor = Color(0xFFFFB300); // Vibrant amber - many items
    const fullColor = Color(0xFF5FD65F); // Vibrant green - full

    // Smooth color interpolation between levels
    if (percentage >= 0.75) {
      // Between Many Items and Full (0.75 - 1.0)
      final t = (percentage - 0.75) / 0.25;
      return Color.lerp(manyItemsColor, fullColor, t)!;
    } else if (percentage >= 0.5) {
      // Between Few Items and Many Items (0.5 - 0.75)
      final t = (percentage - 0.5) / 0.25;
      return Color.lerp(fewItemsColor, manyItemsColor, t)!;
    } else if (percentage > 0) {
      // Between Empty and Few Items (0 - 0.5)
      final t = percentage / 0.5;
      return Color.lerp(emptyColor, fewItemsColor, t)!;
    } else {
      // Empty
      return emptyColor;
    }
  }

  String _conditionLabel(FridgeCondition condition) {
    switch (condition) {
      case FridgeCondition.good:
        return 'Good - Operational';
      case FridgeCondition.dirty:
        return 'Dirty - Needs Cleaning';
      case FridgeCondition.outOfOrder:
        return 'Needs Repairs';
      case FridgeCondition
          .ghost: // Ghost fridges are filtered from API response
        return 'Ghost - No Longer There'; // Kept for exhaustive switch, but ghost fridges are filtered out
      case FridgeCondition.notAtLocation:
        return 'Not at Location';
    }
  }
}
