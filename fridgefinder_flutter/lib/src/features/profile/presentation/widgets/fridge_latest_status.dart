import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Latest status update section with precise timestamp.
class FridgeLatestStatus extends StatelessWidget {
  final FridgeDomain fridge;

  const FridgeLatestStatus({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    final report = fridge.latestFridgeReport;
    if (report == null) {
      return _buildNoReportSection(context);
    }

    return _buildSection(
      context: context,
      icon: Icons.update,
      title: 'Latest Status Update',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp first
          if (report.reportDate != null)
            Padding(
              padding: EdgeInsets.only(bottom: M3ESpacing.xs),
              child: Text(
                DateFormat('M/d/yy h:mm a').format(report.reportDate!),
                style: M3ETypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          // Condition + Food Level row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Condition
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Condition',
                    style: M3ETypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        FridgeIconUtils.getStatusIcon(report.condition),
                        size: 18,
                        color: FridgeIconUtils.getStatusColor(report.condition),
                      ),
                      SizedBox(width: M3ESpacing.xxs),
                      Text(
                        fridge.statusText,
                        style: M3ETypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FridgeIconUtils.getStatusColor(report.condition),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Food Level
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Food Level',
                    style: M3ETypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    fridge.foodLevelText,
                    style: M3ETypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Notes
          if (report.notes != null) ...[
            SizedBox(height: M3ESpacing.sm),
            Text(
              'Notes',
              style: M3ETypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: M3ESpacing.xxs),
            Text(report.notes!, style: M3ETypography.bodyMedium),
          ],

          // Report Photo
          if (report.photoUrl != null) ...[
            SizedBox(height: M3ESpacing.sm),
            Text(
              'Report Photo',
              style: M3ETypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: M3ESpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                report.photoUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                key: ValueKey(
                  'report_photo_${report.photoUrl}_${report.timestamp ?? report.epochTimestamp ?? ''}',
                ),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: M3ESpacing.xs),
                        Text('Photo unavailable', style: M3ETypography.bodySmall),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoReportSection(BuildContext context) {
    return _buildSection(
      context: context,
      icon: Icons.info_outline,
      title: 'Status',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Condition', style: M3ETypography.bodySmall),
              Text(
                fridge.statusText,
                style: M3ETypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Food Level', style: M3ETypography.bodySmall),
              Text(
                fridge.foodLevelText,
                style: M3ETypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              SizedBox(width: M3ESpacing.xs),
              Text(title, style: M3ETypography.labelLarge),
            ],
          ),
          SizedBox(height: M3ESpacing.xs),
          Padding(
            padding: EdgeInsets.only(left: M3ESpacing.xxl),
            child: child,
          ),
        ],
      ),
    );
  }
}
