import '../../domain/models/fridge_domain.dart';

/// Filter condition enum that distinguishes between good fridges with/without food
/// Maps to FridgeCondition and food level for filtering
enum FilterCondition {
  goodWithFood('good_with_food'),
  goodEmpty('good_empty'),
  dirty('dirty'),
  outOfOrder('out_of_order'),
  ghost('ghost'),
  notAtLocation('not_at_location');

  const FilterCondition(this.value);
  final String value;

  /// Get display label for filter
  String get label {
    switch (this) {
      case FilterCondition.goodWithFood:
        return 'Good (w/ Food)';
      case FilterCondition.goodEmpty:
        return 'Good (Empty)';
      case FilterCondition.dirty:
        return 'Dirty';
      case FilterCondition.outOfOrder:
        return 'Out of Order';
      case FilterCondition.ghost:
        return 'Ghost';
      case FilterCondition.notAtLocation:
        return 'Not at Location';
    }
  }

  /// Check if a fridge matches this filter condition
  /// Takes into account both the condition and food level for "good" variants
  bool matches(FridgeDomain fridge) {
    final report = fridge.latestFridgeReport;

    if (report == null) {
      // No report - default to matching goodWithFood
      return this == FilterCondition.goodWithFood;
    }

    switch (this) {
      case FilterCondition.goodWithFood:
        return report.condition == FridgeCondition.good &&
            report.foodPercentage > 0;
      case FilterCondition.goodEmpty:
        return report.condition == FridgeCondition.good &&
            report.foodPercentage == 0;
      case FilterCondition.dirty:
        return report.condition == FridgeCondition.dirty;
      case FilterCondition.outOfOrder:
        return report.condition == FridgeCondition.outOfOrder;
      case FilterCondition.ghost:
        return report.condition == FridgeCondition.ghost;
      case FilterCondition.notAtLocation:
        return report.condition == FridgeCondition.notAtLocation;
    }
  }
}
