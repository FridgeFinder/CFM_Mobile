import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/data/repositories/fridge_repository.dart';

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
    _selectedCondition = (currentCondition == null || currentCondition == FridgeCondition.ghost)
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

      // Upload photo if selected
      String? photoUrl;
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final mimeType = _selectedImage!.mimeType ?? 'image/jpeg';
        photoUrl = await repository.uploadPhoto(imageBytes, mimeType);
      }

      // Submit report with optional photo URL
      await repository.submitFridgeReport(
        widget.fridge.id,
        _selectedCondition,
        _foodPercentage,
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoUrl,
      );

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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Condition Selection
          Text(
            'Fridge Condition',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          // Radio buttons for condition selection (exclude ghost)
          ...FridgeCondition.values
              .where((condition) => condition != FridgeCondition.ghost)
              .map(
                (condition) => RadioListTile<FridgeCondition>(
                  title: Text(_conditionLabel(condition)),
                  value: condition,
                  groupValue: _selectedCondition,
                  onChanged: (FridgeCondition? value) {
                    if (value != null) {
                      setState(() => _selectedCondition = value);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
          const SizedBox(height: 16),

          // Food Level Slider
          Text(
            'Food Level: ${_getFoodLevelLabel()}',
            style: Theme.of(context).textTheme.titleSmall,
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Empty', style: Theme.of(context).textTheme.bodySmall),
              Text('Few Items', style: Theme.of(context).textTheme.bodySmall),
              Text('Many Items', style: Theme.of(context).textTheme.bodySmall),
              Text('Full', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          Text(
            'Additional Notes (Optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any additional information...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo Upload
          Text(
            'Photo (Optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
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
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Update'),
            ),
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
