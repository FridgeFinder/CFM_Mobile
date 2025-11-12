import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Error display widget with retry action
class ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorView({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
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
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            M3ESpacing.verticalMD,
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            M3ESpacing.verticalXS,
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              M3ESpacing.verticalMD,
              FilledButtonM3E(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
