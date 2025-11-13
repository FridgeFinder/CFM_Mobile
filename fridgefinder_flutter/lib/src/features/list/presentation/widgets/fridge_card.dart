import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../map/presentation/widgets/fridge_marker.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Card widget for displaying a fridge in the list
/// Uses the same icon system as the map for consistency
class FridgeCard extends StatefulWidget {
  final FridgeDomain fridge;
  final VoidCallback onTap;
  final double? distanceKm;
  final bool isSubscribed;
  static const double iconSize = 48;

  const FridgeCard({
    super.key,
    required this.fridge,
    required this.onTap,
    this.distanceKm,
    this.isSubscribed = false,
  });

  @override
  State<FridgeCard> createState() => _FridgeCardState();
}

class _FridgeCardState extends State<FridgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.isSubscribed) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    } else {
      _controller = AnimationController(vsync: this);
      _animation = const AlwaysStoppedAnimation(0.0);
    }
  }

  @override
  void didUpdateWidget(FridgeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSubscribed != oldWidget.isSubscribed) {
      if (widget.isSubscribed) {
        _controller.duration = const Duration(milliseconds: 1500);
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.fridge.latestFridgeReport;
    final statusIcon = report != null
        ? FridgeIconUtils.getStatusIcon(report.condition)
        : Icons.help;
    final statusColor = report != null
        ? FridgeIconUtils.getStatusColor(report.condition)
        : Colors.grey;

    return CardM3E(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Icon Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SVG marker icon - same as map (with green glow if subscribed)
              // Wrapped in Hero for smooth transition to detail view
              Hero(
                tag: 'fridge-icon-${widget.fridge.id}',
                child: widget.isSubscribed
                    ? AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Container(
                            width: FridgeCard.iconSize,
                            height: FridgeCard.iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: FridgeMarker.subscribedGreen
                                      .withValues(alpha: _animation.value * 0.6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: FridgeMarker.subscribedGreen
                                      .withValues(alpha: _animation.value * 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: FridgeIconUtils.getFridgeIcon(
                              fridge: widget.fridge,
                              size: FridgeCard.iconSize,
                            ),
                          );
                        },
                      )
                    : SizedBox(
                        width: FridgeCard.iconSize,
                        height: FridgeCard.iconSize,
                        child: FridgeIconUtils.getFridgeIcon(
                          fridge: widget.fridge,
                          size: FridgeCard.iconSize,
                        ),
                      ),
              ),
              M3ESpacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fridge.name,
                      style: M3ETypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    M3ESpacing.verticalXXS,
                    Text(
                      widget.fridge.location.shortAddress,
                      style: M3ETypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          M3ESpacing.verticalMD,

          // Status, Food Level, and Distance Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status with icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: M3ETypography.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      M3ESpacing.horizontalXS,
                      Text(
                        widget.fridge.statusText,
                        style: M3ETypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Food Level
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Food Level',
                    style: M3ETypography.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.fridge.foodLevelText,
                    style: M3ETypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Distance
              if (widget.distanceKm != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Distance',
                      style: M3ETypography.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(widget.distanceKm! * 0.621371 * 10).round() / 10} mi',
                      style: M3ETypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
