// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settlementRepository)
final settlementRepositoryProvider = SettlementRepositoryProvider._();

final class SettlementRepositoryProvider
    extends
        $FunctionalProvider<
          SettlementRepository,
          SettlementRepository,
          SettlementRepository
        >
    with $Provider<SettlementRepository> {
  SettlementRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settlementRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settlementRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettlementRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettlementRepository create(Ref ref) {
    return settlementRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettlementRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettlementRepository>(value),
    );
  }
}

String _$settlementRepositoryHash() =>
    r'd439a5ec9f8559d2e2f801fdac24e0d24bcadb23';
