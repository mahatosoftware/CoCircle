// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_tracking_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveTrackingRepository)
final liveTrackingRepositoryProvider = LiveTrackingRepositoryProvider._();

final class LiveTrackingRepositoryProvider
    extends
        $FunctionalProvider<
          LiveTrackingRepository,
          LiveTrackingRepository,
          LiveTrackingRepository
        >
    with $Provider<LiveTrackingRepository> {
  LiveTrackingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveTrackingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveTrackingRepositoryHash();

  @$internal
  @override
  $ProviderElement<LiveTrackingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveTrackingRepository create(Ref ref) {
    return liveTrackingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveTrackingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveTrackingRepository>(value),
    );
  }
}

String _$liveTrackingRepositoryHash() =>
    r'76ee106d8b8b9dca9cc4a5fee196e71f754e7431';
