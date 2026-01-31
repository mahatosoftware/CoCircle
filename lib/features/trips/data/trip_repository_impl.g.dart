// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tripRepository)
final tripRepositoryProvider = TripRepositoryProvider._();

final class TripRepositoryProvider
    extends $FunctionalProvider<TripRepository, TripRepository, TripRepository>
    with $Provider<TripRepository> {
  TripRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TripRepository create(Ref ref) {
    return tripRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripRepository>(value),
    );
  }
}

String _$tripRepositoryHash() => r'5820818b107600e3bc33fcdc8d56e30e195f9fd7';
