import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'loading_messages.dart';

/// Centered loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return LoadingIndicatorM3E(
      message: message ?? getRandomLoadingMessage(),
    );
  }
}
