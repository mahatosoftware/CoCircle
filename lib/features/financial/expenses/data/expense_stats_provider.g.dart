// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseCategoryStats)
final expenseCategoryStatsProvider = ExpenseCategoryStatsFamily._();

final class ExpenseCategoryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<ExpenseCategory, double>>,
          Map<ExpenseCategory, double>,
          Stream<Map<ExpenseCategory, double>>
        >
    with
        $FutureModifier<Map<ExpenseCategory, double>>,
        $StreamProvider<Map<ExpenseCategory, double>> {
  ExpenseCategoryStatsProvider._({
    required ExpenseCategoryStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseCategoryStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseCategoryStatsHash();

  @override
  String toString() {
    return r'expenseCategoryStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<ExpenseCategory, double>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<ExpenseCategory, double>> create(Ref ref) {
    final argument = this.argument as String;
    return expenseCategoryStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseCategoryStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseCategoryStatsHash() =>
    r'7e1c59d66a3ebda6e85916b5b4a8ddee0d604633';

final class ExpenseCategoryStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<Map<ExpenseCategory, double>>,
          String
        > {
  ExpenseCategoryStatsFamily._()
    : super(
        retry: null,
        name: r'expenseCategoryStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseCategoryStatsProvider call(String tripId) =>
      ExpenseCategoryStatsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'expenseCategoryStatsProvider';
}

@ProviderFor(expenseMemberStats)
final expenseMemberStatsProvider = ExpenseMemberStatsFamily._();

final class ExpenseMemberStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          Stream<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $StreamProvider<Map<String, double>> {
  ExpenseMemberStatsProvider._({
    required ExpenseMemberStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseMemberStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseMemberStatsHash();

  @override
  String toString() {
    return r'expenseMemberStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, double>> create(Ref ref) {
    final argument = this.argument as String;
    return expenseMemberStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseMemberStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseMemberStatsHash() =>
    r'4eae2d73432a11c2e7ecd49192f57270921a2503';

final class ExpenseMemberStatsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, double>>, String> {
  ExpenseMemberStatsFamily._()
    : super(
        retry: null,
        name: r'expenseMemberStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseMemberStatsProvider call(String tripId) =>
      ExpenseMemberStatsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'expenseMemberStatsProvider';
}

@ProviderFor(expenseMemberShare)
final expenseMemberShareProvider = ExpenseMemberShareFamily._();

final class ExpenseMemberShareProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          Stream<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $StreamProvider<Map<String, double>> {
  ExpenseMemberShareProvider._({
    required ExpenseMemberShareFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expenseMemberShareProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expenseMemberShareHash();

  @override
  String toString() {
    return r'expenseMemberShareProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, double>> create(Ref ref) {
    final argument = this.argument as String;
    return expenseMemberShare(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpenseMemberShareProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expenseMemberShareHash() =>
    r'9fe67da6ab845e357187bb5732abc189eaf9b2a6';

final class ExpenseMemberShareFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, double>>, String> {
  ExpenseMemberShareFamily._()
    : super(
        retry: null,
        name: r'expenseMemberShareProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ExpenseMemberShareProvider call(String tripId) =>
      ExpenseMemberShareProvider._(argument: tripId, from: this);

  @override
  String toString() => r'expenseMemberShareProvider';
}

@ProviderFor(tripTotalSpending)
final tripTotalSpendingProvider = TripTotalSpendingFamily._();

final class TripTotalSpendingProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  TripTotalSpendingProvider._({
    required TripTotalSpendingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripTotalSpendingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripTotalSpendingHash();

  @override
  String toString() {
    return r'tripTotalSpendingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    final argument = this.argument as String;
    return tripTotalSpending(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripTotalSpendingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripTotalSpendingHash() => r'fc478f6d847013d69344dc38271e093fea90b61c';

final class TripTotalSpendingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<double>, String> {
  TripTotalSpendingFamily._()
    : super(
        retry: null,
        name: r'tripTotalSpendingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripTotalSpendingProvider call(String tripId) =>
      TripTotalSpendingProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripTotalSpendingProvider';
}
