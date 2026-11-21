import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import 'widgets/finance_group_view.dart';
import '../../polls/presentation/poll_list_view.dart';
import '../../tasks/presentation/task_list_view.dart';
import '../../copilot/presentation/cocircle_magic_sheet.dart';
import '../../memories/presentation/memories_tab.dart';
import 'trip_controller.dart';
import 'trip_plan_tab.dart';
import 'widgets/trip_overview_tab.dart';
import 'widgets/trip_members_tab.dart';
import 'trip_participant_controller.dart';
import '../../live_map/presentation/live_map_tab.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../financial/presentation/widgets/settlement_dialogs.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../road_trip/presentation/road_trip_workspace_tab.dart';
import '../../road_trip/presentation/road_trip_budget_view.dart';
import 'trip_report_screen.dart';
import '../../notifications/presentation/notification_controller.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final int initialTabIndex;
  final String? initialTab;
  const TripDetailScreen({
    super.key,
    required this.tripId,
    this.initialTabIndex = 0,
    this.initialTab,
  });

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return tripAsync.when(
      data: (trip) {
        final circleMembersAsync = ref.watch(circleMembersProvider(trip.circleId));
        final participantsAsync = ref.watch(tripParticipantsProvider(trip.id));
        final memberNames = participantsAsync.value?.isNotEmpty == true
            ? participantsAsync.value!.map((p) => p.name).toList()
            : (circleMembersAsync.value?.map((u) => u.displayName).toList() ?? ['You']);
        final photoUrls = participantsAsync.value?.isNotEmpty == true
            ? participantsAsync.value!.map((p) => p.avatarUrl).toList()
            : circleMembersAsync.value?.map((u) => u.photoUrl).toList();

        final status = trip.status.toLowerCase();
        final isTravel = status == 'ongoing';
        final isSettlement = status == 'settling';
        final isClosed = status == 'closed' || status == 'completed';

        // Select the appropriate workspace layout according to the lifecycle phase (Wireframe 2)
        if (isTravel) {
          return _buildTravelWorkspace(context, trip, memberNames, photoUrls, isDark);
        } else if (isSettlement) {
          return _buildSettlementWorkspace(context, trip, memberNames, photoUrls, isDark);
        } else if (isClosed) {
          return _buildClosedWorkspace(context, trip, memberNames, photoUrls, isDark);
        } else {
          return _buildPlanningWorkspace(context, trip, memberNames, photoUrls, isDark);
        }
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error loading trip: $err'))),
    );
  }

  // 1. PLANNING WORKSPACE (Trip: Planning) - Wireframe 2 Screen 1
  Widget _buildPlanningWorkspace(
    BuildContext context,
    dynamic trip,
    List<String> memberNames,
    List<String?>? photoUrls,
    bool isDark,
  ) {
    String datesText = '12-15 Mar (4 days)';
    if (trip.startDate != null) {
      final startFmt = DateFormat('d MMM').format(trip.startDate);
      final endFmt = trip.endDate != null ? DateFormat('d MMM').format(trip.endDate) : '';
      final days = trip.endDate != null ? trip.endDate.difference(trip.startDate).inDays + 1 : 1;
      datesText = endFmt.isNotEmpty ? '$startFmt - $endFmt ($days days)' : '$startFmt ($days day)';
    }

    return DefaultTabController(
      length: 9,
      initialIndex: widget.initialTabIndex.clamp(0, 8),
      child: Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppPallete.navy),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      trip.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge.fromTripStatus(trip.status.isNotEmpty ? trip.status : 'Planning'),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                trip.location != null && trip.location!.isNotEmpty
                    ? '${trip.location} • $datesText'
                    : datesText,
                style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _confirmTripDialog(context, trip),
                child: const Text('Confirm Trip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildOptionsMenu(context, trip),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppPallete.indigo,
            indicatorWeight: 3,
            labelColor: AppPallete.indigo,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Plan'),
              Tab(text: 'Route'),
              Tab(text: 'Tasks'),
              Tab(text: 'Polls'),
              Tab(text: 'Expenses'),
              Tab(text: 'Budget'),
              Tab(text: 'Members'),
              Tab(text: 'Reports'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: Builder(
            builder: (tabCtx) {
              return TabBarView(
                children: [
                  TripOverviewTab(
                    tripId: widget.tripId,
                    onNavigateToMap: () => DefaultTabController.of(tabCtx).animateTo(2),
                    onNavigateToItinerary: () => DefaultTabController.of(tabCtx).animateTo(1),
                    onNavigateToTasks: () => DefaultTabController.of(tabCtx).animateTo(3),
                    onNavigateToPolls: () => DefaultTabController.of(tabCtx).animateTo(4),
                    onNavigateToExpenses: () => DefaultTabController.of(tabCtx).animateTo(5),
                    onNavigateToMembers: () => DefaultTabController.of(tabCtx).animateTo(7),
                  ),
                  TripPlanTab(tripId: widget.tripId),
                  RoadTripWorkspaceTab(tripId: widget.tripId),
                  TaskListView(tripId: widget.tripId),
                  PollListView(tripId: widget.tripId),
                  FinanceGroupView(tripId: widget.tripId, showBottomAction: true),
                  RoadTripBudgetView(tripId: widget.tripId),
                  TripMembersTab(tripId: widget.tripId),
                  TripReportScreen(tripId: widget.tripId),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // 2. TRAVEL WORKSPACE (Trip: Ongoing) - Wireframe 2 Screen 2
  Widget _buildTravelWorkspace(
    BuildContext context,
    dynamic trip,
    List<String> memberNames,
    List<String?>? photoUrls,
    bool isDark,
  ) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppPallete.navy),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      trip.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge.fromTripStatus('Ongoing'),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Day 2 of 4 • Travel Mode',
                style: TextStyle(fontSize: 11, color: AppPallete.gray),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _advanceToSettlement(context, trip),
                child: const Text('End Travel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildOptionsMenu(context, trip),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppPallete.indigo,
            indicatorWeight: 3,
            labelColor: AppPallete.indigo,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Map'),
              Tab(text: 'Route & Fuel'),
              Tab(text: 'Plan'),
              Tab(text: 'Expenses'),
              Tab(text: 'Budget'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LiveMapTab(tripId: widget.tripId),
            RoadTripWorkspaceTab(tripId: widget.tripId),
            TripPlanTab(tripId: widget.tripId),
            FinanceGroupView(tripId: widget.tripId, showBottomAction: false),
            RoadTripBudgetView(tripId: widget.tripId),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          bottom: true,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            padding: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: '+ Add Expense',
                    icon: Icons.receipt_long_rounded,
                    height: 44,
                    onPressed: () => context.push('/trip/${widget.tripId}/create-expense'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Share ETA',
                    icon: Icons.share_location_rounded,
                    height: 44,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ETA shared with convoy members! 🚗')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 3. SETTLEMENT WORKSPACE (Trip: Settling) - Wireframe 2 Screen 3
  Widget _buildSettlementWorkspace(
    BuildContext context,
    dynamic trip,
    List<String> memberNames,
    List<String?>? photoUrls,
    bool isDark,
  ) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppPallete.navy),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      trip.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : AppPallete.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge.fromTripStatus('Settling'),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'Travel completed • Settlement Phase',
                style: TextStyle(fontSize: 11, color: AppPallete.gray),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Export Financial Report (PDF/Excel/CSV)',
              onPressed: () => context.push('/trip/${trip.id}/export-report'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => CloseTripSheet.show(
                  context,
                  onConfirmClose: () => _finalizeCloseTrip(context, trip),
                ),
                child: const Text('Close Trip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildOptionsMenu(context, trip),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppPallete.indigo,
            indicatorWeight: 3,
            labelColor: AppPallete.indigo,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'Balances'),
              Tab(text: 'Expenses'),
              Tab(text: 'Final Report'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: TabBarView(
            children: [
              _buildSettlementBalancesView(context, trip, memberNames, isDark),
              FinanceGroupView(tripId: widget.tripId, showBottomAction: true),
              TripReportScreen(tripId: widget.tripId),
            ],
          ),
        ),
      ),
    );
  }

  // 4. CLOSED WORKSPACE (Trip: Closed)
  Widget _buildClosedWorkspace(
    BuildContext context,
    dynamic trip,
    List<String> memberNames,
    List<String?>? photoUrls,
    bool isDark,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
        appBar: AppBar(
          titleSpacing: 16,
          backgroundColor: isDark ? AppPallete.surfaceDark : Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppPallete.navy),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  trip.name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : AppPallete.navy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.fromTripStatus('Closed'),
            ],
          ),
          actions: [
            _buildOptionsMenu(context, trip),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            indicatorColor: AppPallete.indigo,
            indicatorWeight: 3,
            labelColor: AppPallete.indigo,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
            tabs: const [
              Tab(text: 'Final Report'),
              Tab(text: 'Memories'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: TabBarView(
            children: [
              TripReportScreen(tripId: widget.tripId),
              MemoriesTab(tripId: widget.tripId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementBalancesView(
    BuildContext context,
    dynamic trip,
    List<String> memberNames,
    bool isDark,
  ) {
    final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));
    final balancesAsync = ref.watch(tripParticipantBalancesProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));

    final participants = participantsAsync.value ?? [];
    final balances = balancesAsync.value ?? {};
    final expenses = expensesAsync.value ?? [];

    final totalSpent = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final totalSpentText = expenses.isNotEmpty ? '₹${totalSpent.toStringAsFixed(0)}' : '₹58,420';
    final avgPersonText = (expenses.isNotEmpty && participants.isNotEmpty)
        ? '₹${(totalSpent / participants.length).toStringAsFixed(0)}'
        : '₹5,842';
    final expenseCountText = expenses.isNotEmpty ? '${expenses.length}' : '24';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trip Summary Metrics
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSummaryItem('Total Spent', totalSpentText, isDark),
                  _buildSummaryItem('Per Person (Avg)', avgPersonText, isDark),
                  _buildSummaryItem('Expenses', expenseCountText, isDark),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget: ₹60,000', style: TextStyle(fontSize: 12, color: AppPallete.gray)),
                  Text('97%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppPallete.indigo)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.97,
                  minHeight: 6,
                  backgroundColor: Color(0xFFEEF2FF),
                  valueColor: AlwaysStoppedAnimation<Color>(AppPallete.indigo),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Member Balances Header
        Text(
          'Member Balances',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 12),

        // Member Balances matching Wireframe 1 Screen 11 & Wireframe 2 Screen 3
        if (participants.isNotEmpty && balances.isNotEmpty) ...[
          for (final p in participants) ...[
            Builder(builder: (_) {
              final bal = balances[p.id];
              final netPaise = bal?.netPaise ?? 0;
              final isSettled = netPaise == 0;
              final statusText = isSettled
                  ? 'Settled'
                  : (netPaise > 0
                      ? 'Receive ₹${(netPaise / 100).toStringAsFixed(0)}'
                      : 'To Pay ₹${(-netPaise / 100).toStringAsFixed(0)}');
              final statusColor = netPaise >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMemberBalanceTile(
                  name: p.name,
                  statusText: statusText,
                  statusColor: statusColor,
                  isSettled: isSettled,
                  isGuest: p.isGuest,
                  isDark: isDark,
                ),
              );
            }),
          ],
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppPallete.gray, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No participants or balances to display yet.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Record Payment',
                icon: Icons.payments_rounded,
                onPressed: () => RecordPaymentSheet.show(
                  context,
                  memberNames: memberNames,
                  participants: participants,
                  onRecord: (data) async {
                    await ref.read(tripParticipantControllerProvider.notifier).recordPayment(
                          tripId: widget.tripId,
                          fromMemberId: data['from'],
                          toMemberId: data['to'],
                          amount: data['amount'] as double,
                          paymentMethod: data['method'] as String,
                          referenceNumber: data['reference'] as String?,
                          notes: data['notes'] as String?,
                          onBehalfOfGuest: data['onBehalfOfGuest'] as bool? ?? false,
                          context: context,
                        );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'Add Write-off',
                icon: Icons.money_off_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Write-off waiver applied.')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Close Trip',
          backgroundColor: const Color(0xFF059669),
          onPressed: () => CloseTripSheet.show(
            context,
            onConfirmClose: () => _finalizeCloseTrip(context, trip),
          ),
          width: double.infinity,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppPallete.navy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppPallete.gray),
        ),
      ],
    );
  }

  Widget _buildMemberBalanceTile({
    required String name,
    required String statusText,
    required Color statusColor,
    bool isSettled = false,
    bool isGuest = false,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppPallete.indigo.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'M',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.indigo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppPallete.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isGuest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Guest',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSettled)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                SizedBox(width: 4),
                Text(
                  'Settled',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13),
                ),
              ],
            )
          else
            Text(
              statusText,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: statusColor,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context, dynamic trip) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (val) {
        if (val == 'switch_planning') {
          ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
                trip: trip,
                newStatus: 'planning',
                context: context,
              );
        } else if (val == 'switch_ongoing') {
          ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
                trip: trip,
                newStatus: 'ongoing',
                context: context,
              );
        } else if (val == 'switch_settling') {
          ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
                trip: trip,
                newStatus: 'settling',
                context: context,
              );
        } else if (val == 'switch_closed') {
          ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
                trip: trip,
                newStatus: 'closed',
                context: context,
              );
        } else if (val == 'ai_magic') {
          CoCircleMagicSheet.show(context, widget.tripId);
        } else if (val == 'report') {
          context.push('/trip/${trip.id}/report');
        } else if (val == 'export_report') {
          context.push('/trip/${trip.id}/export-report');
        } else if (val == 'toggle_mute') {
          final isMuted = ref.read(userNotificationPreferencesProvider).value?.isTripMuted(trip.id) ?? false;
          ref.read(notificationControllerProvider.notifier).toggleMuteTrip(trip.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isMuted ? 'Trip alerts unmuted' : 'Trip alerts muted'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      itemBuilder: (ctx) {
        final isMuted = ref.watch(userNotificationPreferencesProvider).value?.isTripMuted(trip.id) ?? false;
        return [
        PopupMenuItem(
          value: 'toggle_mute',
          child: Row(
            children: [
              Icon(isMuted ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, color: AppPallete.indigo, size: 18),
              const SizedBox(width: 8),
              Text(isMuted ? 'Unmute Trip Alerts' : 'Mute Trip Alerts'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'export_report',
          child: Row(
            children: [
              Icon(Icons.download_rounded, color: AppPallete.indigo, size: 18),
              SizedBox(width: 8),
              Text('Export Financial Report'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'ai_magic',
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppPallete.indigo, size: 18),
              SizedBox(width: 8),
              Text('CoCircle AI Copilot'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'switch_planning',
          child: Text('Mode: Planning'),
        ),
        const PopupMenuItem(
          value: 'switch_ongoing',
          child: Text('Mode: Travel (Ongoing)'),
        ),
        const PopupMenuItem(
          value: 'switch_settling',
          child: Text('Mode: Settlement'),
        ),
        const PopupMenuItem(
          value: 'switch_closed',
          child: Text('Mode: Closed'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'report',
          child: Text('Consolidated Report'),
        ),
      ];
    },
  );
}

  void _confirmTripDialog(BuildContext context, dynamic trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Trip Plan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Locking in trip arrangements will prepare your group for Departure and activate Travel Convoy Radar.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
                    trip: trip,
                    newStatus: 'ongoing',
                    context: context,
                  );
            },
            child: const Text('Activate Travel Mode'),
          ),
        ],
      ),
    );
  }

  void _advanceToSettlement(BuildContext context, dynamic trip) {
    ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
          trip: trip,
          newStatus: 'settling',
          context: context,
        );
  }

  void _finalizeCloseTrip(BuildContext context, dynamic trip) {
    ref.read(tripControllerProvider.notifier).updateTripLifecycleStatus(
          trip: trip,
          newStatus: 'closed',
          context: context,
        );
  }
}
