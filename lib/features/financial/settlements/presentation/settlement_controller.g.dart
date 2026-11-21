// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SettlementController)
final settlementControllerProvider = SettlementControllerProvider._();

final class SettlementControllerProvider
    extends $AsyncNotifierProvider<SettlementController, void> {
  SettlementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settlementControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settlementControllerHash();

  @$internal
  @override
  SettlementController create() => SettlementController();
}

String _$settlementControllerHash() =>
    r'db98367d5b67091a1854c84a398281f5b91a7a48';

abstract class _$SettlementController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(activeSettlements)
final activeSettlementsProvider = ActiveSettlementsFamily._();

final class ActiveSettlementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SettlementTransaction>>,
          List<SettlementTransaction>,
          FutureOr<List<SettlementTransaction>>
        >
    with
        $FutureModifier<List<SettlementTransaction>>,
        $FutureProvider<List<SettlementTransaction>> {
  ActiveSettlementsProvider._({
    required ActiveSettlementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeSettlementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeSettlementsHash();

  @override
  String toString() {
    return r'activeSettlementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SettlementTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SettlementTransaction>> create(Ref ref) {
    final argument = this.argument as String;
    return activeSettlements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveSettlementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeSettlementsHash() => r'6438e450932a7c3f685de7d1eb8244b693ddf04c';

final class ActiveSettlementsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SettlementTransaction>>,
          String
        > {
  ActiveSettlementsFamily._()
    : super(
        retry: null,
        name: r'activeSettlementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ActiveSettlementsProvider call(String tripId) =>
      ActiveSettlementsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'activeSettlementsProvider';
}

@ProviderFor(tripAdjustments)
final tripAdjustmentsProvider = TripAdjustmentsFamily._();

final class TripAdjustmentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SettlementAdjustmentModel>>,
          List<SettlementAdjustmentModel>,
          Stream<List<SettlementAdjustmentModel>>
        >
    with
        $FutureModifier<List<SettlementAdjustmentModel>>,
        $StreamProvider<List<SettlementAdjustmentModel>> {
  TripAdjustmentsProvider._({
    required TripAdjustmentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripAdjustmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripAdjustmentsHash();

  @override
  String toString() {
    return r'tripAdjustmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SettlementAdjustmentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SettlementAdjustmentModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripAdjustments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripAdjustmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripAdjustmentsHash() => r'98611604d0a0d194ba0644659d15f10badc23958';

final class TripAdjustmentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<SettlementAdjustmentModel>>,
          String
        > {
  TripAdjustmentsFamily._()
    : super(
        retry: null,
        name: r'tripAdjustmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripAdjustmentsProvider call(String tripId) =>
      TripAdjustmentsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripAdjustmentsProvider';
}

@ProviderFor(tripSettlements)
final tripSettlementsProvider = TripSettlementsFamily._();

final class TripSettlementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SettlementModel>>,
          List<SettlementModel>,
          Stream<List<SettlementModel>>
        >
    with
        $FutureModifier<List<SettlementModel>>,
        $StreamProvider<List<SettlementModel>> {
  TripSettlementsProvider._({
    required TripSettlementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripSettlementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripSettlementsHash();

  @override
  String toString() {
    return r'tripSettlementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SettlementModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SettlementModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripSettlements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripSettlementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripSettlementsHash() => r'bdce524aef25721f07aad7db1364a69a9b8ffac3';

final class TripSettlementsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SettlementModel>>, String> {
  TripSettlementsFamily._()
    : super(
        retry: null,
        name: r'tripSettlementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripSettlementsProvider call(String tripId) =>
      TripSettlementsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripSettlementsProvider';
}
