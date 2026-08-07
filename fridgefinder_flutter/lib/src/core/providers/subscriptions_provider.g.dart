// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscriptions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user's subscribed fridges

@ProviderFor(subscribedFridges)
const subscribedFridgesProvider = SubscribedFridgesProvider._();

/// Provider for user's subscribed fridges

final class SubscribedFridgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SubscriptionPreferences>>,
          List<SubscriptionPreferences>,
          Stream<List<SubscriptionPreferences>>
        >
    with
        $FutureModifier<List<SubscriptionPreferences>>,
        $StreamProvider<List<SubscriptionPreferences>> {
  /// Provider for user's subscribed fridges
  const SubscribedFridgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscribedFridgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscribedFridgesHash();

  @$internal
  @override
  $StreamProviderElement<List<SubscriptionPreferences>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SubscriptionPreferences>> create(Ref ref) {
    return subscribedFridges(ref);
  }
}

String _$subscribedFridgesHash() => r'7eb8e64945d48c96ad4c349786e95d636219f55e';

/// Provider for checking if a fridge is subscribed

@ProviderFor(isFridgeSubscribed)
const isFridgeSubscribedProvider = IsFridgeSubscribedFamily._();

/// Provider for checking if a fridge is subscribed

final class IsFridgeSubscribedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking if a fridge is subscribed
  const IsFridgeSubscribedProvider._({
    required IsFridgeSubscribedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFridgeSubscribedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFridgeSubscribedHash();

  @override
  String toString() {
    return r'isFridgeSubscribedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isFridgeSubscribed(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFridgeSubscribedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFridgeSubscribedHash() =>
    r'680ca81fd78bf7dfa81b03fba005a250e871c1ba';

/// Provider for checking if a fridge is subscribed

final class IsFridgeSubscribedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsFridgeSubscribedFamily._()
    : super(
        retry: null,
        name: r'isFridgeSubscribedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for checking if a fridge is subscribed

  IsFridgeSubscribedProvider call(String fridgeId) =>
      IsFridgeSubscribedProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'isFridgeSubscribedProvider';
}

/// Provider for subscription preferences for a specific fridge

@ProviderFor(fridgeSubscriptionPreferences)
const fridgeSubscriptionPreferencesProvider =
    FridgeSubscriptionPreferencesFamily._();

/// Provider for subscription preferences for a specific fridge

final class FridgeSubscriptionPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SubscriptionPreferences?>,
          SubscriptionPreferences?,
          FutureOr<SubscriptionPreferences?>
        >
    with
        $FutureModifier<SubscriptionPreferences?>,
        $FutureProvider<SubscriptionPreferences?> {
  /// Provider for subscription preferences for a specific fridge
  const FridgeSubscriptionPreferencesProvider._({
    required FridgeSubscriptionPreferencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fridgeSubscriptionPreferencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fridgeSubscriptionPreferencesHash();

  @override
  String toString() {
    return r'fridgeSubscriptionPreferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SubscriptionPreferences?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SubscriptionPreferences?> create(Ref ref) {
    final argument = this.argument as String;
    return fridgeSubscriptionPreferences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FridgeSubscriptionPreferencesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fridgeSubscriptionPreferencesHash() =>
    r'2e34fe5da0bbb114b5ae64d33dc398dbe3ad6a69';

/// Provider for subscription preferences for a specific fridge

final class FridgeSubscriptionPreferencesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SubscriptionPreferences?>, String> {
  const FridgeSubscriptionPreferencesFamily._()
    : super(
        retry: null,
        name: r'fridgeSubscriptionPreferencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for subscription preferences for a specific fridge

  FridgeSubscriptionPreferencesProvider call(String fridgeId) =>
      FridgeSubscriptionPreferencesProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'fridgeSubscriptionPreferencesProvider';
}

/// Notifier for managing subscriptions

@ProviderFor(SubscriptionManager)
const subscriptionManagerProvider = SubscriptionManagerProvider._();

/// Notifier for managing subscriptions
final class SubscriptionManagerProvider
    extends $AsyncNotifierProvider<SubscriptionManager, void> {
  /// Notifier for managing subscriptions
  const SubscriptionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionManagerHash();

  @$internal
  @override
  SubscriptionManager create() => SubscriptionManager();
}

String _$subscriptionManagerHash() =>
    r'3231db0dbb505b1fa4a84b2a1cebe3d7413e6140';

/// Notifier for managing subscriptions

abstract class _$SubscriptionManager extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
