// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_map_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveMapController)
final liveMapControllerProvider = LiveMapControllerFamily._();

final class LiveMapControllerProvider
    extends $NotifierProvider<LiveMapController, LiveMapState> {
  LiveMapControllerProvider._({
    required LiveMapControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveMapControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveMapControllerHash();

  @override
  String toString() {
    return r'liveMapControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveMapController create() => LiveMapController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveMapState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveMapState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveMapControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveMapControllerHash() => r'b37a787395cc6cf328d1ff7beccf9c4d7133778e';

final class LiveMapControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveMapController,
          LiveMapState,
          LiveMapState,
          LiveMapState,
          String
        > {
  LiveMapControllerFamily._()
    : super(
        retry: null,
        name: r'liveMapControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LiveMapControllerProvider call(String tripId) =>
      LiveMapControllerProvider._(argument: tripId, from: this);

  @override
  String toString() => r'liveMapControllerProvider';
}

abstract class _$LiveMapController extends $Notifier<LiveMapState> {
  late final _$args = ref.$arg as String;
  String get tripId => _$args;

  LiveMapState build(String tripId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LiveMapState, LiveMapState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveMapState, LiveMapState>,
              LiveMapState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
