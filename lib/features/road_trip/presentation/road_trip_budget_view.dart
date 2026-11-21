import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../trips/data/trip_repository_impl.dart';
import '../../trips/domain/trip_model.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_participant_controller.dart';
import '../domain/road_trip_budget_model.dart';
import 'road_trip_controller.dart';

class RoadTripBudgetView extends ConsumerStatefulWidget {
  final String tripId;

  const RoadTripBudgetView({super.key, required this.tripId});

  @override
  ConsumerState<RoadTripBudgetView> createState() => _RoadTripBudgetViewState();
}

class _RoadTripBudgetViewState extends ConsumerState<RoadTripBudgetView> {
  int _selectedTab = 0; // 0: Overview, 1: Category Breakdown, 2: Day-wise Breakdown

  @override
  Widget build(BuildContext context) {
    final budgetAsync = ref.watch(roadTripBudgetStreamProvider(widget.tripId));
    final tripAsync = ref.watch(tripDetailsProvider(widget.tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));
    final participantsAsync = ref.watch(tripParticipantsProvider(widget.tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trip = tripAsync.asData?.value;
    final expenses = expensesAsync.asData?.value ?? [];
    final participants = participantsAsync.asData?.value ?? [];
    final participantCount = participants.isNotEmpty ? participants.length : 1;

    return budgetAsync.when(
      data: (budget) {
        // Fallback default budget initialized from trip.totalBudget if not yet set
        final targetBudgetAmount = (trip != null && trip.totalBudget > 0)
            ? trip.totalBudget
            : 50000.0;

        final activeBudget = budget ??
            RoadTripBudgetModel(
              id: const Uuid().v4(),
              tripId: widget.tripId,
              totalBudget: targetBudgetAmount,
              currency: '₹',
              categoryBudgets: {
                RoadTripBudgetCategory.fuel: targetBudgetAmount * 0.20,
                RoadTripBudgetCategory.accommodation: targetBudgetAmount * 0.35,
                RoadTripBudgetCategory.food: targetBudgetAmount * 0.25,
                RoadTripBudgetCategory.activities: targetBudgetAmount * 0.10,
                RoadTripBudgetCategory.emergency: targetBudgetAmount * 0.10,
              },
              dailyBudgets: {
                1: targetBudgetAmount * 0.3,
                2: targetBudgetAmount * 0.3,
                3: targetBudgetAmount * 0.4,
              },
              createdBy: 'organizer',
              updatedAt: DateTime.now(),
            );

        final report = BudgetUtilizationReport.compute(
          budget: activeBudget,
          actualExpenses: expenses,
          participantCount: participantCount,
        );

        return Scaffold(
          backgroundColor: isDark ? AppPallete.backgroundDark : AppPallete.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Executive Budget Health Card
                _buildBudgetHealthCard(context, report, isDark),
                const SizedBox(height: 16),

                // 2. Segment Switcher (Overview, Category, Day-wise)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppPallete.surfaceDark : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildTabChip(0, 'Overview', isDark),
                      _buildTabChip(1, 'Categories', isDark),
                      _buildTabChip(2, 'Day-wise', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Tab Content
                if (_selectedTab == 0)
                  _buildOverviewSection(context, activeBudget, report, isDark)
                else if (_selectedTab == 1)
                  _buildCategoryBreakdownSection(context, activeBudget, report, isDark)
                else
                  _buildDayWiseSection(context, activeBudget, report, isDark),

                const SizedBox(height: 100), // Navigation spacing
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SecondaryButton(
              label: 'Adjust Target Budget & Category Limits',
              icon: Icons.tune_rounded,
              height: 48,
              onPressed: () => _showComprehensiveBudgetSheet(context, activeBudget, trip),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading budget: $e')),
    );
  }

  Widget _buildBudgetHealthCard(BuildContext context, BudgetUtilizationReport report, bool isDark) {
    Color healthColor;
    String healthText;
    switch (report.health) {
      case BudgetHealth.healthy:
        healthColor = const Color(0xFF10B981); // Green
        healthText = 'WITHIN BUDGET';
        break;
      case BudgetHealth.warning:
        healthColor = const Color(0xFFF59E0B); // Amber
        healthText = 'APPROACHING LIMIT';
        break;
      case BudgetHealth.exceeded:
        healthColor = const Color(0xFFDC2626); // Red
        healthText = 'BUDGET EXCEEDED';
        break;
    }

    final progressVal = (report.utilizationPercentage / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL TRIP BUDGET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  healthText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: healthColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${report.totalActualSpent.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppPallete.navy,
                ),
              ),
              Text(
                'of ₹${report.targetBudget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, color: AppPallete.gray, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressVal,
              minHeight: 10,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.utilizationPercentage.toStringAsFixed(1)}% Utilized',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: healthColor),
              ),
              Text(
                report.remainingBudget >= 0
                    ? '₹${report.remainingBudget.toStringAsFixed(0)} Remaining'
                    : '₹${(-report.remainingBudget).toStringAsFixed(0)} Over Budget',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: report.remainingBudget >= 0 ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppPallete.indigo : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppPallete.navy)
                    : AppPallete.gray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    BuildContext context,
    RoadTripBudgetModel budget,
    BudgetUtilizationReport report,
    bool isDark,
  ) {
    final activeCategories = budget.categoryBudgets.keys.toList();

    return Column(
      children: [
        // Per-person card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPallete.teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppPallete.teal, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Per-Person Share', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      'Split across ${report.totalParticipants} participants (incl. guests)',
                      style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${report.perPersonActualSpent.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppPallete.navy),
                  ),
                  Text(
                    'Target: ₹${report.perPersonEstimatedBudget.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: AppPallete.gray),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quick Top Spending Categories (Tappable to edit)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spending Snapshot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 16, color: AppPallete.primary),
                    label: const Text('Add Line Item', style: TextStyle(fontSize: 12, color: AppPallete.primary, fontWeight: FontWeight.bold)),
                    onPressed: () => _showAddCategoryDialog(context, budget),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tap any category to update its budget limit',
                style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : AppPallete.gray),
              ),
              const SizedBox(height: 14),

              ...activeCategories.map((cat) {
                final spent = report.categorySpent[cat] ?? 0.0;
                final limit = report.categoryBudgetLimits[cat] ?? 0.0;
                final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showEditCategoryDialog(context, budget, cat),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(cat.icon, size: 16, color: cat.color),
                                const SizedBox(width: 8),
                                Text(cat.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 11, color: AppPallete.gray, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit_outlined, size: 14, color: AppPallete.gray),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                          valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownSection(
    BuildContext context,
    RoadTripBudgetModel budget,
    BudgetUtilizationReport report,
    bool isDark,
  ) {
    // Collect all categories that have a budget limit or have recorded expenses
    final categoriesToShow = RoadTripBudgetCategory.values.where((cat) {
      final hasLimit = (budget.categoryBudgets[cat] ?? 0.0) > 0;
      final hasSpent = (report.categorySpent[cat] ?? 0.0) > 0;
      return hasLimit || hasSpent;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${categoriesToShow.length} Active Category Budgets',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Reset Defaults', style: TextStyle(fontSize: 12)),
              onPressed: () => _resetToDefaults(context, budget),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...categoriesToShow.map((cat) {
          final spent = report.categorySpent[cat] ?? 0.0;
          final limit = report.categoryBudgetLimits[cat] ?? 0.0;
          final pct = limit > 0 ? (spent / limit) * 100 : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showEditCategoryDialog(context, budget, cat),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppPallete.navy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  limit > 0 ? 'Allocated: ₹${limit.toStringAsFixed(0)}' : 'No limit set',
                                  style: const TextStyle(fontSize: 11, color: AppPallete.gray),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${spent.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppPallete.navy,
                                ),
                              ),
                              Text(
                                limit > 0 ? '${pct.toStringAsFixed(0)}% utilized' : 'Spent',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: pct > 100
                                      ? const Color(0xFFDC2626)
                                      : (pct > 80 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppPallete.primary,
                            tooltip: 'Edit Budget Limit',
                            onPressed: () => _showEditCategoryDialog(context, budget, cat),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            color: Colors.redAccent,
                            tooltip: 'Remove Category Limit',
                            onPressed: () => _removeCategoryLimit(context, budget, cat),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0,
                          minHeight: 5,
                          backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct > 100
                                ? const Color(0xFFDC2626)
                                : (pct > 80 ? const Color(0xFFF59E0B) : cat.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        // Add Category Line Item Button
        OutlinedButton.icon(
          onPressed: () => _showAddCategoryDialog(context, budget),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppPallete.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.add_rounded, color: AppPallete.primary),
          label: const Text(
            '+ Add Category Line Item',
            style: TextStyle(color: AppPallete.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDayWiseSection(
    BuildContext context,
    RoadTripBudgetModel budget,
    BudgetUtilizationReport report,
    bool isDark,
  ) {
    final days = budget.dailyBudgets.keys.toList()..sort();
    if (days.isEmpty) {
      days.addAll([1, 2, 3]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${days.length} Itinerary Day Allocations',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppPallete.navy,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Day', style: TextStyle(fontSize: 12)),
              onPressed: () => _showAddDayDialog(context, budget),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...days.map((dayNum) {
          final spent = report.daySpent[dayNum] ?? 0.0;
          final dayBudget = report.dayBudgetLimits[dayNum] ?? 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppPallete.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showEditDayDialog(context, budget, dayNum),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppPallete.indigo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'D$dayNum',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppPallete.indigo, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day $dayNum Itinerary Budget',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : AppPallete.navy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Allocated: ₹${dayBudget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${spent.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: spent > dayBudget && dayBudget > 0 ? const Color(0xFFDC2626) : (isDark ? Colors.white : AppPallete.navy),
                            ),
                          ),
                          const Text('Actual Spent', style: TextStyle(fontSize: 10, color: AppPallete.gray)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: AppPallete.primary,
                        tooltip: 'Edit Day Budget',
                        onPressed: () => _showEditDayDialog(context, budget, dayNum),
                      ),
                      if (days.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          color: Colors.redAccent,
                          tooltip: 'Remove Day',
                          onPressed: () => _removeDayBudget(context, budget, dayNum),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddDayDialog(context, budget),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppPallete.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.add_rounded, color: AppPallete.primary),
          label: const Text(
            '+ Add Day Allocation',
            style: TextStyle(color: AppPallete.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- ACTIONS & DIALOGS ---

  void _showEditCategoryDialog(
    BuildContext context,
    RoadTripBudgetModel budget,
    RoadTripBudgetCategory cat,
  ) {
    final currentAmount = budget.categoryBudgets[cat] ?? 0.0;
    final controller = TextEditingController(
      text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(cat.icon, color: cat.color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Edit ${cat.shortName} Limit',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set target budget allocation for ${cat.displayName}:',
              style: const TextStyle(fontSize: 13, color: AppPallete.gray),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Limit (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Quick Presets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppPallete.gray)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildQuickChip('10%', (budget.totalBudget * 0.1).roundToDouble(), controller),
                _buildQuickChip('20%', (budget.totalBudget * 0.2).roundToDouble(), controller),
                _buildQuickChip('35%', (budget.totalBudget * 0.35).roundToDouble(), controller),
                _buildQuickChip('+₹2,000', (currentAmount + 2000).roundToDouble(), controller),
                _buildQuickChip('+₹5,000', (currentAmount + 5000).roundToDouble(), controller),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newLimit = double.tryParse(controller.text.trim()) ?? 0.0;
              final updatedBudgets = Map<RoadTripBudgetCategory, double>.from(budget.categoryBudgets);
              if (newLimit > 0) {
                updatedBudgets[cat] = newLimit;
              } else {
                updatedBudgets.remove(cat);
              }

              final updated = budget.copyWith(
                categoryBudgets: updatedBudgets,
                updatedAt: DateTime.now(),
              );

              ref.read(roadTripControllerProvider).saveBudget(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Updated ${cat.displayName} limit to ₹${newLimit.toStringAsFixed(0)}')),
              );
            },
            child: const Text('Save Limit'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    RoadTripBudgetModel budget,
  ) {
    // Show categories that don't have an active limit yet
    final unallocatedCategories = RoadTripBudgetCategory.values.where((c) {
      return (budget.categoryBudgets[c] ?? 0.0) <= 0;
    }).toList();

    RoadTripBudgetCategory selectedCategory = unallocatedCategories.isNotEmpty
        ? unallocatedCategories.first
        : RoadTripBudgetCategory.shopping;

    final controller = TextEditingController(text: '5000');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Category Line Item', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Category:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppPallete.gray)),
              const SizedBox(height: 6),
              DropdownButtonFormField<RoadTripBudgetCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: RoadTripBudgetCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 18, color: cat.color),
                        const SizedBox(width: 8),
                        Text(cat.displayName, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 14),
              const Text('Allocated Budget (₹):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppPallete.gray)),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: '5000',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final amt = double.tryParse(controller.text.trim()) ?? 5000.0;
                final updatedBudgets = Map<RoadTripBudgetCategory, double>.from(budget.categoryBudgets);
                updatedBudgets[selectedCategory] = amt;

                final updated = budget.copyWith(
                  categoryBudgets: updatedBudgets,
                  updatedAt: DateTime.now(),
                );

                ref.read(roadTripControllerProvider).saveBudget(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${selectedCategory.displayName} (₹${amt.toStringAsFixed(0)}) to budget')),
                );
              },
              child: const Text('Add Line Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeCategoryLimit(BuildContext context, RoadTripBudgetModel budget, RoadTripBudgetCategory cat) {
    final updatedBudgets = Map<RoadTripBudgetCategory, double>.from(budget.categoryBudgets);
    updatedBudgets.remove(cat);

    final updated = budget.copyWith(
      categoryBudgets: updatedBudgets,
      updatedAt: DateTime.now(),
    );

    ref.read(roadTripControllerProvider).saveBudget(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${cat.displayName} limit')),
    );
  }

  void _showEditDayDialog(BuildContext context, RoadTripBudgetModel budget, int dayNum) {
    final currentAmount = budget.dailyBudgets[dayNum] ?? 0.0;
    final controller = TextEditingController(text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Day $dayNum Budget', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target itinerary budget allocated for Day $dayNum:', style: const TextStyle(fontSize: 13, color: AppPallete.gray)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Day Budget (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPallete.primary, foregroundColor: Colors.white),
            onPressed: () {
              final newAmt = double.tryParse(controller.text.trim()) ?? 0.0;
              final updatedDaily = Map<int, double>.from(budget.dailyBudgets);
              updatedDaily[dayNum] = newAmt;

              final updated = budget.copyWith(
                dailyBudgets: updatedDaily,
                updatedAt: DateTime.now(),
              );

              ref.read(roadTripControllerProvider).saveBudget(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Day $dayNum budget updated to ₹${newAmt.toStringAsFixed(0)}')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddDayDialog(BuildContext context, RoadTripBudgetModel budget) {
    final maxDay = budget.dailyBudgets.keys.isNotEmpty
        ? budget.dailyBudgets.keys.reduce((a, b) => a > b ? a : b)
        : 0;
    final nextDay = maxDay + 1;
    final dayController = TextEditingController(text: nextDay.toString());
    final amountController = TextEditingController(text: '10000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Day Allocation', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: dayController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Day Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Allocated Budget (₹)', prefixText: '₹ ', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppPallete.primary, foregroundColor: Colors.white),
            onPressed: () {
              final dayNum = int.tryParse(dayController.text.trim()) ?? nextDay;
              final amt = double.tryParse(amountController.text.trim()) ?? 0.0;

              final updatedDaily = Map<int, double>.from(budget.dailyBudgets);
              updatedDaily[dayNum] = amt;

              final updated = budget.copyWith(
                dailyBudgets: updatedDaily,
                updatedAt: DateTime.now(),
              );

              ref.read(roadTripControllerProvider).saveBudget(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added Day $dayNum with ₹${amt.toStringAsFixed(0)} budget')),
              );
            },
            child: const Text('Add Day'),
          ),
        ],
      ),
    );
  }

  void _removeDayBudget(BuildContext context, RoadTripBudgetModel budget, int dayNum) {
    final updatedDaily = Map<int, double>.from(budget.dailyBudgets);
    updatedDaily.remove(dayNum);

    final updated = budget.copyWith(
      dailyBudgets: updatedDaily,
      updatedAt: DateTime.now(),
    );

    ref.read(roadTripControllerProvider).saveBudget(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed Day $dayNum allocation')),
    );
  }

  void _resetToDefaults(BuildContext context, RoadTripBudgetModel budget) {
    final total = budget.totalBudget > 0 ? budget.totalBudget : 50000.0;
    final defaultCategories = {
      RoadTripBudgetCategory.fuel: total * 0.20,
      RoadTripBudgetCategory.accommodation: total * 0.35,
      RoadTripBudgetCategory.food: total * 0.25,
      RoadTripBudgetCategory.activities: total * 0.10,
      RoadTripBudgetCategory.emergency: total * 0.10,
    };
    final defaultDaily = {
      1: total * 0.3,
      2: total * 0.3,
      3: total * 0.4,
    };

    final updated = budget.copyWith(
      categoryBudgets: defaultCategories,
      dailyBudgets: defaultDaily,
      updatedAt: DateTime.now(),
    );

    ref.read(roadTripControllerProvider).saveBudget(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget reset to standard default allocations')),
    );
  }

  void _showComprehensiveBudgetSheet(
    BuildContext context,
    RoadTripBudgetModel budget,
    TripModel? trip,
  ) {
    final totalController = TextEditingController(text: budget.totalBudget.toStringAsFixed(0));
    final categoryControllers = <RoadTripBudgetCategory, TextEditingController>{};

    for (final cat in RoadTripBudgetCategory.values) {
      final amt = budget.categoryBudgets[cat] ?? 0.0;
      categoryControllers[cat] = TextEditingController(text: amt > 0 ? amt.toStringAsFixed(0) : '');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          double totalAllocated = 0.0;
          for (final c in categoryControllers.values) {
            final v = double.tryParse(c.text.trim()) ?? 0.0;
            totalAllocated += v;
          }

          final currentTotalBudget = double.tryParse(totalController.text.trim()) ?? budget.totalBudget;

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Budget & Line Items',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Update the total target budget and customize line item allocations.',
                    style: TextStyle(fontSize: 12, color: AppPallete.gray),
                  ),
                  const SizedBox(height: 18),

                  // Total Budget Field
                  TextField(
                    controller: totalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Total Trip Target Budget (₹)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Quick Auto-Distribution Presets
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.auto_awesome, size: 14),
                        label: const Text('Auto-Distribute Defaults', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          final t = double.tryParse(totalController.text.trim()) ?? 50000.0;
                          setSheetState(() {
                            categoryControllers[RoadTripBudgetCategory.fuel]?.text = (t * 0.20).toStringAsFixed(0);
                            categoryControllers[RoadTripBudgetCategory.accommodation]?.text = (t * 0.35).toStringAsFixed(0);
                            categoryControllers[RoadTripBudgetCategory.food]?.text = (t * 0.25).toStringAsFixed(0);
                            categoryControllers[RoadTripBudgetCategory.activities]?.text = (t * 0.10).toStringAsFixed(0);
                            categoryControllers[RoadTripBudgetCategory.emergency]?.text = (t * 0.10).toStringAsFixed(0);
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.balance_rounded, size: 14),
                        label: const Text('Equal Split', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          final t = double.tryParse(totalController.text.trim()) ?? 50000.0;
                          final active = categoryControllers.entries.where((e) => e.value.text.isNotEmpty).toList();
                          final count = active.isNotEmpty ? active.length : 5;
                          final perCat = (t / count).toStringAsFixed(0);
                          setSheetState(() {
                            if (active.isNotEmpty) {
                              for (final entry in active) {
                                entry.value.text = perCat;
                              }
                            } else {
                              for (final cat in RoadTripBudgetCategory.values.take(5)) {
                                categoryControllers[cat]?.text = perCat;
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Allocation Balance Summary Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppPallete.surfaceDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (totalAllocated - currentTotalBudget).abs() < 1
                            ? const Color(0xFF10B981)
                            : (totalAllocated > currentTotalBudget ? const Color(0xFFDC2626) : const Color(0xFFF59E0B)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Allocated: ₹${totalAllocated.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(
                          totalAllocated > currentTotalBudget
                              ? '₹${(totalAllocated - currentTotalBudget).toStringAsFixed(0)} over budget'
                              : '₹${(currentTotalBudget - totalAllocated).toStringAsFixed(0)} unallocated',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: totalAllocated > currentTotalBudget ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Category Line Items',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Line Items List
                  ...RoadTripBudgetCategory.values.map((cat) {
                    final ctrl = categoryControllers[cat]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cat.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(cat.icon, color: cat.color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Text(cat.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: ctrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixText: '₹ ',
                                hintText: '0',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Save All Button
                  PrimaryButton(
                    label: 'Save Budget & Line Items',
                    icon: Icons.check_rounded,
                    height: 50,
                    onPressed: () async {
                      final newTotal = double.tryParse(totalController.text.trim()) ?? budget.totalBudget;
                      final updatedCategoryBudgets = <RoadTripBudgetCategory, double>{};

                      for (final entry in categoryControllers.entries) {
                        final val = double.tryParse(entry.value.text.trim()) ?? 0.0;
                        if (val > 0) {
                          updatedCategoryBudgets[entry.key] = val;
                        }
                      }

                      final updatedBudget = budget.copyWith(
                        totalBudget: newTotal,
                        categoryBudgets: updatedCategoryBudgets,
                        updatedAt: DateTime.now(),
                      );

                      await ref.read(roadTripControllerProvider).saveBudget(updatedBudget);

                      // Also update trip.totalBudget if trip exists so other screens are synchronized
                      if (trip != null) {
                        final updatedTrip = trip.copyWith(totalBudget: newTotal);
                        await ref.read(tripRepositoryProvider).updateTrip(updatedTrip);
                        ref.invalidate(tripDetailsProvider(trip.id));
                      }

                      if (context.mounted) {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Budget updated to ₹${newTotal.toStringAsFixed(0)} with ${updatedCategoryBudgets.length} line items')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickChip(String label, double targetVal, TextEditingController controller) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        controller.text = targetVal.toStringAsFixed(0);
      },
    );
  }
}
