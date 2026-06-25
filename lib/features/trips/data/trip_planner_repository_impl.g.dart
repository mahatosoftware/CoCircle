// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_planner_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tripPlannerRepository)
final tripPlannerRepositoryProvider = TripPlannerRepositoryProvider._();

final class TripPlannerRepositoryProvider
    extends
        $FunctionalProvider<
          TripPlannerRepository,
          TripPlannerRepository,
          TripPlannerRepository
        >
    with $Provider<TripPlannerRepository> {
  TripPlannerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripPlannerRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripPlannerRepositoryHash();

  @$internal
  @override
  $ProviderElement<TripPlannerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TripPlannerRepository create(Ref ref) {
    return tripPlannerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TripPlannerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TripPlannerRepository>(value),
    );
  }
}

String _$tripPlannerRepositoryHash() =>
    r'0b82640567e67d0f76f1b4e835b7d3515afd6970';
