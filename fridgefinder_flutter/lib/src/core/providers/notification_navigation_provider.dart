import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/app_logger.dart';
import '../../features/map/presentation/controllers/fridge_list_controller.dart';

part 'notification_navigation_provider.g.dart';

/// Provider for handling notification navigation
/// When a notification is tapped, this provider stores the fridge ID
/// and MapScreen will listen to this and show the fridge details
@riverpod
class NotificationNavigation extends _$NotificationNavigation {
  @override
  String? build() => null;

  /// Set fridge ID from notification tap
  void setFridgeId(String fridgeId) {
    logger.i('Notification navigation: setting fridge ID: $fridgeId');
    state = fridgeId;
    ref.read(selectedFridgeIdProvider.notifier).setSelectedFridgeId(fridgeId);
  }

  void clear() {
    state = null;
  }
}

