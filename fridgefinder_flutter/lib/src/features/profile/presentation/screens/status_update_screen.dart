import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../widgets/status_update_form.dart';

/// Full-screen page wrapper for StatusUpdateForm.
///
/// Launched via `Navigator.of(context, rootNavigator: true).push()` from the
/// fridge profile sheet to avoid GoRouter route-change detection dismissing
/// the bottom sheet.
class StatusUpdateScreen extends ConsumerStatefulWidget {
  final FridgeDomain fridge;
  final ScaffoldMessengerState? parentMessenger;

  const StatusUpdateScreen({
    super.key,
    required this.fridge,
    this.parentMessenger,
  });

  @override
  ConsumerState<StatusUpdateScreen> createState() =>
      _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends ConsumerState<StatusUpdateScreen> {
  bool _hasUnsavedChanges = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldDiscard = await DialogM3E.showConfirmation(
          context: context,
          title: 'Discard changes?',
          message: 'You have unsaved changes that will be lost.',
          confirmText: 'Discard',
          isDestructive: true,
        );
        if (shouldDiscard == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Status Update'),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(
              left: M3ESpacing.md,
              right: M3ESpacing.md,
              top: M3ESpacing.sm,
            ),
            child: StatusUpdateForm(
            fridge: widget.fridge,
            parentMessenger: widget.parentMessenger,
            onDirtyChanged: (isDirty) {
              setState(() => _hasUnsavedChanges = isDirty);
            },
          ),
          ),
        ),
      ),
    );
  }
}
