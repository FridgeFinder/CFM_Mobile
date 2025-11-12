import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Empty state display widget
class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: M3ESpacing.all(M3ESpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            M3ESpacing.verticalMD,
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            M3ESpacing.verticalXS,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[M3ESpacing.verticalMD, action!],
          ],
        ),
      ),
    );
  }
}
