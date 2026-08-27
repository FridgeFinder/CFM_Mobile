// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'followed_fridges_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for user's followed fridges

@ProviderFor(followedFridges)
const followedFridgesProvider = FollowedFridgesProvider._();

/// Provider for user's followed fridges

final class FollowedFridgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FridgeNotificationPreferences>>,
          List<FridgeNotificationPreferences>,
          Stream<List<FridgeNotificationPreferences>>
        >
    with
        $FutureModifier<List<FridgeNotificationPreferences>>,
        $StreamProvider<List<FridgeNotificationPreferences>> {
  /// Provider for user's followed fridges
  const FollowedFridgesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followedFridgesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followedFridgesHash();

  @$internal
  @override
  $StreamProviderElement<List<FridgeNotificationPreferences>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FridgeNotificationPreferences>> create(Ref ref) {
    return followedFridges(ref);
  }
}

String _$followedFridgesHash() => r'00eaf2a1bfb1aecd18e66b20accfeb41cafaafbe';

/// Provider for checking if a fridge is followed

@ProviderFor(isFridgeFollowed)
const isFridgeFollowedProvider = IsFridgeFollowedFamily._();

/// Provider for checking if a fridge is followed

final class IsFridgeFollowedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for checking if a fridge is followed
  const IsFridgeFollowedProvider._({
    required IsFridgeFollowedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFridgeFollowedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFridgeFollowedHash();

  @override
  String toString() {
    return r'isFridgeFollowedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isFridgeFollowed(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsFridgeFollowedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFridgeFollowedHash() => r'b5b4b61299e6156dc4c71514d8055ee7f1a2d3a2';

/// Provider for checking if a fridge is followed

final class IsFridgeFollowedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  const IsFridgeFollowedFamily._()
    : super(
        retry: null,
        name: r'isFridgeFollowedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for checking if a fridge is followed

  IsFridgeFollowedProvider call(String fridgeId) =>
      IsFridgeFollowedProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'isFridgeFollowedProvider';
}

/// Provider for alert preferences for a specific fridge.

@ProviderFor(fridgeAlertPreferences)
const fridgeAlertPreferencesProvider = FridgeAlertPreferencesFamily._();

/// Provider for alert preferences for a specific fridge.

final class FridgeAlertPreferencesProvider
    extends
        $FunctionalProvider<
          FridgeNotificationPreferences?,
          FridgeNotificationPreferences?,
          FridgeNotificationPreferences?
        >
    with $Provider<FridgeNotificationPreferences?> {
  /// Provider for alert preferences for a specific fridge.
  const FridgeAlertPreferencesProvider._({
    required FridgeAlertPreferencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fridgeAlertPreferencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fridgeAlertPreferencesHash();

  @override
  String toString() {
    return r'fridgeAlertPreferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<FridgeNotificationPreferences?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FridgeNotificationPreferences? create(Ref ref) {
    final argument = this.argument as String;
    return fridgeAlertPreferences(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FridgeNotificationPreferences? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FridgeNotificationPreferences?>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FridgeAlertPreferencesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fridgeAlertPreferencesHash() =>
    r'25e669bd2de73f71aa9553f7e262953c8c76ea49';

/// Provider for alert preferences for a specific fridge.

final class FridgeAlertPreferencesFamily extends $Family
    with $FunctionalFamilyOverride<FridgeNotificationPreferences?, String> {
  const FridgeAlertPreferencesFamily._()
    : super(
        retry: null,
        name: r'fridgeAlertPreferencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for alert preferences for a specific fridge.

  FridgeAlertPreferencesProvider call(String fridgeId) =>
      FridgeAlertPreferencesProvider._(argument: fridgeId, from: this);

  @override
  String toString() => r'fridgeAlertPreferencesProvider';
}

/// Notifier for managing followed fridges.

@ProviderFor(FollowManager)
const followManagerProvider = FollowManagerProvider._();

/// Notifier for managing followed fridges.
final class FollowManagerProvider
    extends $AsyncNotifierProvider<FollowManager, void> {
  /// Notifier for managing followed fridges.
  const FollowManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followManagerHash();

  @$internal
  @override
  FollowManager create() => FollowManager();
}

String _$followManagerHash() => r'461229edab8427e5a169ae6523d4771423bc5b55';

/// Notifier for managing followed fridges.

abstract class _$FollowManager extends $AsyncNotifier<void> {
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
