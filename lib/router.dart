import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/profile_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/circles/presentation/my_circles_screen.dart';
import 'features/circles/presentation/create_circle_screen.dart';
import 'features/circles/presentation/join_circle_screen.dart';
import 'features/circles/presentation/circle_detail_screen.dart';
import 'features/circles/presentation/circle_settings_screen.dart';
import 'features/circles/presentation/qr_scanner_screen.dart';
import 'features/circles/presentation/circle_trips_screen.dart';
import 'features/circles/presentation/circle_shopping_lists_screen.dart';
import 'features/trips/presentation/all_trips_screen.dart';
import 'features/trips/presentation/create_trip_screen.dart';
import 'features/trips/presentation/trip_detail_screen.dart';
import 'features/trips/presentation/trip_report_screen.dart';
import 'features/financial/presentation/expenses_hub_screen.dart';
import 'features/financial/expenses/presentation/create_expense_screen.dart';
import 'features/financial/expenses/presentation/expense_detail_screen.dart';
import 'features/financial/expenses/domain/expense_model.dart';
import 'features/financial/expenses/presentation/audit_log_detail_screen.dart';
import 'features/financial/expenses/domain/audit_log_model.dart';
import 'features/financial/presentation/trip_finance_section_screen.dart';
import 'features/activity_center/presentation/unified_activity_center_screen.dart';
import 'features/polls/presentation/create_poll_screen.dart';
import 'features/polls/domain/poll_model.dart';
import 'features/shopping_lists/presentation/create_shopping_list_screen.dart';
import 'features/shopping_lists/presentation/shopping_list_detail_screen.dart';
import 'features/shopping_lists/domain/shopping_list_model.dart';
import 'features/bill_scanner/presentation/bill_scanner_screen.dart';
import 'features/viral_joining/presentation/guest_group_preview_screen.dart';
import 'features/main_nav/main_navigation_shell.dart';
import 'features/reports/presentation/expense_report_config_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isAuthenticated = authState.value != null;
      final isLoginRoute = state.uri.path == '/login';
      final isJoinRoute = state.uri.path.startsWith('/join');

      if (!isAuthenticated && !isLoginRoute && !isJoinRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main Navigation Shell with 5 Persistent Bottom Destinations
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // Destination 0: Home Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Destination 1: Circles Directory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/circles',
                builder: (context, state) => const MyCirclesScreen(),
              ),
            ],
          ),

          // Destination 2: Trips Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) => const AllTripsScreen(),
              ),
            ],
          ),

          // Destination 3: Expenses Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesHubScreen(),
              ),
            ],
          ),

          // Destination 4: Profile & Account Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Full-screen Utility & Detail Routes
      GoRoute(
        path: '/activity-center',
        builder: (context, state) => const UnifiedActivityCenterScreen(),
      ),
      GoRoute(
        path: '/create-circle',
        builder: (context, state) => const CreateCircleScreen(),
      ),
      GoRoute(
        path: '/join-circle',
        builder: (context, state) => const JoinCircleScreen(),
      ),
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/join/:code',
        builder: (context, state) {
          final code = state.pathParameters['code'] ?? '';
          return GuestGroupPreviewScreen(code: code);
        },
      ),
      GoRoute(
        path: '/circle/:circleId',
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
          GoRoute(
            path: 'create-shopping-list',
            builder: (context, state) {
              final circleId = state.pathParameters['circleId']!;
              return CreateShoppingListScreen(circleId: circleId);
            },
          ),
          GoRoute(
            path: 'trips',
            builder: (context, state) {
              final circleId = state.pathParameters['circleId']!;
              return CircleTripsScreen(circleId: circleId);
            },
          ),
          GoRoute(
            path: 'shopping-lists',
            builder: (context, state) {
              final circleId = state.pathParameters['circleId']!;
              return CircleShoppingListsScreen(circleId: circleId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/shopping-list/:listId',
        builder: (context, state) {
          final shoppingList = state.extra as ShoppingListModel;
          return ShoppingListDetailScreen(shoppingList: shoppingList);
        },
      ),
      GoRoute(
        path: '/trip/:tripId',
        builder: (context, state) {
          final tripId = state.pathParameters['tripId']!;
          final tab = state.uri.queryParameters['tab'];
          int initialTab = 0; // Default to Overview
          if (tab == 'overview') initialTab = 0;
          if (tab == 'plan' || tab == 'itinerary') initialTab = 1;
          if (tab == 'tasks') initialTab = 2;
          if (tab == 'polls') initialTab = 3;
          if (tab == 'members') initialTab = 4;
          if (tab == 'finance' || tab == 'budget' || tab == 'settlements' || tab == 'insights' || tab == 'audit' || tab == 'expenses') initialTab = 5;
          if (tab == 'memories') initialTab = 6;

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
          GoRoute(
            path: 'scan-bill',
            builder: (context, state) {
              final tripId = state.pathParameters['tripId']!;
              return BillScannerScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: 'report',
            builder: (context, state) {
              final tripId = state.pathParameters['tripId']!;
              return TripReportScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: 'export-report',
            builder: (context, state) {
              final tripId = state.pathParameters['tripId']!;
              final participantId = state.uri.queryParameters['participantId'];
              return ExpenseReportConfigScreen(
                tripId: tripId,
                initialParticipantId: participantId,
              );
            },
          ),
        ],
      ),
    ],
  );
});
