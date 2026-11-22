import 'package:cocircle/core/errors/failure.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/features/auth/domain/auth_repository.dart';
import 'package:cocircle/features/auth/domain/user_model.dart';
import 'package:cocircle/features/circles/data/circle_repository_impl.dart';
import 'package:cocircle/features/circles/domain/circle_model.dart';
import 'package:cocircle/features/circles/domain/circle_repository.dart';
import 'package:cocircle/features/circles/presentation/circle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
class MockCircleRepository implements CircleRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, CircleModel>> getCircleByCode(String code) async {
    return right(
      CircleModel(
        id: 'circle_test_1',
        name: 'Weekend Getaway',
        description: 'Test circle',
        code: 'TEST123',
        currency: 'INR',
        memberIds: ['admin_user'],
        pendingMemberIds: [],
        adminIds: ['admin_user'],
        createdBy: 'admin_user',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> joinCircle(String circleId, String userId) async {
    return right(null);
  }

  @override
  Future<Either<Failure, void>> requestJoin(String circleId, String userId) async {
    return right(null);
  }
}

class MockAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<UserModel?> getCurrentUser() async {
    return UserModel(
      uid: 'guest_user_1',
      email: 'guest@cocircle.app',
      displayName: 'Guest Traveler',
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<UserModel?> get authStateChanges => Stream.value(
    UserModel(
      uid: 'guest_user_1',
      email: 'guest@cocircle.app',
      displayName: 'Guest Traveler',
      createdAt: DateTime.now(),
    ),
  );
}

void main() {
  group('Join Invitation Tests', () {
    testWidgets('Join invitation adds user to circle directly and navigates to circle detail', (tester) async {
      final mockCircleRepo = MockCircleRepository();
      final mockAuthRepo = MockAuthRepository();

      final router = GoRouter(
        initialLocation: '/join/TEST123',
        routes: [
          GoRoute(
            path: '/join/:code',
            builder: (context, state) => Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  final circleState = ref.watch(circleControllerProvider);
                  return ElevatedButton(
                    onPressed: circleState.isLoading
                        ? null
                        : () {
                            ref.read(circleControllerProvider.notifier).joinCircleByCode(
                              code: state.pathParameters['code']!,
                              context: context,
                              directJoin: true,
                            );
                          },
                    child: Text(circleState.isLoading ? 'Joining...' : 'Join Invitation'),
                  );
                },
              ),
            ),
          ),
          GoRoute(
            path: '/circle/:id',
            builder: (context, state) => Scaffold(
              body: Text('Circle Detail: ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            circleRepositoryProvider.overrideWithValue(mockCircleRepo),
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Join Invitation'), findsOneWidget);

      await tester.tap(find.text('Join Invitation'));
      await tester.pumpAndSettle();

      // Verify that join completed and navigated to circle detail
      expect(find.text('Circle Detail: circle_test_1'), findsOneWidget);
    });
  });
}
