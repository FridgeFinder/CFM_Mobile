import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drawer_provider.g.dart';

/// Provider for tracking drawer state
/// MainShell updates this when drawer opens/closes
@riverpod
class DrawerState extends _$DrawerState {
  @override
  bool build() => false;

  void setOpen(bool isOpen) {
    state = isOpen;
  }
}

/// Provider for tracking if bottom sheet should be closed
/// Set to true to trigger bottom sheet closure
@riverpod
class BottomSheetCloseTrigger extends _$BottomSheetCloseTrigger {
  @override
  int build() => 0;

  void triggerClose() {
    state = state + 1;
  }
}

