import '../../trips/domain/trip_model.dart';
import '../../trips/domain/trip_participant_model.dart';
import '../../financial/expenses/domain/expense_model.dart';
import '../../financial/payments/domain/guest_payment_model.dart';
import '../../financial/settlements/domain/settlement_model.dart';
import '../../../core/finance/exact_money_calculator.dart';
import '../domain/expense_report_config.dart';

class ExpenseReportDataAggregator {
  ExpenseReportDataAggregator._();

  static ExpenseReportData aggregate({
    required TripModel trip,
    required List<TripParticipantModel> allParticipants,
    required List<ExpenseModel> allExpenses,
    required List<GuestPaymentModel> allPayments,
    required List<SettlementAdjustmentModel> allAdjustments,
    required String currency,
    required String generatedBy,
    required ExpenseReportFilter filter,
  }) {
    final now = DateTime.now();

    // 1. Determine active date window from filter
    DateTime? windowStart;
    DateTime? windowEnd;

    switch (filter.datePreset) {
      case ExpenseDateRangePreset.allDates:
        windowStart = null;
        windowEnd = null;
        break;
      case ExpenseDateRangePreset.today:
        windowStart = DateTime(now.year, now.month, now.day);
        windowEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ExpenseDateRangePreset.last7Days:
        windowStart = now.subtract(const Duration(days: 7));
        windowEnd = now;
        break;
      case ExpenseDateRangePreset.last30Days:
        windowStart = now.subtract(const Duration(days: 30));
        windowEnd = now;
        break;
      case ExpenseDateRangePreset.custom:
        windowStart = filter.customStartDate != null
            ? DateTime(filter.customStartDate!.year, filter.customStartDate!.month, filter.customStartDate!.day)
            : null;
        windowEnd = filter.customEndDate != null
            ? DateTime(filter.customEndDate!.year, filter.customEndDate!.month, filter.customEndDate!.day, 23, 59, 59)
            : null;
        break;
    }

    // 2. Filter Expenses
    final filteredExpenses = allExpenses.where((e) {
      if (windowStart != null && e.date.isBefore(windowStart)) return false;
      if (windowEnd != null && e.date.isAfter(windowEnd)) return false;

      if (filter.selectedCategory != null && filter.selectedCategory!.isNotEmpty) {
        if (e.category.toLowerCase() != filter.selectedCategory!.toLowerCase()) {
          return false;
        }
      }

      if (filter.selectedParticipantId != null) {
        final pid = filter.selectedParticipantId!;
        final isPayer = e.payerId == pid || e.payers.containsKey(pid);
        final isParticipant = e.splitDetails.containsKey(pid);
        if (!isPayer && !isParticipant) return false;
      }

      return true;
    }).toList();

    // Sort expenses chronologically
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    // 3. Filter Payments
    final filteredPayments = allPayments.where((p) {
      if (windowStart != null && p.paymentDate.isBefore(windowStart)) return false;
      if (windowEnd != null && p.paymentDate.isAfter(windowEnd)) return false;

      if (filter.paymentMethod != null && filter.paymentMethod!.isNotEmpty) {
        if (p.paymentMethod.toLowerCase() != filter.paymentMethod!.toLowerCase()) {
          return false;
        }
      }

      if (filter.selectedParticipantId != null) {
        final pid = filter.selectedParticipantId!;
        if (p.fromMemberId != pid && p.toMemberId != pid) return false;
      }

      return true;
    }).toList();

    filteredPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    // 4. Filter Adjustments
    final filteredAdjustments = allAdjustments.where((adj) {
      if (filter.selectedParticipantId != null) {
        final pid = filter.selectedParticipantId!;
        if (adj.creditorUid != pid && adj.debtorUid != pid) return false;
      }
      return true;
    }).toList();

    // 5. Participants involved
    final participantMap = {for (final p in allParticipants) p.id: p};
    List<TripParticipantModel> activeParticipants = allParticipants;
    if (filter.selectedParticipantId != null) {
      final specific = participantMap[filter.selectedParticipantId!];
      activeParticipants = specific != null ? [specific] : allParticipants;
    }

    // 6. Authoritative Balance Calculations using ExactMoneyCalculator
    // Even if filtered, balances must accurately reflect the mathematical state of participants
    final allParticipantIds = allParticipants.map((p) => p.id).toList();
    final balances = ExactMoneyCalculator.calculateBalances(
      participantIds: allParticipantIds,
      expenses: filteredExpenses,
      guestPayments: filteredPayments,
      adjustments: filteredAdjustments,
    );

    // 7. Category Breakdowns
    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryCounts = {};
    for (final e in filteredExpenses) {
      final cat = e.category.isEmpty ? 'Miscellaneous' : e.category;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + e.amount;
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    // 8. Overall KPI Aggregations
    final totalExpenses = filteredExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final totalContributed = filteredPayments.fold<double>(0.0, (sum, p) => sum + p.amount);

    double totalOutstanding = 0.0;
    if (filter.selectedParticipantId != null) {
      final b = balances[filter.selectedParticipantId!];
      totalOutstanding = b?.amountOwed ?? 0.0;
    } else {
      for (final b in balances.values) {
        if (b.owes) {
          totalOutstanding += b.amountOwed;
        }
      }
    }

    final participantCount = activeParticipants.isNotEmpty ? activeParticipants.length : 1;
    final avgPerPerson = totalExpenses > 0 ? (totalExpenses / participantCount) : 0.0;

    final registeredCount = allParticipants.where((p) => p.isRegistered).length;
    final guestCount = allParticipants.where((p) => p.isGuest).length;

    // 9. Multilateral Settlement Optimization
    final settlements = ExactMoneyCalculator.optimizeSettlements(balances);

    return ExpenseReportData(
      tripId: trip.id,
      tripName: trip.name,
      destination: trip.location,
      tripStartDate: trip.startDate,
      tripEndDate: trip.endDate,
      currency: currency,
      generatedAt: now,
      generatedBy: generatedBy,
      filter: filter,
      participants: allParticipants,
      expenses: filteredExpenses,
      payments: filteredPayments,
      adjustments: filteredAdjustments,
      totalExpenses: totalExpenses,
      totalContributed: totalContributed,
      totalOutstanding: totalOutstanding,
      averagePerParticipant: avgPerPerson,
      registeredCount: registeredCount,
      guestCount: guestCount,
      categoryTotals: categoryTotals,
      categoryCounts: categoryCounts,
      balances: balances,
      optimizedSettlements: settlements,
    );
  }
}
