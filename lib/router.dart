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
import 'features/circles/presentation/qr_scanner_screen.dart';
import 'features/financial/expenses/presentation/audit_log_detail_screen.dart';
import 'features/financial/expenses/domain/audit_log_model.dart';
import 'features/financial/presentation/trip_finance_section_screen.dart';
import 'features/polls/presentation/create_poll_screen.dart';
import 'features/polls/domain/poll_model.dart';
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
                path: 'scan-qr',
                builder: (context, state) => const QRScannerScreen(),
              ),
              GoRoute(
                path: 'join/:code',
                builder: (context, state) {
                  final code = state.pathParameters['code'];
                  return JoinCircleScreen(initialCode: code);
                },
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
                  final tab = state.uri.queryParameters['tab'];
                  int initialTab = 0;
                  if (tab == 'polls') initialTab = 1;
                  if (tab == 'tasks') initialTab = 2;
                  if (tab == 'settlements' || tab == 'insights' || tab == 'audit') initialTab = 0;
                  
                  return TripDetailScreen(tripId: tripId, initialTabIndex: initialTab);
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
                  GoRoute(
                    path: 'audit-detail',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final log = extra['log'] as AuditLogModel;
                      final currency = extra['currency'] as String;
                      final memberNames = extra['memberNames'] as Map<String, String>;
                      return AuditLogDetailScreen(log: log, currency: currency, memberNames: memberNames);
                    },
                  ),
                   GoRoute(
                    path: 'finance/:type',
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      final typeStr = state.pathParameters['type']!;
                      final type = FinanceSectionType.values.firstWhere(
                        (e) => e.name == typeStr,
                        orElse: () => FinanceSectionType.expenses,
                      );
                      return TripFinanceSectionScreen(tripId: tripId, type: type);
                    },
                  ),
                  GoRoute(
                    path: 'create-poll',
                    builder: (context, state) {
                      final tripId = state.pathParameters['tripId']!;
                      final poll = state.extra as PollModel?;
                      return CreatePollScreen(tripId: tripId, poll: poll);
                    },
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
