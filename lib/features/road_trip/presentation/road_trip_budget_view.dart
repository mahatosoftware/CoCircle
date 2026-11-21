import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_pallete.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
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
        final activeBudget = budget ??
            RoadTripBudgetModel(
              id: const Uuid().v4(),
              tripId: widget.tripId,
              totalBudget: trip?.totalBudget ?? 50000.0,
              currency: '₹',
              categoryBudgets: {
                RoadTripBudgetCategory.fuel: (trip?.totalBudget ?? 50000.0) * 0.20,
                RoadTripBudgetCategory.accommodation: (trip?.totalBudget ?? 50000.0) * 0.35,
                RoadTripBudgetCategory.food: (trip?.totalBudget ?? 50000.0) * 0.25,
                RoadTripBudgetCategory.activities: (trip?.totalBudget ?? 50000.0) * 0.10,
                RoadTripBudgetCategory.emergency: (trip?.totalBudget ?? 50000.0) * 0.10,
              },
              dailyBudgets: {
                1: (trip?.totalBudget ?? 50000.0) * 0.3,
                2: (trip?.totalBudget ?? 50000.0) * 0.3,
                3: (trip?.totalBudget ?? 50000.0) * 0.4,
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
                  _buildOverviewSection(context, report, isDark)
                else if (_selectedTab == 1)
                  _buildCategoryBreakdownSection(context, report, isDark)
                else
                  _buildDayWiseSection(context, report, isDark),

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
              onPressed: () => _showEditBudgetDialog(context, activeBudget),
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

  Widget _buildOverviewSection(BuildContext context, BudgetUtilizationReport report, bool isDark) {
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

        // Quick Top Spending Categories
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
              const Text('Spending Snapshot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...RoadTripBudgetCategory.values.take(4).map((cat) {
                final spent = report.categorySpent[cat] ?? 0.0;
                final limit = report.categoryBudgetLimits[cat] ?? 1.0;
                final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.displayName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text('₹${spent.toStringAsFixed(0)} / ₹${limit.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, color: AppPallete.gray, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: ratio,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppPallete.indigo),
                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownSection(BuildContext context, BudgetUtilizationReport report, bool isDark) {
    return Column(
      children: RoadTripBudgetCategory.values.map((cat) {
        final spent = report.categorySpent[cat] ?? 0.0;
        final limit = report.categoryBudgetLimits[cat] ?? 0.0;
        final pct = limit > 0 ? (spent / limit) * 100 : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cat.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    '₹${spent.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppPallete.navy),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Allocated: ₹${limit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
                  Text(
                    limit > 0 ? '${pct.toStringAsFixed(0)}% utilized' : 'No limit set',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: pct > 100 ? const Color(0xFFDC2626) : AppPallete.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayWiseSection(BuildContext context, BudgetUtilizationReport report, bool isDark) {
    final days = [1, 2, 3, 4, 5];
    return Column(
      children: days.map((dayNum) {
        final spent = report.daySpent[dayNum] ?? 0.0;
        final budget = report.dayBudgetLimits[dayNum] ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppPallete.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          ),
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
                    Text('Day $dayNum Itinerary Budget', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('Allocated: ₹${budget.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppPallete.gray)),
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
                      color: spent > budget && budget > 0 ? const Color(0xFFDC2626) : (isDark ? Colors.white : AppPallete.navy),
                    ),
                  ),
                  const Text('Actual Spent', style: TextStyle(fontSize: 10, color: AppPallete.gray)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showEditBudgetDialog(BuildContext context, RoadTripBudgetModel budget) {
    final totalController = TextEditingController(text: budget.totalBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Target Budget'),
        content: TextField(
          controller: totalController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Total Trip Budget (₹)',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTotal = double.tryParse(totalController.text) ?? budget.totalBudget;
              final updated = budget.copyWith(
                totalBudget: newTotal,
                updatedAt: DateTime.now(),
              );
              ref.read(roadTripControllerProvider).saveBudget(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
