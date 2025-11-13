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
  late FridgeCondition _selectedCondition;
  late double _foodPercentage;
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    final currentCondition = widget.fridge.latestFridgeReport?.condition;
    // Default to 'good', and skip ghost condition if somehow present
    _selectedCondition =
        (currentCondition == null || currentCondition == FridgeCondition.ghost)
        ? FridgeCondition.good
        : currentCondition;
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
          backgroundColor: Colors.orange,
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

      // Submit report with optional photo bytes (will be base64 encoded)
      await repository.submitFridgeReport(
        widget.fridge.id,
        _selectedCondition,
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
          isNowGood: _selectedCondition == FridgeCondition.good,
          previousFoodPercentage: previousFoodPercentage,
          newFoodPercentage: _foodPercentage,
          isVolunteer: true,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status update submitted for ${widget.fridge.name}'),
          backgroundColor: Colors.green,
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
          backgroundColor: Colors.red,
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
        StepperStepM3E(
          title: 'Condition',
          content: _buildConditionStep(),
        ),
        StepperStepM3E(
          title: 'Food Level',
          content: _buildFoodLevelStep(),
        ),
        StepperStepM3E(
          title: 'Details',
          content: _buildDetailsStep(),
        ),
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
          Text(
            'Fridge Condition',
            style: M3ETypography.labelLarge,
          ),
          SizedBox(height: M3ESpacing.xs),
          ...FridgeCondition.values
              .where((condition) => condition != FridgeCondition.ghost)
              .map(
                (condition) => RadioM3E<FridgeCondition>(
                  value: condition,
                  groupValue: _selectedCondition,
                  onChanged: (FridgeCondition? value) {
                    if (value != null) {
                      setState(() => _selectedCondition = value);
                    }
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
          Text(
            'Food Level: ${_getFoodLevelLabel()}',
            style: M3ETypography.labelLarge,
          ),
          SliderM3E(
            value: _foodPercentage,
            onChanged: (value) {
              setState(() => _foodPercentage = value);
            },
            min: 0,
            max: 1,
            divisions: 3,
            label: _getFoodLevelLabel(),
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
          Text(
            'Additional Notes (Optional)',
            style: M3ETypography.labelLarge,
          ),
          SizedBox(height: M3ESpacing.xs),
          TextFieldM3E(
            controller: _notesController,
            maxLines: 3,
            hintText: 'Any additional information...',
            filled: true,
          ),
          SizedBox(height: M3ESpacing.md),
          Text(
            'Photo (Optional)',
            style: M3ETypography.labelLarge,
          ),
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
                    child: Text(
                      'Camera',
                      style: M3ETypography.labelLarge,
                    ),
                  ),
                ),
                SizedBox(width: M3ESpacing.xs),
                Expanded(
                  child: OutlinedButtonM3E(
                    icon: Icons.photo_library,
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text(
                      'Gallery',
                      style: M3ETypography.labelLarge,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getFoodLevelLabel() {
    // Convert to API level (0-3) for display
    if (_foodPercentage >= 0.75) return 'Full';
    if (_foodPercentage >= 0.5) return 'Many Items';
    if (_foodPercentage > 0) return 'Few Items';
    return 'Empty';
  }

  String _conditionLabel(FridgeCondition condition) {
    switch (condition) {
      case FridgeCondition.good:
        return 'Good - Operational';
      case FridgeCondition.dirty:
        return 'Dirty - Needs Cleaning';
      case FridgeCondition.outOfOrder:
        return 'Out of Order';
      case FridgeCondition
          .ghost: // Ghost fridges are filtered from API response
        return 'Ghost - No Longer There'; // Kept for exhaustive switch, but ghost fridges are filtered out
      case FridgeCondition.notAtLocation:
        return 'Not at Location';
    }
  }
}
