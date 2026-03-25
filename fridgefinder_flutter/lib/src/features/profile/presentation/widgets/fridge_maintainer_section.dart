import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';

/// Maintainer information section.
class FridgeMaintainerSection extends StatelessWidget {
  final FridgeDomain fridge;

  const FridgeMaintainerSection({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    final m = fridge.maintainer;
    if (m == null) return const SizedBox.shrink();

    final hasContent = m.organization != null ||
        m.email != null ||
        m.phone != null ||
        m.name != null;

    if (!hasContent) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, size: 20),
              SizedBox(width: M3ESpacing.xs),
              Text('Maintainer', style: M3ETypography.labelLarge),
            ],
          ),
          SizedBox(height: M3ESpacing.xs),
          Padding(
            padding: EdgeInsets.only(left: M3ESpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (m.name != null) Text(m.name!),
                if (m.organization != null) Text(m.organization!),
                if (m.email != null) Text(m.email!),
                if (m.phone != null) Text(m.phone!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
