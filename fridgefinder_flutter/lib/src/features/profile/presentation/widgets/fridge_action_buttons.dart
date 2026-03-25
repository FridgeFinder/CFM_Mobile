import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import 'status_update_form.dart';

/// Report Status Update + Share action buttons.
class FridgeActionButtons extends ConsumerWidget {
  final FridgeDomain fridge;

  const FridgeActionButtons({super.key, required this.fridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledTonalButtonM3E(
            onPressed: () => _showStatusUpdateDialog(context, ref),
            icon: Icons.edit,
            child: Text('Report Status Update', style: M3ETypography.labelLarge),
          ),
        ),
        SizedBox(height: M3ESpacing.sm),
        SizedBox(
          width: double.infinity,
          child: TextButtonM3E(
            onPressed: () => _share(context),
            icon: Icons.share,
            child: Text('Share', style: M3ETypography.labelLarge),
          ),
        ),
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref) {
    final fridgeAsync = ref.read(singleFridgeProvider(fridge.id));
    final liveFridge = fridgeAsync.whenOrNull(data: (f) => f) ?? fridge;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: EdgeInsets.all(M3ESpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report Status Update', style: M3ETypography.headlineSmall),
                SizedBox(height: M3ESpacing.md),
                Expanded(child: StatusUpdateForm(fridge: liveFridge)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final slug = fridge.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );
    final fridgeUrl = 'https://www.fridgefinder.app/fridge/$slug';

    try {
      await Clipboard.setData(ClipboardData(text: fridgeUrl));
      await Share.share(
        '${fridge.name}\n${fridge.location.fullAddress}\n\nView on FridgeFinder: $fridgeUrl',
        subject: 'Check out this community fridge: ${fridge.name}',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }
}
