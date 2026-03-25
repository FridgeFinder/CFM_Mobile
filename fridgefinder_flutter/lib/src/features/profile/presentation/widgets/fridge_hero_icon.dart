import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system/design_system.dart';
import '../../../map/domain/models/fridge_domain.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/utils/fridge_icon_utils.dart';

/// Hero icon widget with animated glow for followed fridges.
/// Only watches `isFridgeSubscribedProvider` — does NOT rebuild on GPS updates.
class FridgeHeroIcon extends ConsumerStatefulWidget {
  final FridgeDomain fridge;

  const FridgeHeroIcon({super.key, required this.fridge});

  @override
  ConsumerState<FridgeHeroIcon> createState() => _FridgeHeroIconState();
}

class _FridgeHeroIconState extends ConsumerState<FridgeHeroIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: M3EMotion.extraLong2,
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubscribedAsync = ref.watch(
      isFridgeSubscribedProvider(widget.fridge.id),
    );
    final isSubscribed = isSubscribedAsync.whenOrNull(
      data: (subscribed) => subscribed,
    ) ?? false;

    // Start/stop glow based on subscription
    if (isSubscribed && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!isSubscribed && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0.0;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 48,
          height: 48,
          decoration: isSubscribed
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: M3EColors.follow.withValues(
                        alpha: _glowAnimation.value,
                      ),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: FridgeIconUtils.getFridgeIcon(
            fridge: widget.fridge,
            size: 48,
          ),
        );
      },
    );
  }
}
