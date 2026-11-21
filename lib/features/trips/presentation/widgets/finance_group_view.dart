import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../financial/expenses/presentation/expense_audit_screen.dart';
import '../../../financial/expenses/presentation/expense_list.dart';
import '../../../financial/expenses/presentation/expense_stats_screen.dart';
import '../../../financial/presentation/widgets/settlement_dialogs.dart';
import '../../../financial/settlements/presentation/settlement_list.dart';
import '../../../money_predictor/presentation/money_predictor_view.dart';
import '../trip_controller.dart';
import 'package:cocircle/l10n/app_localizations.dart';

class FinanceGroupView extends ConsumerStatefulWidget {
  final String tripId;
  final bool showBottomAction;

  const FinanceGroupView({
    super.key,
    required this.tripId,
    this.showBottomAction = true,
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
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBottomAction(BuildContext context, dynamic trip, List<String> memberNames) {
    switch (_tabController.index) {
      case 0:
      case 3:
      case 4:
        context.push('/trip/${widget.tripId}/create-expense');
        break;
      case 1:
        RecordPaymentSheet.show(
          context,
          memberNames: memberNames,
          onRecord: (record) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment of ₹${record["amount"]} recorded!'),
                backgroundColor: AppPallete.teal,
              ),
            );
          },
        );
        break;
      case 2:
        context.push('/trip/${widget.tripId}/create-expense');
        break;
    }
  }

  String _getBottomButtonLabel(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return '+ Add Expense';
      case 1:
        return 'Record Payment';
      case 2:
        return '+ Add Commitment';
      case 3:
      case 4:
      default:
        return '+ Add Expense';
    }
  }

  IconData _getBottomButtonIcon(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Icons.add_rounded;
      case 1:
        return Icons.payment_rounded;
      case 2:
        return Icons.add_circle_outline_rounded;
      case 3:
      case 4:
      default:
        return Icons.add_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return tripAsync.when(
      data: (trip) {
        final circleAsync = ref.watch(circleDetailsProvider(trip.circleId));
        final membersAsync = ref.watch(circleMembersProvider(trip.circleId));
        final members = membersAsync.asData?.value;
        final List<String> memberNames = (members != null && members.isNotEmpty)
            ? members.map((m) => m.displayName.isNotEmpty ? m.displayName : 'Member').toList()
            : const ['Rahul', 'Priya', 'Amit', 'Neha'];

        return circleAsync.when(
          data: (circle) => Scaffold(
            backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
            body: Column(
              children: [
                // Top Segmented Pill Sub-Tabs (Wireframe 1 Screen 9 & Wireframe 2)
                Container(
                  width: double.infinity,
                  color: isDark ? AppPallete.surfaceDark : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSubTabChip(0, l10n.expensesTab, Icons.receipt_long_outlined, isDark),
                        const SizedBox(width: 8),
                        _buildSubTabChip(1, l10n.settlementsTab, Icons.handshake_outlined, isDark),
                        const SizedBox(width: 8),
                        _buildSubTabChip(2, 'Predictor', Icons.auto_graph_rounded, isDark),
                        const SizedBox(width: 8),
                        _buildSubTabChip(3, l10n.insightsTab, Icons.insights_outlined, isDark),
                        const SizedBox(width: 8),
                        _buildSubTabChip(4, l10n.auditTab, Icons.history_outlined, isDark),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Sub-tab 0: Expenses List
                      ExpenseList(tripId: widget.tripId, currency: circle.currency),

                      // Sub-tab 1: Settlements
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                l10n.settlementPlanTitle(circle.currency),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppPallete.navy,
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

                      // Sub-tab 2: Predictor
                      MoneyPredictorView(
                        tripId: widget.tripId,
                        currency: circle.currency,
                      ),

                      // Sub-tab 3: Insights & Analytics
                      ExpenseStatsView(tripId: widget.tripId),

                      // Sub-tab 4: Audit Logs
                      ExpenseAuditView(tripId: widget.tripId),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: widget.showBottomAction
                ? SafeArea(
                    minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: PrimaryButton(
                            label: _getBottomButtonLabel(_tabController.index),
                            icon: _getBottomButtonIcon(_tabController.index),
                            height: 48,
                            onPressed: () => _handleBottomAction(context, trip, memberNames),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: SecondaryButton(
                            label: 'Export',
                            icon: Icons.download_rounded,
                            height: 48,
                            onPressed: () => context.push('/trip/${widget.tripId}/export-report'),
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
    );
  }

  Widget _buildSubTabChip(int index, String label, IconData icon, bool isDark) {
    final isSelected = _tabController.index == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppPallete.indigo
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppPallete.indigo
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF94A3B8) : AppPallete.gray),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
