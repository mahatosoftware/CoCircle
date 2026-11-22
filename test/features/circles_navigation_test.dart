import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/features/auth/domain/provisioning_state.dart';
import 'package:cocircle/features/auth/domain/user_model.dart';
import 'package:cocircle/features/auth/presentation/provisioning_controller.dart';
import 'package:cocircle/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Circles Navigation and Router Tests', () {
    testWidgets('Navigating to /circles maintains route without redirecting to Home screen on provisioning events', (tester) async {
      final testUser = UserModel(
        uid: 'user_123',
        email: 'test@cocircle.app',
        displayName: 'Test User',
        createdAt: DateTime.now(),
      );

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateChangesProvider.overrideWith(
              (ref) => Stream.value(testUser),
            ),
            provisioningStatusStreamProvider.overrideWith(
              (ref) => Stream.value(
                ProvisioningResult(
                  status: ProvisioningStatus.completed,
                  user: testUser,
                  version: 1,
                  updatedAt: DateTime.now(),
                ),
              ),
            ),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              final router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final router = container.read(routerProvider);
      // Navigate to /circles
      router.go('/circles');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, equals('/circles'));

      // Simulate a provisioning update or auth state update via the listenable notifier
      final notifier = container.read(routerNotifierProvider);
      notifier.notifyListeners();
      await tester.pumpAndSettle();

      // Ensure router does NOT redirect to '/' and remains on '/circles'
      expect(router.state.uri.path, equals('/circles'));
    });
  });
}
