// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripController)
final tripControllerProvider = TripControllerProvider._();

final class TripControllerProvider
    extends $AsyncNotifierProvider<TripController, void> {
  TripControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripControllerHash();

  @$internal
  @override
  TripController create() => TripController();
}

String _$tripControllerHash() => r'8a72dc3799a7b0f3075e27764a72328531431dc7';

abstract class _$TripController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(circleTrips)
final circleTripsProvider = CircleTripsFamily._();

final class CircleTripsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TripModel>>,
          List<TripModel>,
          Stream<List<TripModel>>
        >
    with $FutureModifier<List<TripModel>>, $StreamProvider<List<TripModel>> {
  CircleTripsProvider._({
    required CircleTripsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'circleTripsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$circleTripsHash();

  @override
  String toString() {
    return r'circleTripsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TripModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TripModel>> create(Ref ref) {
    final argument = this.argument as String;
    return circleTrips(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CircleTripsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$circleTripsHash() => r'a0ef4bd5e37e1412e92aec817601b70faba058c3';

final class CircleTripsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TripModel>>, String> {
  CircleTripsFamily._()
    : super(
        retry: null,
        name: r'circleTripsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CircleTripsProvider call(String circleId) =>
      CircleTripsProvider._(argument: circleId, from: this);

  @override
  String toString() => r'circleTripsProvider';
}

@ProviderFor(tripDetails)
final tripDetailsProvider = TripDetailsFamily._();

final class TripDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TripModel>,
          TripModel,
          FutureOr<TripModel>
        >
    with $FutureModifier<TripModel>, $FutureProvider<TripModel> {
  TripDetailsProvider._({
    required TripDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripDetailsHash();

  @override
  String toString() {
    return r'tripDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<TripModel> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<TripModel> create(Ref ref) {
    final argument = this.argument as String;
    return tripDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripDetailsHash() => r'f9c890b48aad90510d3c71022c3217f79c522d55';

final class TripDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TripModel>, String> {
  TripDetailsFamily._()
    : super(
        retry: null,
        name: r'tripDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripDetailsProvider call(String tripId) =>
      TripDetailsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripDetailsProvider';
}
