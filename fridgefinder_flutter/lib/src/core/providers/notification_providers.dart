import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/fcm_service.dart';
import '../services/device_id_service.dart';
import '../services/geofencing_service.dart';
import 'auth_provider.dart';
import '../../features/map/data/repositories/fridge_repository.dart';

part 'notification_providers.g.dart';

/// Provider for FCM Service
@riverpod
FCMService fcmService(Ref ref) {
  final service = FCMService(
    authRepository: ref.watch(authRepositoryProvider),
    deviceIdService: DeviceIdService(),
  );

  // Dispose FCM service when provider is disposed (fixes no-dispose bug)
  ref.onDispose(() {
    service.dispose();
  });

  // Initialize when auth state changes
  ref.listen(authUserProvider, (previous, next) async {
    next.when(
      data: (user) async {
        if (user != null) {
          // User signed in - initialize FCM
          await service.initialize();
        } else {
          // User signed out - delete token
          await service.deleteToken();
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  });

  return service;
}

/// Provider for Geofencing Service
@riverpod
GeofencingService geofencingService(Ref ref) {
  final fridgeRepository = ref.watch(fridgeRepositoryProvider);
  final service = GeofencingService(
    authRepository: ref.watch(authRepositoryProvider),
    fridgeRepository: fridgeRepository,
  );

  // Start/stop monitoring based on auth and settings
  ref.listen(userProfileProvider, (previous, next) async {
    next.whenData((profile) async {
      if (profile != null && profile.settings.geofencingEnabled) {
        await service.startMonitoring();
      } else {
        service.stopMonitoring();
      }
    });
  });

  return service;
}
