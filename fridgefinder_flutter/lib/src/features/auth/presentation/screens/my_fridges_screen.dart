import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../map/presentation/widgets/fridge_marker.dart';
import '../../../profile/presentation/fridge_profile_sheet.dart';
import '../widgets/sign_in_widget.dart';
import '../../../../common_widgets/index.dart' as common_widgets;
import '../../../../common_widgets/loading_messages.dart';

/// My Fridges screen showing user's subscribed fridges
class MyFridgesScreen extends ConsumerWidget {
  const MyFridgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final subscriptionsAsync = ref.watch(subscribedFridgesProvider);
    final fridgesAsync = ref.watch(fridgeListProvider);

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
                  'Subscribe to specific fridges to receive updates on food availability or when fridges need re-stocking or cleaning.',
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

    return Scaffold(
      body: subscriptionsAsync.when(
        loading: () => LoadingIndicatorM3E(
          message: getRandomLoadingMessage(),
        ),
        error: (error, stackTrace) {
          logger.e('Error loading subscriptions: $error');
          return common_widgets.ErrorView(
            message: 'Failed to load your fridges',
            onRetry: () => ref.refresh(subscribedFridgesProvider),
          );
        },
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return Center(
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
                      'No Subscribed Fridges',
                      style: M3ETypography.headlineMedium,
                    ),
                    M3ESpacing.verticalMD,
                    Text(
                      'Subscribe to fridges to receive notifications about food availability, cleaning needs, and more.',
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
            );
          }

          return fridgesAsync.when(
            loading: () => LoadingIndicatorM3E(
              message: getRandomLoadingMessage(),
            ),
            error: (error, stackTrace) => common_widgets.ErrorView(
              message: 'Failed to load fridge details',
              onRetry: () => ref.refresh(fridgeListProvider),
            ),
            data: (allFridges) {
              // Filter fridges to only show subscribed ones
              final subscribedFridgeIds = subscriptions
                  .map((s) => s.fridgeId)
                  .toSet();
              final subscribedFridges = allFridges
                  .where((fridge) => subscribedFridgeIds.contains(fridge.id))
                  .toList();

              if (subscribedFridges.isEmpty) {
                return Center(
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
                          'No Subscribed Fridges',
                          style: M3ETypography.headlineMedium,
                        ),
                        M3ESpacing.verticalMD,
                        Text(
                          'Some of your subscribed fridges may no longer be available.',
                          textAlign: TextAlign.center,
                          style: M3ETypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: subscribedFridges.length,
                itemBuilder: (context, index) {
                  final fridge = subscribedFridges[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.kitchen,
                        color: FridgeMarker.subscribedGreen,
                      ),
                      title: Text(fridge.name),
                      subtitle: Text(fridge.location.shortAddress),
                      trailing: Icon(
                        Icons.favorite,
                        color: FridgeMarker.subscribedGreen,
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
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
