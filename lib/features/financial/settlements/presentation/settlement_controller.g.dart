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
    r'b5ab192070ec8f82438632045d35eb8bc5109c92';

abstract class _$SettlementController extends $AsyncNotifier<void> {
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

String _$activeSettlementsHash() => r'52278fe84cf79c2a1eb4553de042d70bb105d8d8';

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
