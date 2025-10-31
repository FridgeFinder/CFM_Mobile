import 'package:flutter/material.dart';
import '../../domain/models/fridge_domain.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Custom marker widget for displaying fridge on map
/// Uses SVG icons that match the web app design system
class FridgeMarker extends StatelessWidget {
  final FridgeDomain fridge;
  static const double markerSize = 40;

  const FridgeMarker({super.key, required this.fridge});

  @override
  Widget build(BuildContext context) {
    return FridgeIconUtils.getFridgeIcon(fridge: fridge, size: markerSize);
  }
}
