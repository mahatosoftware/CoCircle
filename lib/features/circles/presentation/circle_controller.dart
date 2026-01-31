import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/circle_repository_impl.dart';
import '../domain/circle_model.dart';

part 'circle_controller.g.dart';

@riverpod
class CircleController extends _$CircleController {
  @override
  FutureOr<void> build() {
    // Initial state is idle
  }

  Future<void> createCircle({
    required String name,
    required String description,
    required String currency,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final result = await ref.read(circleRepositoryProvider).createCircle(
      name: name,
      description: description,
      currency: currency,
      userId: user.uid,
    );

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (circle) {
        state = const AsyncData(null);
        showSnackBar(context, 'Circle created successfully!');
        ref.invalidate(userCirclesProvider);
        context.pop(); // Go back to finding/my circles
      },
    );
  }

  Future<void> joinCircleByCode({required String code, required BuildContext context}) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    // 1. Find circle by code
    final circleRes = await ref.read(circleRepositoryProvider).getCircleByCode(code.toUpperCase());
    
    await circleRes.fold(
      (l) async {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (circle) async {
        // 2. Check if already member or pending
        if (circle.memberIds.contains(user.uid)) {
           state = const AsyncData(null);
           showSnackBar(context, 'You are already a member of this circle.');
           return;
        }
        if (circle.pendingMemberIds.contains(user.uid)) {
           state = const AsyncData(null);
           showSnackBar(context, 'Request already sent. Waiting for approval.');
           return;
        }

        // 3. Request Join
        final joinRes = await ref.read(circleRepositoryProvider).requestJoin(circle.id, user.uid);
        
        joinRes.fold(
          (l) {
            state = AsyncError(l.message, StackTrace.current);
            showSnackBar(context, l.message);
          },
          (r) {
            state = const AsyncData(null);
            showSnackBar(context, 'Request sent to ${circle.name}. Waiting for approval.');
            // Do not invalidate userCirclesProvider yet as user is not a member
            context.pop(); 
          }
        );
      },
    );
  }

  Future<void> approveMember({required String circleId, required String memberId, required BuildContext context}) async {
    final res = await ref.read(circleRepositoryProvider).approveMember(circleId, memberId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Member approved!'),
    );
  }

  Future<void> rejectMember({required String circleId, required String memberId, required BuildContext context}) async {
    final res = await ref.read(circleRepositoryProvider).rejectMember(circleId, memberId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Member rejected.'),
    );
  }

  Future<void> promoteToAdmin({required String circleId, required String memberId, required BuildContext context}) async {
    final res = await ref.read(circleRepositoryProvider).promoteToAdmin(circleId, memberId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Member promoted to Admin!'),
    );
  }

  Future<void> demoteFromAdmin({required String circleId, required String memberId, required BuildContext context}) async {
    final res = await ref.read(circleRepositoryProvider).demoteFromAdmin(circleId, memberId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => showSnackBar(context, 'Member demoted from Admin.'),
    );
  }

  Future<void> removeMember({required String circleId, required String memberId, required BuildContext context, required bool isSelf}) async {
    final res = await ref.read(circleRepositoryProvider).removeMember(circleId, memberId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        if (isSelf) {
          showSnackBar(context, 'You have left the circle.');
          context.pop(); // Exit screen
        } else {
          showSnackBar(context, 'Member removed.');
        }
        // StreamProvider handles invalidation automatically
      }
    );
  }
}

@riverpod
Future<List<CircleModel>> userCircles(Ref ref) async {
  final user = await ref.watch(authRepositoryProvider).getCurrentUser();
  if (user == null) return [];
  
  final res = await ref.watch(circleRepositoryProvider).getUserCircles(user.uid);
  return res.fold((l) => [], (r) => r);
}

@riverpod
Stream<CircleModel> circleDetails(Ref ref, String circleId) {
  return ref.watch(circleRepositoryProvider).getCircleStream(circleId).map((circle) {
    if (circle == null) throw 'Circle not found';
    return circle;
  });
}

@riverpod
Future<List<UserModel>> circleMembers(Ref ref, String circleId) async {
  final circle = await ref.watch(circleDetailsProvider(circleId).future);
  return ref.watch(authRepositoryProvider).getUsersByIds(circle.memberIds);
}
