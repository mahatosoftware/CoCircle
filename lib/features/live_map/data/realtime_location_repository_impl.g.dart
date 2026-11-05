// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_location_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(realtimeLocationRepository)
final realtimeLocationRepositoryProvider =
    RealtimeLocationRepositoryProvider._();

final class RealtimeLocationRepositoryProvider
    extends
        $FunctionalProvider<
          RealtimeLocationRepository,
          RealtimeLocationRepository,
          RealtimeLocationRepository
        >
    with $Provider<RealtimeLocationRepository> {
  RealtimeLocationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeLocationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeLocationRepositoryHash();

  @$internal
  @override
  $ProviderElement<RealtimeLocationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RealtimeLocationRepository create(Ref ref) {
    return realtimeLocationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeLocationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeLocationRepository>(value),
    );
  }
}

String _$realtimeLocationRepositoryHash() =>
    r'1916e167fdcbe16f450e7f41cb558130ad0d613a';
