import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/circles/presentation/create_circle_screen.dart';
import 'features/circles/presentation/join_circle_screen.dart';
import 'features/circles/presentation/my_circles_screen.dart';
import 'features/circles/presentation/circle_detail_screen.dart';
import 'features/trips/presentation/create_trip_screen.dart';
import 'features/trips/presentation/trip_detail_screen.dart';
import 'features/financial/expenses/presentation/create_expense_screen.dart';
import 'features/financial/expenses/presentation/expense_detail_screen.dart';
import 'features/financial/expenses/domain/expense_model.dart';
import 'features/circles/presentation/circle_settings_screen.dart';
import 'features/auth/presentation/profile_screen.dart';
import 'core/widgets/copyright_footer.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;
      
      final isAuthenticated = authState.value != null;
      final isLoginRoute = state.uri.path == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(child: child),
                const CopyrightFooter(),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/',
            builder: (context, state) => const MyCirclesScreen(),
            routes: [
              GoRoute(
                path: 'create-circle',
                builder: (context, state) => const CreateCircleScreen(),
              ),
              GoRoute(
                path: 'join-circle',
                builder: (context, state) => const JoinCircleScreen(),
              ),
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'circle/:circleId',
                builder: (context, state) {
                   final circleId = state.pathParameters['circleId']!;
                   return CircleDetailScreen(circleId: circleId);
                },
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) {
                      final circleId = state.pathParameters['circleId']!;
                      return CircleSettingsScreen(circleId: circleId);
                    },
                  ),
                  GoRoute(
                    path: 'create-trip',
                    builder: (context, state) {
                      final circleId = state.pathParameters['circleId']!;
                      return CreateTripScreen(circleId: circleId);
                    },
                  ),
                ]
              ),
              GoRoute(
                path: 'trip/:tripId',
                builder: (context, state) {
                  final tripId = state.pathParameters['tripId']!;
                  return TripDetailScreen(tripId: tripId);
                },
                routes: [
                  GoRoute(
                    path: 'create-expense',
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      return CreateExpenseScreen(tripId: tripId);
                    },
                  ),
                  GoRoute(
                    path: 'expense/:expenseId',
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      final expenseId = state.pathParameters['expenseId']!;
                      return ExpenseDetailScreen(tripId: tripId, expenseId: expenseId);
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) {
                          final tripId = state.pathParameters['tripId']!;
                          final expense = state.extra as ExpenseModel?;
                          return CreateExpenseScreen(tripId: tripId, expense: expense);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
