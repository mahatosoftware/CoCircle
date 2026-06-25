// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_planner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TripPlannerController)
final tripPlannerControllerProvider = TripPlannerControllerProvider._();

final class TripPlannerControllerProvider
    extends $AsyncNotifierProvider<TripPlannerController, void> {
  TripPlannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tripPlannerControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tripPlannerControllerHash();

  @$internal
  @override
  TripPlannerController create() => TripPlannerController();
}

String _$tripPlannerControllerHash() =>
    r'ad1bf98c41db4686250a8feb7f41f2bb01a367ac';

abstract class _$TripPlannerController extends $AsyncNotifier<void> {
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

@ProviderFor(tripItinerary)
final tripItineraryProvider = TripItineraryFamily._();

final class TripItineraryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ItineraryItemModel>>,
          List<ItineraryItemModel>,
          Stream<List<ItineraryItemModel>>
        >
    with
        $FutureModifier<List<ItineraryItemModel>>,
        $StreamProvider<List<ItineraryItemModel>> {
  TripItineraryProvider._({
    required TripItineraryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripItineraryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripItineraryHash();

  @override
  String toString() {
    return r'tripItineraryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ItineraryItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ItineraryItemModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripItinerary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripItineraryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripItineraryHash() => r'6e2e4c0d586a773d7bd1dd5804dc5004341dfce7';

final class TripItineraryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ItineraryItemModel>>, String> {
  TripItineraryFamily._()
    : super(
        retry: null,
        name: r'tripItineraryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripItineraryProvider call(String tripId) =>
      TripItineraryProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripItineraryProvider';
}

@ProviderFor(tripLodging)
final tripLodgingProvider = TripLodgingFamily._();

final class TripLodgingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LodgingModel>>,
          List<LodgingModel>,
          Stream<List<LodgingModel>>
        >
    with
        $FutureModifier<List<LodgingModel>>,
        $StreamProvider<List<LodgingModel>> {
  TripLodgingProvider._({
    required TripLodgingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripLodgingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripLodgingHash();

  @override
  String toString() {
    return r'tripLodgingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LodgingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LodgingModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripLodging(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripLodgingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripLodgingHash() => r'4ad8284101fd63c74ff8d1b9325af959d6eeb820';

final class TripLodgingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LodgingModel>>, String> {
  TripLodgingFamily._()
    : super(
        retry: null,
        name: r'tripLodgingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripLodgingProvider call(String tripId) =>
      TripLodgingProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripLodgingProvider';
}

@ProviderFor(tripIdeas)
final tripIdeasProvider = TripIdeasFamily._();

final class TripIdeasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<IdeaModel>>,
          List<IdeaModel>,
          Stream<List<IdeaModel>>
        >
    with $FutureModifier<List<IdeaModel>>, $StreamProvider<List<IdeaModel>> {
  TripIdeasProvider._({
    required TripIdeasFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripIdeasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripIdeasHash();

  @override
  String toString() {
    return r'tripIdeasProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<IdeaModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<IdeaModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripIdeas(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripIdeasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripIdeasHash() => r'f138e30b651a14637ade66ee3294f84e17b5c638';

final class TripIdeasFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<IdeaModel>>, String> {
  TripIdeasFamily._()
    : super(
        retry: null,
        name: r'tripIdeasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripIdeasProvider call(String tripId) =>
      TripIdeasProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripIdeasProvider';
}

@ProviderFor(tripPacking)
final tripPackingProvider = TripPackingFamily._();

final class TripPackingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PackingItemModel>>,
          List<PackingItemModel>,
          Stream<List<PackingItemModel>>
        >
    with
        $FutureModifier<List<PackingItemModel>>,
        $StreamProvider<List<PackingItemModel>> {
  TripPackingProvider._({
    required TripPackingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripPackingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripPackingHash();

  @override
  String toString() {
    return r'tripPackingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PackingItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PackingItemModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripPacking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripPackingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripPackingHash() => r'4883fc3a6ef3a0aef850c16a224a71e22ffa551a';

final class TripPackingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PackingItemModel>>, String> {
  TripPackingFamily._()
    : super(
        retry: null,
        name: r'tripPackingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripPackingProvider call(String tripId) =>
      TripPackingProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripPackingProvider';
}
