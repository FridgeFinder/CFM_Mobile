import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/followed_fridges_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/fridge_id_utils.dart';
import '../../../../core/utils/fridge_icon_utils.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../map/presentation/widgets/fridge_marker.dart';
import '../../../profile/presentation/fridge_profile_sheet.dart';
import '../widgets/sign_in_widget.dart';
import '../../../../common_widgets/index.dart' as common_widgets;
import '../../../../common_widgets/loading_messages.dart';

/// My Fridges screen showing user's followed fridges
class MyFridgesScreen extends ConsumerStatefulWidget {
  const MyFridgesScreen({super.key});

  @override
  ConsumerState<MyFridgesScreen> createState() => _MyFridgesScreenState();
}

class _MyFridgesScreenState extends ConsumerState<MyFridgesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listAnimationController;
  Timer? _listAnimationDelayTimer;

  Future<void> _handlePullToRefresh() async {
    ref.invalidate(followedFridgesProvider);
    ref.invalidate(fridgeListProvider);

    await Future.wait([
      ref.read(followedFridgesProvider.future),
      ref.read(fridgeListProvider.future),
    ]);
  }

  Widget _buildRefreshableEmptyState({
    required BuildContext context,
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: _handlePullToRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for list entrance
    _listAnimationController = AnimationController(
      duration: M3EMotion.long2,
      vsync: this,
    );

    // Delay animation start until after first frame renders (so it's more noticeable)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Add a small extra delay so the animation is visible
        _listAnimationDelayTimer = Timer(const Duration(milliseconds: 150), () {
          if (mounted) {
            _listAnimationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _listAnimationDelayTimer?.cancel();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final followedFridgesAsync = ref.watch(followedFridgesProvider);
    final fridgesAsync = ref.watch(fridgeListProvider);

    final followedFridgeNotifications = followedFridgesAsync.hasValue
        ? followedFridgesAsync.value ?? const []
        : null;
    final allFridges = fridgesAsync.hasValue ? fridgesAsync.value ?? const [] : null;

    if (!isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: M3ESpacing.all(M3ESpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                M3ESpacing.verticalXL,
                Text(
                  'Follow specific fridges to receive updates on food availability or when fridges need re-stocking or cleaning.',
                  textAlign: TextAlign.center,
                  style: M3ETypography.bodyMedium,
                ),
                M3ESpacing.verticalXS,
                Text(
                  'This option is available for both people looking for food and volunteers.',
                  textAlign: TextAlign.center,
                  style: M3ETypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                M3ESpacing.verticalXXL,
                FilledButtonM3E(
                  icon: Icons.login,
                  onPressed: () {
                    DialogM3E.showCustom(
                      context: context,
                      child: Padding(
                        padding: M3ESpacing.all(M3ESpacing.xl),
                        child: SignInWidget(),
                      ),
                    );
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (followedFridgeNotifications == null && followedFridgesAsync.isLoading) {
      return Scaffold(
        body: LoadingIndicatorM3E(
          message: getRandomLoadingMessage(),
        ),
      );
    }

    if (followedFridgeNotifications == null && followedFridgesAsync.hasError) {
      logger.e('Error loading followed fridges: ${followedFridgesAsync.error}');
      return Scaffold(
        body: common_widgets.ErrorView(
          message: 'Failed to load your fridges',
          onRetry: () => ref.refresh(followedFridgesProvider),
        ),
      );
    }

    if (followedFridgeNotifications == null || followedFridgeNotifications.isEmpty) {
      return Scaffold(
        body: _buildRefreshableEmptyState(
          context: context,
          child: Padding(
            padding: M3ESpacing.all(M3ESpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                M3ESpacing.verticalXL,
                Text(
                  'No Followed Fridges',
                  style: M3ETypography.headlineMedium,
                ),
                M3ESpacing.verticalMD,
                Text(
                  'Follow fridges to receive notifications about food availability, cleaning needs, and more.',
                  textAlign: TextAlign.center,
                  style: M3ETypography.bodyMedium,
                ),
                M3ESpacing.verticalXXL,
                FilledButtonM3E(
                  icon: Icons.map,
                  onPressed: () => context.go('/'),
                  child: const Text('Browse Fridges'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (allFridges == null && fridgesAsync.isLoading) {
      return Scaffold(
        body: LoadingIndicatorM3E(
          message: getRandomLoadingMessage(),
        ),
      );
    }

    if (allFridges == null && fridgesAsync.hasError) {
      return Scaffold(
        body: common_widgets.ErrorView(
          message: 'Failed to load fridge details',
          onRetry: () => ref.refresh(fridgeListProvider),
        ),
      );
    }

    final followedFridgeIds = followedFridgeNotifications
        .map((s) => normalizeFridgeId(s.fridgeId))
        .where((id) => id.isNotEmpty)
        .toSet();
    final followedFridges = (allFridges ?? const <dynamic>[])
      .where((fridge) => followedFridgeIds.contains(normalizeFridgeId(fridge.id)))
        .toList();

    if (followedFridges.isEmpty) {
      return Scaffold(
        body: _buildRefreshableEmptyState(
          context: context,
          child: Padding(
            padding: M3ESpacing.all(M3ESpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                M3ESpacing.verticalXL,
                Text(
                  'No Followed Fridges',
                  style: M3ETypography.headlineMedium,
                ),
                M3ESpacing.verticalMD,
                Text(
                  'Some of your followed fridges may no longer be available.',
                  textAlign: TextAlign.center,
                  style: M3ETypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
          onRefresh: _handlePullToRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: M3ESpacing.md,
              vertical: M3ESpacing.sm,
            ),
            itemCount: followedFridges.length,
            itemBuilder: (context, index) {
              final fridge = followedFridges[index];
              final report = fridge.latestFridgeReport;
              final statusIcon = report != null
                  ? FridgeIconUtils.getStatusIcon(report.condition)
                  : Icons.help;
              final statusColor = report != null
                  ? FridgeIconUtils.getStatusColor(report.condition)
                  : Colors.grey;

              // Wrap each item with bouncy entrance animation
              return M3ETransitions.listItemEntrance(
                animation: _listAnimationController,
                index: index,
                totalItems: followedFridges.length.clamp(0, 10),
                child: Padding(
                  padding: M3ESpacing.only(bottom: M3ESpacing.sm),
                  child: ListTileM3E(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: FridgeIconUtils.getFridgeIcon(
                      fridge: fridge,
                      size: 40,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fridge.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: FridgeMarker.followedGold,
                        size: 20,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fridge.location.shortAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      M3ESpacing.verticalXXS,
                      Row(
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          M3ESpacing.horizontalXXS,
                          Text(
                            fridge.statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          M3ESpacing.horizontalSM,
                          Text(
                            'Food: ${fridge.foodLevelText}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(selectedFridgeIdProvider.notifier)
                        .setSelectedFridgeId(fridge.id);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          FridgeProfileSheet(fridge: fridge),
                    );
                  },
                ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
