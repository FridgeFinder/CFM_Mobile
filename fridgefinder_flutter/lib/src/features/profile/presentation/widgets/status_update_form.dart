import 'package:flutter/material.dart';
import '../../../map/domain/models/fridge_domain.dart';

/// Form for reporting fridge status updates
class StatusUpdateForm extends StatefulWidget {
  final FridgeDomain fridge;

  const StatusUpdateForm({super.key, required this.fridge});

  @override
  State<StatusUpdateForm> createState() => _StatusUpdateFormState();
}

class _StatusUpdateFormState extends State<StatusUpdateForm> {
  late FridgeCondition _selectedCondition;
  late double _foodPercentage;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCondition =
        widget.fridge.latestFridgeReport?.condition ?? FridgeCondition.good;
    _foodPercentage = widget.fridge.latestFridgeReport?.foodPercentage ?? 0.5;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: Implement actual status update submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status update submitted for ${widget.fridge.name}'),
      ),
    );
    Navigator.pop(context);
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
          SegmentedButton<FridgeCondition>(
            segments: FridgeCondition.values
                .map(
                  (condition) => ButtonSegment(
                    value: condition,
                    label: Text(_conditionLabel(condition)),
                  ),
                )
                .toList(),
            selected: {_selectedCondition},
            onSelectionChanged: (Set<FridgeCondition> newSelection) {
              setState(() => _selectedCondition = newSelection.first);
            },
          ),
          const SizedBox(height: 16),

          // Food Level Slider
          Text(
            'Food Level: ${(_foodPercentage * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: _foodPercentage,
            onChanged: (value) {
              setState(() => _foodPercentage = value);
            },
            min: 0,
            max: 1,
            divisions: 10,
            label: '${(_foodPercentage * 100).toStringAsFixed(0)}%',
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
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Submit Update'),
            ),
          ),
        ],
      ),
    );
  }

  String _conditionLabel(FridgeCondition condition) {
    switch (condition) {
      case FridgeCondition.good:
        return 'Good - Operational';
      case FridgeCondition.dirty:
        return 'Dirty - Needs Cleaning';
      case FridgeCondition.outOfOrder:
        return 'Out of Order';
      case FridgeCondition.ghost:
        return 'Ghost - No Longer There';
      case FridgeCondition.notAtLocation:
        return 'Not at Location';
    }
  }
}
