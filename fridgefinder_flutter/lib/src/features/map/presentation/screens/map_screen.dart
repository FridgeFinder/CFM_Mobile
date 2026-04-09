import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:design_system/design_system.dart';
import '../../../../core/providers/subscriptions_provider.dart';
import '../../domain/models/fridge_domain.dart';
import '../controllers/fridge_list_controller.dart';
import '../controllers/map_filter_controller.dart';
import '../widgets/fridge_marker.dart';
import '../widgets/fridge_cluster_widget.dart';
import '../widgets/user_location_indicator.dart';
import '../widgets/filter_status_indicator.dart';
import '../widgets/filter_pills_row.dart';
import '../../../profile/presentation/fridge_profile_sheet.dart';
import '../../../../common_widgets/index.dart' as common_widgets;
import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/map_cache_provider.dart';
import '../../../../core/providers/notification_navigation_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/map_constants.dart';

/// Map screen showing all community fridges on a map
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with AutomaticKeepAliveClientMixin {
  late MapController _mapController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isSearchVisible =
      false; // Controls search bar visibility with animation
  String?
  _handlingNotificationId; // Track which notification we're currently handling
  // ignore: unused_field
  Timer? _logOutputTimer; // Timer for outputting logs

  // GlobalKeys for each fridge marker to preserve state across rebuilds
  final Map<String, GlobalKey<State<FridgeMarker>>> _markerKeys = {};

  @override
  bool get wantKeepAlive => true; // Keep the map state alive

  // Logging system
  final List<String> _initLogs = [];
  bool _hasLoggedComplete = false;

  void _log(String message) {
    final timestamp = DateTime.now()
        .toIso8601String()
        .split('T')[1]
        .substring(0, 12);
    _initLogs.add('[$timestamp] $message');
  }

  void _outputAllLogs() {
    if (_hasLoggedComplete) return;
    _hasLoggedComplete = true;

    logger.i('\n${'=' * 80}');
    logger.i('🗺️ MAP INITIALIZATION COMPLETE LOG 🗺️'.toUpperCase());
    logger.i('=' * 80);
    for (final log in _initLogs) {
      logger.i(log);
    }
    logger.i('=' * 80);
    logger.i('END OF MAP INITIALIZATION LOG');
    logger.i('=' * 80 + '\n');
  }

  @override
  void initState() {
    super.initState();
    _log('🚀 initState: Starting map screen initialization');
    _mapController = MapController();
    _log('✅ initState: MapController created');
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _log('✅ initState: Controllers and focus nodes created');

    // Schedule a check to output logs after everything should be loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _log('📍 PostFrameCallback: First frame rendered');

      _logOutputTimer = Timer(const Duration(seconds: 3), () {
        _log('⏰ 3-second delay complete - outputting all logs');
        _outputAllLogs();
      });
    });
  }

  @override
  void dispose() {
    _log('🧹 dispose: Starting cleanup');
    _logOutputTimer
        ?.cancel(); // Cancel the timer to avoid pending timer errors in tests
    _outputAllLogs(); // Output logs before disposal in case we never reach the timer
    _mapController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showFridgeProfile(FridgeDomain fridge) {
    // Prevent opening multiple sheets - close any existing bottom sheet first
    if (!mounted) return;

    // Close any existing bottom sheet
    Navigator.of(context).popUntil((route) => route.isFirst || !route.isActive);

    ref.read(selectedFridgeIdProvider.notifier).setSelectedFridgeId(fridge.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FridgeProfileSheet(fridge: fridge),
    );
  }

  Future<void> _handleNotificationNavigation(String fridgeId) async {
    // Prevent multiple simultaneous calls for the same notification
    if (_handlingNotificationId == fridgeId) {
      logger.i(
        '🔔🔔🔔 NOTIFICATION NAV: Already handling fridge: $fridgeId, skipping 🔔🔔🔔',
      );
      return;
    }

    _handlingNotificationId = fridgeId;
    logger.i(
      '🔔🔔🔔 NOTIFICATION NAV: Handling navigation for fridge: $fridgeId 🔔🔔🔔',
    );

    try {
      // Wait for the next frame to ensure map is fully built and initialized
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      logger.i(
        '🔔🔔🔔 NOTIFICATION NAV: Starting fridge lookup for: $fridgeId 🔔🔔🔔',
      );

      // Wait for fridge list to load, then find and show the fridge
      final fridgesAsync = ref.read(fridgeListProvider);
      logger.i(
        '🔔🔔🔔 NOTIFICATION NAV: Fridge list state: ${fridgesAsync.runtimeType} 🔔🔔🔔',
      );

      fridgesAsync.when(
        data: (fridges) async {
          if (!mounted) return;

          logger.i(
            '🔔🔔🔔 NOTIFICATION NAV: Fridge list loaded with ${fridges.length} fridges, searching for: $fridgeId 🔔🔔🔔',
          );
          // Find the fridge in the list
          try {
            final fridge = fridges.firstWhere((f) => f.id == fridgeId);
            logger.i(
              '🔔🔔🔔 NOTIFICATION NAV: ✅ Found fridge "${fridge.name}" at (${fridge.location.geoLat}, ${fridge.location.geoLng}) 🔔🔔🔔',
            );

            // Zoom to fridge location
            final fridgeLocation = LatLng(
              fridge.location.geoLat,
              fridge.location.geoLng,
            );

            logger.i(
              '🔔🔔🔔 NOTIFICATION NAV: Moving map to location... 🔔🔔🔔',
            );
            _mapController.move(
              fridgeLocation,
              16.0,
            ); // Zoom level 16 for close-up view

            // Show fridge profile sheet after a short delay to ensure map has moved
            await Future.delayed(const Duration(milliseconds: 1000));
            if (!mounted) return;

            logger.i(
              '🔔🔔🔔 NOTIFICATION NAV: Showing fridge profile sheet 🔔🔔🔔',
            );
            _showFridgeProfile(fridge);
            // Clear the notification navigation state
            ref.read(notificationNavigationProvider.notifier).clear();
            logger.i('🔔🔔🔔 NOTIFICATION NAV: ✅ Complete! 🔔🔔🔔');
          } catch (e) {
            logger.w(
              '🔔🔔🔔 NOTIFICATION NAV: ❌ Fridge not found in list for ID: $fridgeId - $e 🔔🔔🔔',
            );
            // Try fetching directly from API as fallback
            try {
              logger.i(
                '🔔🔔🔔 NOTIFICATION NAV: Fetching fridge directly from API... 🔔🔔🔔',
              );
              final fridgeAsync = await ref.read(
                singleFridgeProvider(fridgeId).future,
              );
              if (!mounted) return;

              logger.i(
                '🔔🔔🔔 NOTIFICATION NAV: ✅ Fetched fridge directly: ${fridgeAsync.name} 🔔🔔🔔',
              );
              final fridgeLocation = LatLng(
                fridgeAsync.location.geoLat,
                fridgeAsync.location.geoLng,
              );
              logger.i(
                '🔔🔔🔔 NOTIFICATION NAV: Moving map to fetched fridge location... 🔔🔔🔔',
              );
              _mapController.move(fridgeLocation, 16.0);

              await Future.delayed(const Duration(milliseconds: 1000));
              if (!mounted) return;

              logger.i(
                '🔔🔔🔔 NOTIFICATION NAV: Showing fridge profile sheet 🔔🔔🔔',
              );
              _showFridgeProfile(fridgeAsync);
              ref.read(notificationNavigationProvider.notifier).clear();
              logger.i('🔔🔔🔔 NOTIFICATION NAV: ✅ Complete! 🔔🔔🔔');
            } catch (fetchError) {
              logger.e(
                '🔔🔔🔔 NOTIFICATION NAV: ❌ Failed to fetch fridge: $fetchError 🔔🔔🔔',
              );
              // Clear the notification navigation state even if fridge not found
              ref.read(notificationNavigationProvider.notifier).clear();
            }
          }
        },
        loading: () {
          // If still loading, wait a bit and try again
          logger.i(
            '🔔🔔🔔 NOTIFICATION NAV: ⏳ Fridge list still loading, waiting... 🔔🔔🔔',
          );
          Future.delayed(const Duration(milliseconds: 2000), () async {
            if (!mounted) return;
            // Re-trigger by reading the provider again
            final fridgesAsyncRetry = ref.read(fridgeListProvider);
            fridgesAsyncRetry.whenData((fridges) async {
              if (!mounted) return;
              try {
                final fridge = fridges.firstWhere((f) => f.id == fridgeId);
                logger.i(
                  '🔔🔔🔔 NOTIFICATION NAV: ✅ Found fridge after retry: ${fridge.name} 🔔🔔🔔',
                );
                final fridgeLocation = LatLng(
                  fridge.location.geoLat,
                  fridge.location.geoLng,
                );
                _mapController.move(fridgeLocation, 16.0);
                await Future.delayed(const Duration(milliseconds: 1000));
                if (!mounted) return;
                _showFridgeProfile(fridge);
                ref.read(notificationNavigationProvider.notifier).clear();
                logger.i('🔔🔔🔔 NOTIFICATION NAV: ✅ Complete! 🔔🔔🔔');
              } catch (e) {
                logger.w(
                  '🔔🔔🔔 NOTIFICATION NAV: ❌ Fridge still not found after retry: $e 🔔🔔🔔',
                );
                ref.read(notificationNavigationProvider.notifier).clear();
              }
            });
          });
        },
        error: (error, stack) {
          logger.e(
            '🔔🔔🔔 NOTIFICATION NAV: ❌ Error loading fridge list: $error 🔔🔔🔔',
          );
          // Try fetching directly from API as fallback
          Future.delayed(const Duration(milliseconds: 500), () async {
            if (!mounted) return;
            try {
              final fridgeAsync = await ref.read(
                singleFridgeProvider(fridgeId).future,
              );
              if (!mounted) return;
              logger.i(
                '🔔🔔🔔 NOTIFICATION NAV: ✅ Fetched fridge directly after error: ${fridgeAsync.name} 🔔🔔🔔',
              );
              final fridgeLocation = LatLng(
                fridgeAsync.location.geoLat,
                fridgeAsync.location.geoLng,
              );
              _mapController.move(fridgeLocation, 16.0);
              await Future.delayed(const Duration(milliseconds: 1000));
              if (!mounted) return;
              _showFridgeProfile(fridgeAsync);
              ref.read(notificationNavigationProvider.notifier).clear();
              logger.i('🔔🔔🔔 NOTIFICATION NAV: ✅ Complete! 🔔🔔🔔');
            } catch (fetchError) {
              logger.e(
                '🔔🔔🔔 NOTIFICATION NAV: ❌ Failed to fetch fridge: $fetchError 🔔🔔🔔',
              );
              ref.read(notificationNavigationProvider.notifier).clear();
            }
          });
        },
      );
    } finally {
      // Always clear the handling flag when done
      _handlingNotificationId = null;
    }
  }

  void _toggleSearchBar() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        // Auto-focus search bar when showing
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _searchFocusNode.requestFocus();
          }
        });
      } else {
        // Unfocus search bar when hiding
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    _log('🏗️ build: Starting build method');

    final fridgesAsync = ref.watch(fridgeListProvider);
    _log('📦 build: fridgeListProvider state = ${fridgesAsync.runtimeType}');

    final userLocationAsync = ref.watch(userLocationProvider);
    _log(
      '📍 build: userLocationProvider state = ${userLocationAsync.runtimeType}, hasValue = ${userLocationAsync.hasValue}',
    );

    // Note: userLocationStreamProvider is now watched only in the user location marker Consumer
    // This prevents unnecessary rebuilds of the entire map when location updates
    _log(
      '🌊 build: userLocationStream now watched only in Consumer (prevents full rebuilds)',
    );

    final locationAccessEnabled = ref.watch(locationAccessProvider);
    _log('🔐 build: locationAccessEnabled = $locationAccessEnabled');

    final filteredFridges = ref.watch(mapFilteredFridgesProvider);
    _log('🔍 build: filteredFridges count = ${filteredFridges.length}');

    // Auto-expand search bar when filter has a non-empty searchQuery (e.g. synced from list view)
    final filterStateAsync = ref.watch(mapFilterProvider);
    final currentSearchQuery = filterStateAsync.whenOrNull(data: (s) => s.searchQuery) ?? '';
    if (currentSearchQuery.isNotEmpty && !_isSearchVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isSearchVisible = true);
      });
    }
    // Sync search controller text with shared filter state
    if (_searchController.text != currentSearchQuery) {
      _searchController.value = TextEditingValue(
        text: currentSearchQuery,
        selection: TextSelection.collapsed(offset: currentSearchQuery.length),
      );
    }

    final subscriptionsAsync = ref.watch(subscribedFridgesProvider);
    _log(
      '⭐ build: subscribedFridgesProvider state = ${subscriptionsAsync.runtimeType}',
    );

    // Detect dark mode for theme-aware search bar background
    final themeMode = ref.watch(appThemeModeProvider);
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
    final searchBarBg = isDarkMode
        ? Colors.black.withValues(
            alpha: 0.7,
          ) // Dark mode: semi-transparent black
        : Colors.white.withValues(
            alpha: 0.9,
          ); // Light mode: semi-transparent white

    final router = GoRouter.of(context);
    final currentRoute = router.routerDelegate.currentConfiguration.uri
        .toString();
    _log('🛣️ build: currentRoute = $currentRoute');

    // Listen for notification navigation (must be in build method)
    // Note: Navigation to map is handled globally in app.dart
    // Here we just handle zooming and showing the sheet when on map screen
    ref.listen(notificationNavigationProvider, (previous, next) {
      if (next != null && mounted) {
        logger.i(
          '🔔🔔🔔 NOTIFICATION NAV: Map screen listener fired for fridge: $next 🔔🔔🔔',
        );
        _handleNotificationNavigation(next);
      }
    });

    // Also check if there's already a notification pending when screen builds
    final currentNotification = ref.read(notificationNavigationProvider);
    if (currentNotification != null && mounted) {
      logger.i(
        '🔔🔔🔔 NOTIFICATION NAV: Found pending notification on build: $currentNotification 🔔🔔🔔',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleNotificationNavigation(currentNotification);
        }
      });
    }

    return GestureDetector(
      onTap: () {
        // Unfocus any focused widget (search bar) when tapping on the map
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: fridgesAsync.when(
          loading: () {
            _log('⏳ fridgesAsync.when: LOADING state');
            return const common_widgets.LoadingIndicator();
          },
          error: (error, stackTrace) {
            _log('❌ fridgesAsync.when: ERROR state - $error');
            return common_widgets.ErrorView(
              message: error.toString(),
              onRetry: () => ref.refresh(fridgeListProvider),
            );
          },
          data: (fridges) {
            _log(
              '✅ fridgesAsync.when: DATA state - ${fridges.length} fridges loaded',
            );

            if (fridges.isEmpty) {
              _log(
                '⚠️ fridgesAsync.when: No fridges found, showing empty state',
              );
              return common_widgets.EmptyStateView(
                title: 'No Fridges Found',
                message: 'There are no community fridges in your area yet.',
                icon: Icons.location_off,
              );
            }

            // Determine initial map center: user location or first fridge
            LatLng initialCenter = LatLng(
              fridges[0].location.geoLat,
              fridges[0].location.geoLng,
            );
            _log(
              '📌 Initial center set to first fridge: (${fridges[0].location.geoLat}, ${fridges[0].location.geoLng})',
            );

            if (userLocationAsync.value != null) {
              initialCenter = userLocationAsync.value!.position;
              _log(
                '📍 Initial center updated to user location: (${initialCenter.latitude}, ${initialCenter.longitude})',
              );
            } else {
              _log(
                '📍 User location not available, using first fridge location',
              );
            }

            _log(
              '🗺️ Building FlutterMap widget with ${filteredFridges.length} markers',
            );
            _log(
              '🎯 Map options: center=(${initialCenter.latitude}, ${initialCenter.longitude}), zoom=13.0',
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _log(
                '✅ Widget tree built successfully - FlutterMap widget rendered',
              );
            });

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 13.0,
                    maxZoom: 18.0,
                    minZoom: 3.0,
                    interactionOptions: const InteractionOptions(
                      rotationThreshold: 40.0, // Increase from default (20) to reduce rotation sensitivity
                    ),
                    onTap: (tapPosition, latLng) {
                      // Unfocus search when tapping on the map
                      FocusScope.of(context).unfocus();
                    },
                    onMapEvent: (event) {
                      _log('🎪 MapEvent: ${event.runtimeType}');
                    },
                  ),
                  children: [
                    // Tile layer with caching
                    Consumer(
                      builder: (context, ref, child) {
                        _log('🧱 Building TileLayer');
                        // Use MapTiler Streets if API key is available, otherwise fallback to OpenStreetMap
                        final tileUrl =
                            MapConstants.getMapTilerStreetsUrl() ??
                            MapConstants.openStreetMapUrl;
                        final isMapTiler = tileUrl.contains('maptiler');
                        _log(
                          '🗺️ Using tile URL: ${isMapTiler ? 'MapTiler Streets' : 'OpenStreetMap'}',
                        );
                        // Note: Attribution is required by MapTiler and OpenStreetMap terms of service
                        // Attribution: © MapTiler © OpenStreetMap contributors (when using MapTiler)
                        // Attribution: © OpenStreetMap contributors (when using OpenStreetMap)

                        // Handle async tile provider (now using persistent Hive cache)
                        final tileProviderAsync = ref.watch(cachedTileProviderProvider);
                        return tileProviderAsync.when(
                          data: (tileProvider) => TileLayer(
                            urlTemplate: tileUrl,
                            userAgentPackageName: 'com.example.fridgefinder',
                            tileProvider: tileProvider,
                          ),
                          loading: () => TileLayer(
                            urlTemplate: tileUrl,
                            userAgentPackageName: 'com.example.fridgefinder',
                            // Use default NetworkTileProvider while cache initializes
                          ),
                          error: (error, stack) {
                            _log('❌ Error loading tile cache: $error');
                            return TileLayer(
                              urlTemplate: tileUrl,
                              userAgentPackageName: 'com.example.fridgefinder',
                              // Fallback to default NetworkTileProvider on error
                            );
                          },
                        );
                      },
                    ),
                    // User location marker with pulsating circle
                    // Wrapped in Consumer to isolate rebuilds - only this marker rebuilds on location updates
                    Consumer(
                      builder: (context, ref, child) {
                        final userLocationStream = ref.watch(userLocationStreamProvider);
                        return userLocationStream.when(
                          data: (userLocation) {
                            if (userLocation != null) {
                              _log(
                                '👤 Building user location marker at (${userLocation.position.latitude}, ${userLocation.position.longitude})',
                              );
                              return MarkerLayer(
                                markers: [
                                  Marker(
                                    point: userLocation.position,
                                    child: UserLocationIndicator(),
                                  ),
                                ],
                              );
                            }
                            _log('👤 User location is null, skipping marker');
                            return const SizedBox.shrink();
                          },
                          loading: () {
                            _log('👤 User location stream: LOADING');
                            return const SizedBox.shrink();
                          },
                          error: (error, _) {
                            _log('👤 User location stream: ERROR - $error');
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                    // Fridge markers with clustering - use filtered fridges
                    Builder(
                      builder: (context) {
                        _log(
                          '🏪 Building MarkerClusterLayer with ${filteredFridges.length} fridge markers',
                        );
                        return MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                            maxClusterRadius: 20,
                            size: const Size(50, 50),
                            markers: () {
                              // Create set of subscribed fridge IDs for O(1) lookup
                              final subscribedFridgeIds = subscriptionsAsync
                                  .when(
                                    data: (subscriptions) => subscriptions
                                        .map((s) => s.fridgeId)
                                        .toSet(),
                                    loading: () => <String>{},
                                    error: (_, _) => <String>{},
                                  );

                              return filteredFridges
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) {
                                      final index = entry.key;
                                      final fridge = entry.value;

                                      // Get or create GlobalKey for this fridge
                                      // GlobalKeys preserve widget state across parent rebuilds
                                      final markerKey = _markerKeys.putIfAbsent(
                                        fridge.id,
                                        () => GlobalKey<State<FridgeMarker>>(),
                                      );

                                      return Marker(
                                        point: LatLng(
                                          fridge.location.geoLat,
                                          fridge.location.geoLng,
                                        ),
                                        width: FridgeMarker.markerSize,
                                        height: FridgeMarker.markerSize,
                                        child: FridgeMarker(
                                          key: markerKey,
                                          fridge: fridge,
                                          isSubscribed: subscribedFridgeIds
                                              .contains(fridge.id),
                                          animationIndex: index,
                                        ),
                                      );
                                    },
                                  )
                                  .toList();
                            }(),
                            builder: (context, markers) {
                              return FridgeClusterWidget(
                                markerCount: markers.length,
                                isDarkMode:
                                    Theme.of(context).brightness ==
                                    Brightness.dark,
                              );
                            },
                            onMarkerTap: (marker) {
                              // Find the fridge corresponding to this marker
                              final markerPoint = marker.point;
                              final fridge = filteredFridges.firstWhere(
                                (fridge) =>
                                    fridge.location.geoLat ==
                                        markerPoint.latitude &&
                                    fridge.location.geoLng ==
                                        markerPoint.longitude,
                              );
                              _showFridgeProfile(fridge);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Always-visible filter pills at top of map
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const FilterPillsRow(),
                  ),
                ),
                // Search bar - overlays above map, below filter pills
                // Animated visibility with M3E motion
                Positioned(
                  top: 64, // Below the filter pills row (height 48)
                  left: M3ESpacing.md,
                  right: M3ESpacing.md,
                  child: AnimatedContainer(
                    duration: M3EMotion.medium3, // 350ms M3E duration
                    curve: _isSearchVisible
                        ? M3EMotion
                              .emphasizedDecelerate // Expanding
                        : M3EMotion.emphasizedAccelerate, // Collapsing
                    height: _isSearchVisible ? 64.0 : 0.0, // Animate height
                    child: _isSearchVisible
                        ? Padding(
                            padding: const EdgeInsets.only(
                              bottom: M3ESpacing.xs,
                            ),
                            child: SearchBarM3E(
                              controller: _searchController,
                              hintText: 'Search by name, address, or zip...',
                              leadingIcon: Icons.search,
                              expandedByDefault: false,
                              backgroundColor:
                                  searchBarBg, // Theme-aware background
                              onChanged: (query) {
                                ref
                                    .read(mapFilterProvider.notifier)
                                    .setSearchQuery(query);
                              },
                              onSubmitted: (_) => FocusScope.of(context).unfocus(),
                            ),
                          )
                        : const SizedBox.shrink(), // Hidden state
                  ),
                ),
                // Center to user location button (above search button)
                Positioned(
                  bottom: 80,
                  right: 16,
                  child: FABM3E(
                    icon: Icons.my_location,
                    tooltip: 'Center on my location',
                    onPressed: () async {
                      // If location access is disabled, request permission first
                      if (!locationAccessEnabled) {
                        final result = await ref
                            .read(locationAccessProvider.notifier)
                            .setAccessWithPermission(true);

                        if (result['success'] != true) {
                          if (context.mounted) {
                            if (result['openSettings'] == true) {
                              // Guide user to settings
                              final shouldOpenSettings = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    'Location Permission Required',
                                  ),
                                  content: const Text(
                                    'Location access is disabled. '
                                    'Please enable it in Settings to center the map on your location.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Open Settings'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldOpenSettings == true) {
                                await openAppSettings();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Location permission denied. Enable in settings to use this feature.',
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                          return;
                        }
                        // Permission granted and toggle turned on
                        // Wait for location data to be fetched
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Getting your location...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        // Give the location provider time to fetch the location
                        // Check periodically for up to 5 seconds
                        int attempts = 0;
                        while (attempts < 10) {
                          await Future.delayed(
                            const Duration(milliseconds: 500),
                          );

                          // Re-read the latest location state
                          final updatedLocation = ref
                              .read(userLocationProvider)
                              .whenOrNull(data: (location) => location);

                          if (updatedLocation != null) {
                            if (context.mounted) {
                              _mapController.move(
                                updatedLocation.position,
                                15.0,
                              );
                            }
                            return;
                          }
                          attempts++;
                        }

                        // Location still not available after 5 seconds
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to get location. Please try again.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        return;
                      }

                      // Location access already enabled - center map to user location if available
                      if (userLocationAsync.value != null) {
                        _mapController.move(
                          userLocationAsync.value!.position,
                          15.0,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Getting your location...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                // Filter status indicator at bottom left
                const FilterStatusIndicator(),
                // Search toggle button in bottom right
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    foregroundColor: Colors.white,
                    onPressed: _toggleSearchBar,
                    child: AnimatedSwitcher(
                      duration: M3EMotion.medium3,
                      switchInCurve: M3EMotion.emphasizedDecelerate,
                      switchOutCurve: M3EMotion.emphasizedAccelerate,
                      transitionBuilder: (child, animation) {
                        // M3E shape morph: scale + fade + rotation
                        return ScaleTransition(
                          scale: animation,
                          child: RotationTransition(
                            turns: Tween<double>(
                              begin: 0.125,
                              end: 0.0,
                            ).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        _isSearchVisible ? Icons.arrow_downward : Icons.search,
                        key: ValueKey(_isSearchVisible),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _log('🔄 didUpdateWidget: Widget updated');
  }
}
