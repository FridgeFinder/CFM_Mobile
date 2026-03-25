import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fridgefinder_app/src/core/services/neighborhood_service.dart';

/// Mock Dio adapter that returns canned JSON responses.
class MockAdapter implements HttpClientAdapter {
  final Map<String, dynamic>? responseData;
  final DioException? error;
  int callCount = 0;

  MockAdapter({this.responseData, this.error});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    if (error != null) throw error!;

    final jsonBytes = utf8.encode(jsonEncode(responseData ?? {}));
    return ResponseBody.fromBytes(
      jsonBytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  Dio createDio(MockAdapter adapter) {
    final dio = Dio();
    dio.httpClientAdapter = adapter;
    return dio;
  }

  test('returns cached value without API call', () async {
    final box = await Hive.openBox<String>('neighborhood_cache_v2');
    await box.put('fridge-1', 'Bushwick');
    await box.close();

    final adapter = MockAdapter();
    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-1',
      lat: 40.0,
      lng: -73.0,
    );

    expect(result, 'Bushwick');
    expect(adapter.callCount, 0);
  });

  test('calls API on cache miss and caches result', () async {
    final adapter = MockAdapter(responseData: {
      'features': [
        {
          'text': 'Williamsburg',
          'place_type': ['neighbourhood'],
        },
      ],
    });

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-2',
      lat: 40.0,
      lng: -73.0,
    );

    expect(result, 'Williamsburg');
    expect(adapter.callCount, 1);

    // Verify it was cached
    final box = await Hive.openBox<String>('neighborhood_cache_v2');
    expect(box.get('fridge-2'), 'Williamsburg');
  });

  test('falls back to locationName when API fails', () async {
    final adapter = MockAdapter(
      error: DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-3',
      lat: 40.0,
      lng: -73.0,
      locationName: 'Downtown Brooklyn',
    );

    expect(result, 'Downtown Brooklyn');
  });

  test('falls back to city when locationName is null and API fails', () async {
    final adapter = MockAdapter(
      error: DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-4',
      lat: 40.0,
      lng: -73.0,
      city: 'New York',
    );

    expect(result, 'New York');
  });

  test('falls back when features array is empty', () async {
    final adapter = MockAdapter(responseData: {
      'features': <Map<String, dynamic>>[],
    });

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-5',
      lat: 40.0,
      lng: -73.0,
      locationName: 'Red Hook',
    );

    expect(result, 'Red Hook');
  });

  test('prefers neighbourhood over joint_municipality', () async {
    final adapter = MockAdapter(responseData: {
      'features': [
        {
          'text': 'Eastern Parkway',
          'place_type': ['address'],
        },
        {
          'text': 'Brooklyn',
          'place_type': ['joint_municipality'],
        },
        {
          'text': 'Crown Heights',
          'place_type': ['neighbourhood'],
        },
        {
          'text': 'New York',
          'place_type': ['region'],
        },
      ],
    });

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-priority',
      lat: 40.0,
      lng: -73.0,
    );

    expect(result, 'Crown Heights');
  });

  test('picks joint_municipality when no neighbourhood exists', () async {
    final adapter = MockAdapter(responseData: {
      'features': [
        {
          'text': 'Eastern Parkway',
          'place_type': ['address'],
        },
        {
          'text': 'Brooklyn',
          'place_type': ['joint_municipality'],
        },
        {
          'text': 'New York',
          'place_type': ['region'],
        },
      ],
    });

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    final result = await service.getNeighborhood(
      fridgeId: 'fridge-jm',
      lat: 40.0,
      lng: -73.0,
    );

    expect(result, 'Brooklyn');
  });

  test('returns empty string when all fallbacks are empty', () async {
    final adapter = MockAdapter(
      error: DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final service = NeighborhoodService(
      dio: createDio(adapter),
      apiKey: 'test-key',
    );

    // No locationName, empty city (default) — returns empty string
    final result = await service.getNeighborhood(
      fridgeId: 'fridge-6',
      lat: 40.0,
      lng: -73.0,
    );

    expect(result, '');
  });
}
