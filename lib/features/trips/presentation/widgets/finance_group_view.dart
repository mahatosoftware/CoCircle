import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../financial/expenses/presentation/expense_audit_screen.dart';
import '../../../financial/expenses/presentation/expense_list.dart';
import '../../../financial/expenses/presentation/expense_stats_screen.dart';
import '../../../financial/settlements/presentation/settlement_list.dart';
import '../trip_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class FinanceGroupView extends ConsumerStatefulWidget {
  final String tripId;

  const FinanceGroupView({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<FinanceGroupView> createState() => _FinanceGroupViewState();
}

class _FinanceGroupViewState extends ConsumerState<FinanceGroupView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
        return circleAsync.when(
          data: (circle) => Column(
            children: [
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: l10n.expensesTab),
                    Tab(text: l10n.settlementsTab),
                    Tab(text: l10n.insightsTab),
                    Tab(text: l10n.auditTab),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ExpenseList(tripId: widget.tripId, currency: circle.currency),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l10n.settlementPlanTitle(circle.currency),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SettlementList(
                            tripId: widget.tripId,
                            currency: circle.currency,
                          ),
                        ],
                      ),
                    ),
                    ExpenseStatsView(tripId: widget.tripId),
                    ExpenseAuditView(tripId: widget.tripId),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }
}
