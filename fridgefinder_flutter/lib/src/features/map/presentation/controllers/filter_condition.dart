import '../../domain/models/fridge_domain.dart';

/// Filter condition enum matching the map key design
/// Food level categories: Full >= 75%, Many >= 50%, Few > 0%, Empty = 0%
enum FilterCondition {
  full('full'), // Green - Full (75-100% food)
  manyItems('many_items'), // Yellow - Many Items (50-74% food)
  fewItems('few_items'), // Pink - Few Items (1-49% food)
  empty('empty'), // White - Empty (0% food)
  needsCleaning('needs_cleaning'), // Dirty condition
  needsServicing('needs_servicing'), // Out of order condition
  notAtLocation('not_at_location'); // Not at location

  const FilterCondition(this.value);
  final String value;

  /// Get display label for filter
  String get label {
    switch (this) {
      case FilterCondition.full:
        return 'Full';
      case FilterCondition.manyItems:
        return 'Many Items';
      case FilterCondition.fewItems:
        return 'Few Items';
      case FilterCondition.empty:
        return 'Empty';
      case FilterCondition.needsCleaning:
        return 'Needs Cleaning';
      case FilterCondition.needsServicing:
        return 'Needs Repairs';
      case FilterCondition.notAtLocation:
        return 'Not at Location';
    }
  }

  /// Check if a fridge matches this filter condition
  /// Food level filters check ONLY food percentage (regardless of condition)
  /// Condition filters check ONLY condition (regardless of food level)
  bool matches(FridgeDomain fridge) {
    final report = fridge.latestFridgeReport;

    // Fridges with no report don't match food-level filters (unknown status)
    // They only match condition filters based on the fridge's actual condition
    if (report == null) {
      switch (this) {
        case FilterCondition.full:
        case FilterCondition.manyItems:
        case FilterCondition.fewItems:
        case FilterCondition.empty:
          // No report = unknown food level, don't match food filters
          return false;
        case FilterCondition.needsCleaning:
        case FilterCondition.needsServicing:
        case FilterCondition.notAtLocation:
          // Match condition filters based on fridge's condition (not from report)
          return false; // For now, don't match if no report
      }
    }

    switch (this) {
      case FilterCondition.full:
        // Full: >= 75% food (regardless of condition)
        return report.foodPercentage >= 0.75;
      case FilterCondition.manyItems:
        // Many items: 50-74% food (regardless of condition)
        return report.foodPercentage >= 0.5 &&
            report.foodPercentage < 0.75;
      case FilterCondition.fewItems:
        // Few items: 1-49% food (regardless of condition)
        return report.foodPercentage > 0 &&
            report.foodPercentage < 0.5;
      case FilterCondition.empty:
        // Empty: 0% food (regardless of condition)
        return report.foodPercentage == 0;
      case FilterCondition.needsCleaning:
        // Dirty condition (regardless of food level)
        return report.condition == FridgeCondition.dirty;
      case FilterCondition.needsServicing:
        // Out of order condition (regardless of food level)
        return report.condition == FridgeCondition.outOfOrder;
      case FilterCondition.notAtLocation:
        // Not at location (regardless of food level)
        return report.condition == FridgeCondition.notAtLocation;
    }
  }
}
