import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';

/// Fridge photo section with 3:4 aspect ratio and shimmer loading.
class FridgeProfilePhoto extends StatelessWidget {
  final FridgeDomain fridge;

  const FridgeProfilePhoto({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    if (fridge.photoUrl == null) return const SizedBox.shrink();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: AspectRatio(
          aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            fridge.photoUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            key: ValueKey('fridge_photo_${fridge.photoUrl}'),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicatorM3E.small(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
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
      ),
    ),
    );
  }
}
