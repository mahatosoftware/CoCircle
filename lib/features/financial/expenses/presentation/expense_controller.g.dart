// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExpenseController)
final expenseControllerProvider = ExpenseControllerProvider._();

final class ExpenseControllerProvider
    extends $AsyncNotifierProvider<ExpenseController, void> {
  ExpenseControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseControllerHash();

  @$internal
  @override
  ExpenseController create() => ExpenseController();
}

String _$expenseControllerHash() => r'27ed820b519ce9964b3cf4d705e24473ca0b4259';

abstract class _$ExpenseController extends $AsyncNotifier<void> {
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

@ProviderFor(tripExpenses)
final tripExpensesProvider = TripExpensesFamily._();

final class TripExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExpenseModel>>,
          List<ExpenseModel>,
          Stream<List<ExpenseModel>>
        >
    with
        $FutureModifier<List<ExpenseModel>>,
        $StreamProvider<List<ExpenseModel>> {
  TripExpensesProvider._({
    required TripExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripExpensesHash();

  @override
  String toString() {
    return r'tripExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ExpenseModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ExpenseModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripExpensesHash() => r'303d288b5411015ccfa11ad1bc7338300f7e4ebd';

final class TripExpensesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ExpenseModel>>, String> {
  TripExpensesFamily._()
    : super(
        retry: null,
        name: r'tripExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripExpensesProvider call(String tripId) =>
      TripExpensesProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripExpensesProvider';
}

@ProviderFor(expenseDetail)
final expenseDetailProvider = ExpenseDetailFamily._();

final class ExpenseDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExpenseModel>,
          ExpenseModel,
          FutureOr<ExpenseModel>
        >
    with $FutureModifier<ExpenseModel>, $FutureProvider<ExpenseModel> {
  ExpenseDetailProvider._({
    required ExpenseDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseDetailHash();

  @override
  String toString() {
    return r'expenseDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ExpenseModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExpenseModel> create(Ref ref) {
    final argument = this.argument as String;
    return expenseDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseDetailHash() => r'14bf662440707b6296a07e75aa61dc9f24439ff4';

final class ExpenseDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ExpenseModel>, String> {
  ExpenseDetailFamily._()
    : super(
        retry: null,
        name: r'expenseDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseDetailProvider call(String expenseId) =>
      ExpenseDetailProvider._(argument: expenseId, from: this);

  @override
  String toString() => r'expenseDetailProvider';
}
