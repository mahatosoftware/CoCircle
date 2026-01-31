// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(circleRepository)
final circleRepositoryProvider = CircleRepositoryProvider._();

final class CircleRepositoryProvider
    extends
        $FunctionalProvider<
          CircleRepository,
          CircleRepository,
          CircleRepository
        >
    with $Provider<CircleRepository> {
  CircleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'circleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$circleRepositoryHash();

  @$internal
  @override
  $ProviderElement<CircleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CircleRepository create(Ref ref) {
    return circleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CircleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CircleRepository>(value),
    );
  }
}

String _$circleRepositoryHash() => r'3ed95a2b2483f2ec6972200cf328dae475e9c4f0';
