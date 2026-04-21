// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vector_tile_style_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that loads a bundled Protomaps v3 theme (compatible with
/// vector_tile_renderer v6) and wires it to the Protomaps hosted tile API.
/// Rebuilds when app theme changes (light/dark).

@ProviderFor(vectorTileStyle)
const vectorTileStyleProvider = VectorTileStyleProvider._();

/// Provider that loads a bundled Protomaps v3 theme (compatible with
/// vector_tile_renderer v6) and wires it to the Protomaps hosted tile API.
/// Rebuilds when app theme changes (light/dark).

final class VectorTileStyleProvider
    extends $FunctionalProvider<AsyncValue<Style>, Style, FutureOr<Style>>
    with $FutureModifier<Style>, $FutureProvider<Style> {
  /// Provider that loads a bundled Protomaps v3 theme (compatible with
  /// vector_tile_renderer v6) and wires it to the Protomaps hosted tile API.
  /// Rebuilds when app theme changes (light/dark).
  const VectorTileStyleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vectorTileStyleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vectorTileStyleHash();

  @$internal
  @override
  $FutureProviderElement<Style> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Style> create(Ref ref) {
    return vectorTileStyle(ref);
  }
}

String _$vectorTileStyleHash() => r'e3f36e169139dc9b37b1080b436799cca6605378';
