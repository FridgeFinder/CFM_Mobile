import 'dart:io';
import 'package:flutter/material.dart';
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
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable form content - uses Expanded to fill available space
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Condition Selection
                Text(
                  'Fridge Condition',
                  style: M3ETypography.labelLarge, // 14px Medium
                ),
                SizedBox(height: M3ESpacing.xs), // 8dp
                // Radio buttons for condition selection (exclude ghost)
                ...FridgeCondition.values
                    .where((condition) => condition != FridgeCondition.ghost)
                    .map(
                      (condition) =>
                      // ignore: deprecated_member_use
                      RadioListTile<FridgeCondition>(
                        title: Text(_conditionLabel(condition)),
                        value: condition,
                        // ignore: deprecated_member_use
                        groupValue: _selectedCondition,
                        // ignore: deprecated_member_use
                        onChanged: (FridgeCondition? value) {
                          if (value != null) {
                            setState(() => _selectedCondition = value);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                SizedBox(height: M3ESpacing.md), // 16dp

                // Food Level Slider
                Text(
                  'Food Level: ${_getFoodLevelLabel()}',
                  style: M3ETypography.labelLarge, // 14px Medium
                ),
                Slider(
                  value: _foodPercentage,
                  onChanged: (value) {
                    setState(() => _foodPercentage = value);
                  },
                  min: 0,
                  max: 1,
                  divisions: 3,
                  label: _getFoodLevelLabel(),
                ),
                SizedBox(height: M3ESpacing.xxs), // 4dp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Empty', style: M3ETypography.bodySmall),
                    Text('Few Items', style: M3ETypography.bodySmall),
                    Text('Many Items', style: M3ETypography.bodySmall),
                    Text('Full', style: M3ETypography.bodySmall),
                  ],
                ),
                SizedBox(height: M3ESpacing.md), // 16dp

                // Notes - M3E TextField with 56dp height, 12dp top corners, 4dp bottom
                Text(
                  'Additional Notes (Optional)',
                  style: M3ETypography.labelLarge, // 14px Medium
                ),
                SizedBox(height: M3ESpacing.xs), // 8dp
                TextFieldM3E(
                  controller: _notesController,
                  maxLines: 3,
                  hintText: 'Any additional information...',
                  filled: true,
                ),
                SizedBox(height: M3ESpacing.md), // 16dp

                // Photo Upload
                Text(
                  'Photo (Optional)',
                  style: M3ETypography.labelLarge, // 14px Medium
                ),
                SizedBox(height: M3ESpacing.xs), // 8dp
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
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
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
                      SizedBox(width: M3ESpacing.xs), // 8dp
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
                SizedBox(height: M3ESpacing.xl), // 24dp
              ],
            ),
          ),
        ),
        // Fixed bottom row with Cancel and Submit buttons - M3E variants
        Padding(
          padding: EdgeInsets.only(top: M3ESpacing.md), // 16dp
          child: Row(
            mainAxisSize: MainAxisSize.min,  // ← FIX: Prevent unbounded constraints
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel - M3E Text button (40dp height)
              TextButtonM3E(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: M3ETypography.labelLarge,
                ),
              ),
              SizedBox(width: M3ESpacing.xs), // 8dp
              // Submit - M3E Filled button (40dp height) with 300ms press animation
              FilledButtonM3E(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicatorM3E.small(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Update',
                        style: M3ETypography.labelLarge,
                      ),
              ),
            ],
          ),
        ),
      ],
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
