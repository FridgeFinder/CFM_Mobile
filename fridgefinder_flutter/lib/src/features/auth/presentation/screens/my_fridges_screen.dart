import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../map/presentation/controllers/fridge_list_controller.dart';
import '../../../map/presentation/widgets/fridge_marker.dart';
import '../../../profile/presentation/fridge_profile_sheet.dart';
import '../widgets/sign_in_widget.dart';
import '../../../../common_widgets/index.dart' as common_widgets;

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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'My Fridges',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Subscribe to specific fridges to receive updates on food availability or when fridges need re-stocking or cleaning.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This option is available for both people looking for food and volunteers.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: SignInWidget(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: subscriptionsAsync.when(
        loading: () => const common_widgets.LoadingIndicator(
          message: 'Loading your fridges...',
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No Subscribed Fridges',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Subscribe to fridges to receive notifications about food availability, cleaning needs, and more.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.map),
                      label: const Text('Browse Fridges'),
                    ),
                  ],
                ),
              ),
            );
          }

          return fridgesAsync.when(
            loading: () => const common_widgets.LoadingIndicator(
              message: 'Loading fridge details...',
            ),
            error: (error, stackTrace) => common_widgets.ErrorView(
              message: 'Failed to load fridge details',
              onRetry: () => ref.refresh(fridgeListProvider),
            ),
            data: (allFridges) {
              // Filter fridges to only show subscribed ones
              final subscribedFridgeIds = subscriptions.map((s) => s.fridgeId).toSet();
              final subscribedFridges = allFridges
                  .where((fridge) => subscribedFridgeIds.contains(fridge.id))
                  .toList();

              if (subscribedFridges.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Subscribed Fridges',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Some of your subscribed fridges may no longer be available.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
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
                        ref.read(selectedFridgeIdProvider.notifier)
                            .setSelectedFridgeId(fridge.id);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => FridgeProfileSheet(fridge: fridge),
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

