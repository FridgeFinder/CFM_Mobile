import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../../map/domain/models/fridge_domain.dart';
import '../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../core/providers/drawer_provider.dart';
import 'widgets/fridge_profile_header.dart';
import 'widgets/fridge_profile_button_row.dart';
import 'widgets/fridge_profile_photo.dart';
import 'widgets/fridge_latest_status.dart';
import 'widgets/fridge_details_section.dart';
import 'widgets/fridge_maintainer_section.dart';
import 'widgets/fridge_action_buttons.dart';

/// Bottom sheet modal displaying detailed fridge information.
///
/// Thin orchestrator that composes focused child widgets.
/// Each child widget watches only the providers it needs,
/// preventing full-sheet rebuilds on GPS updates.
class FridgeProfileSheet extends ConsumerStatefulWidget {
  final FridgeDomain fridge;

  const FridgeProfileSheet({super.key, required this.fridge});

  @override
  ConsumerState<FridgeProfileSheet> createState() => _FridgeProfileSheetState();
}

class _FridgeProfileSheetState extends ConsumerState<FridgeProfileSheet> {
  int _lastCloseTrigger = 0;

  @override
  Widget build(BuildContext context) {
    // Side-effect only: close sheet when drawer opens
    ref.listen<bool>(drawerStateProvider, (prev, next) {
      if (next && mounted) {
        Navigator.of(context).pop();
      }
    });

    // Side-effect only: close sheet on external trigger
    ref.listen<int>(bottomSheetCloseTriggerProvider, (prev, next) {
      if (next > _lastCloseTrigger && mounted) {
        _lastCloseTrigger = next;
        Navigator.of(context).pop();
      }
    });

    // Watch fridge data for latest updates, fallback to initial fridge
    final fridgeAsync = ref.watch(singleFridgeProvider(widget.fridge.id));
    final fridge = fridgeAsync.whenOrNull(data: (f) => f) ?? widget.fridge;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandleM3E(),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.all(M3ESpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: hero icon, name, address, neighborhood, distance
                    FridgeProfileHeader(fridge: fridge),
                    SizedBox(height: M3ESpacing.md),

                    // Follow/Unfollow + Directions buttons
                    FridgeProfileButtonRow(fridge: fridge),
                    SizedBox(height: M3ESpacing.xl),

                    // Fridge photo (3:4 aspect ratio)
                    FridgeProfilePhoto(fridge: fridge),
                    if (fridge.photoUrl != null)
                      SizedBox(height: M3ESpacing.lg),

                    // Latest status update section
                    FridgeLatestStatus(fridge: fridge),

                    // Details: notes, instagram, website
                    FridgeDetailsSection(fridge: fridge),

                    // Maintainer info
                    FridgeMaintainerSection(fridge: fridge),

                    // Report Status Update + Share
                    FridgeActionButtons(fridge: fridge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
