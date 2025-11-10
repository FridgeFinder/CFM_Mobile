import 'package:flutter/material.dart';
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

    final cardWidget = Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Icon Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SVG marker icon - same as map (with green glow if subscribed)
                  widget.isSubscribed
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fridge.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.fridge.location.shortAddress,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!widget.fridge.verified)
                    Tooltip(
                      message: 'Not verified',
                      child: Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            widget.fridge.statusText,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        widget.fridge.foodLevelText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          '${(widget.distanceKm! * 0.621371 * 10).round() / 10} mi',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return cardWidget;
  }
}
