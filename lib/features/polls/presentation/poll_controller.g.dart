// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PollController)
final pollControllerProvider = PollControllerProvider._();

final class PollControllerProvider
    extends $AsyncNotifierProvider<PollController, void> {
  PollControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pollControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pollControllerHash();

  @$internal
  @override
  PollController create() => PollController();
}

String _$pollControllerHash() => r'7b4eb08e3e54349a14f94cc4dee52fb68b94127e';

abstract class _$PollController extends $AsyncNotifier<void> {
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

@ProviderFor(tripPolls)
final tripPollsProvider = TripPollsFamily._();

final class TripPollsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PollModel>>,
          List<PollModel>,
          Stream<List<PollModel>>
        >
    with $FutureModifier<List<PollModel>>, $StreamProvider<List<PollModel>> {
  TripPollsProvider._({
    required TripPollsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tripPollsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tripPollsHash();

  @override
  String toString() {
    return r'tripPollsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<PollModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PollModel>> create(Ref ref) {
    final argument = this.argument as String;
    return tripPolls(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TripPollsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tripPollsHash() => r'05d04c364f9b9e436799316fad696ae1415a00bf';

final class TripPollsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<PollModel>>, String> {
  TripPollsFamily._()
    : super(
        retry: null,
        name: r'tripPollsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TripPollsProvider call(String tripId) =>
      TripPollsProvider._(argument: tripId, from: this);

  @override
  String toString() => r'tripPollsProvider';
}
