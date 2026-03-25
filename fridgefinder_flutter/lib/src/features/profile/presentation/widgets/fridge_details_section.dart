import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';

/// Details section: fridge notes, instagram link, website link.
class FridgeDetailsSection extends StatelessWidget {
  final FridgeDomain fridge;

  const FridgeDetailsSection({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    final hasNotes = fridge.notes != null && fridge.notes!.isNotEmpty;
    final hasInstagram = fridge.maintainer?.instagram != null;
    final hasWebsite = fridge.maintainer?.website != null;

    if (!hasNotes && !hasInstagram && !hasWebsite) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: M3ESpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              SizedBox(width: M3ESpacing.xs),
              Text('Details', style: M3ETypography.labelLarge),
            ],
          ),
          SizedBox(height: M3ESpacing.xs),
          Padding(
            padding: EdgeInsets.only(left: M3ESpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasNotes) ...[
                  Text(
                    fridge.notes!,
                    style: M3ETypography.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasInstagram || hasWebsite)
                    SizedBox(height: M3ESpacing.sm),
                ],
                if (hasInstagram)
                  _buildLinkRow(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    text: 'Instagram',
                    url: fridge.maintainer!.instagram!,
                  ),
                if (hasWebsite) ...[
                  if (hasInstagram) SizedBox(height: M3ESpacing.xs),
                  _buildLinkRow(
                    context: context,
                    icon: Icons.language,
                    text: 'Website',
                    url: fridge.maintainer!.website!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow({
    required BuildContext context,
    required IconData icon,
    required String text,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: M3ESpacing.xxs),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: M3ESpacing.xs),
            Flexible(
              child: Text(
                text,
                style: M3ETypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
