// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CircleController)
final circleControllerProvider = CircleControllerProvider._();

final class CircleControllerProvider
    extends $AsyncNotifierProvider<CircleController, void> {
  CircleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'circleControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$circleControllerHash();

  @$internal
  @override
  CircleController create() => CircleController();
}

String _$circleControllerHash() => r'ff4ce7ec2f6e02448f528ddca103c67794ea02cb';

abstract class _$CircleController extends $AsyncNotifier<void> {
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

@ProviderFor(userCircles)
final userCirclesProvider = UserCirclesProvider._();

final class UserCirclesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CircleModel>>,
          List<CircleModel>,
          Stream<List<CircleModel>>
        >
    with
        $FutureModifier<List<CircleModel>>,
        $StreamProvider<List<CircleModel>> {
  UserCirclesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userCirclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userCirclesHash();

  @$internal
  @override
  $StreamProviderElement<List<CircleModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CircleModel>> create(Ref ref) {
    return userCircles(ref);
  }
}

String _$userCirclesHash() => r'2e072d8410a32c7f92c98e46f71299ad54c7c2b2';

@ProviderFor(circleDetails)
final circleDetailsProvider = CircleDetailsFamily._();

final class CircleDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CircleModel>,
          CircleModel,
          Stream<CircleModel>
        >
    with $FutureModifier<CircleModel>, $StreamProvider<CircleModel> {
  CircleDetailsProvider._({
    required CircleDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'circleDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$circleDetailsHash();

  @override
  String toString() {
    return r'circleDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<CircleModel> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CircleModel> create(Ref ref) {
    final argument = this.argument as String;
    return circleDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CircleDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$circleDetailsHash() => r'0b6573d28d896ab175a9dfa48900533d810648bc';

final class CircleDetailsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<CircleModel>, String> {
  CircleDetailsFamily._()
    : super(
        retry: null,
        name: r'circleDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CircleDetailsProvider call(String circleId) =>
      CircleDetailsProvider._(argument: circleId, from: this);

  @override
  String toString() => r'circleDetailsProvider';
}

@ProviderFor(circleMembers)
final circleMembersProvider = CircleMembersFamily._();

final class CircleMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  CircleMembersProvider._({
    required CircleMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'circleMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$circleMembersHash();

  @override
  String toString() {
    return r'circleMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return circleMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CircleMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$circleMembersHash() => r'67d0c07c6068cb23aff97e8191742598e4932c79';

final class CircleMembersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  CircleMembersFamily._()
    : super(
        retry: null,
        name: r'circleMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CircleMembersProvider call(String circleId) =>
      CircleMembersProvider._(argument: circleId, from: this);

  @override
  String toString() => r'circleMembersProvider';
}
