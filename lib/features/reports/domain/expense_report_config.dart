import 'package:flutter/foundation.dart';
import '../../trips/domain/trip_participant_model.dart';
import '../../financial/expenses/domain/expense_model.dart';
import '../../financial/payments/domain/guest_payment_model.dart';
import '../../financial/settlements/domain/settlement_model.dart';
import '../../../core/finance/exact_money_calculator.dart';

enum ExpenseReportType {
  completeTrip,
  expenseTransactions,
  participantWise,
  categoryWise,
  payments,
  settlements,
  outstandingBalances,
  completeFinancialStatement,
}

extension ExpenseReportTypeExtension on ExpenseReportType {
  String get displayName {
    switch (this) {
      case ExpenseReportType.completeTrip:
        return 'Complete Trip Expense Report';
      case ExpenseReportType.expenseTransactions:
        return 'Expense Transaction Report';
      case ExpenseReportType.participantWise:
        return 'Participant-wise Expense Report';
      case ExpenseReportType.categoryWise:
        return 'Category-wise Expense Report';
      case ExpenseReportType.payments:
        return 'Payment & Contribution Report';
      case ExpenseReportType.settlements:
        return 'Settlement Report';
      case ExpenseReportType.outstandingBalances:
        return 'Outstanding Balance Report';
      case ExpenseReportType.completeFinancialStatement:
        return 'Complete Financial Statement';
    }
  }

  String get shortName {
    switch (this) {
      case ExpenseReportType.completeTrip:
        return 'Complete Report';
      case ExpenseReportType.expenseTransactions:
        return 'Transactions';
      case ExpenseReportType.participantWise:
        return 'Participant Statement';
      case ExpenseReportType.categoryWise:
        return 'Categories';
      case ExpenseReportType.payments:
        return 'Payments';
      case ExpenseReportType.settlements:
        return 'Settlements';
      case ExpenseReportType.outstandingBalances:
        return 'Balances';
      case ExpenseReportType.completeFinancialStatement:
        return 'Financial Statement';
    }
  }
}

enum ExpenseReportFormat {
  pdf,
  excel,
  csv,
}

extension ExpenseReportFormatExtension on ExpenseReportFormat {
  String get displayName {
    switch (this) {
      case ExpenseReportFormat.pdf:
        return 'PDF Document (.pdf)';
      case ExpenseReportFormat.excel:
        return 'Excel Workbook (.xlsx)';
      case ExpenseReportFormat.csv:
        return 'CSV Spreadsheet (.csv)';
    }
  }

  String get extensionName {
    switch (this) {
      case ExpenseReportFormat.pdf:
        return 'pdf';
      case ExpenseReportFormat.excel:
        return 'xlsx';
      case ExpenseReportFormat.csv:
        return 'csv';
    }
  }

  String get mimeType {
    switch (this) {
      case ExpenseReportFormat.pdf:
        return 'application/pdf';
      case ExpenseReportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExpenseReportFormat.csv:
        return 'text/csv';
    }
  }
}

enum ExpenseDateRangePreset {
  allDates,
  today,
  last7Days,
  last30Days,
  custom,
}

extension ExpenseDateRangePresetExtension on ExpenseDateRangePreset {
  String get displayName {
    switch (this) {
      case ExpenseDateRangePreset.allDates:
        return 'All Dates';
      case ExpenseDateRangePreset.today:
        return 'Today';
      case ExpenseDateRangePreset.last7Days:
        return 'Last 7 Days';
      case ExpenseDateRangePreset.last30Days:
        return 'Last 30 Days';
      case ExpenseDateRangePreset.custom:
        return 'Custom Date Range';
    }
  }
}

@immutable
class ExpenseReportFilter {
  final ExpenseReportType reportType;
  final ExpenseReportFormat format;
  final ExpenseDateRangePreset datePreset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? selectedParticipantId; // null = all participants
  final String? selectedCategory; // null = all categories
  final String? paymentMethod; // null = all methods
  final bool includeTripInfo;
  final bool includeParticipantDetails;
  final bool includeCategoryBreakdown;
  final bool includePayments;
  final bool includeSettlements;
  final bool includeAdjustments;
  final bool includeReceiptReferences;
  final bool includeNotes;

  const ExpenseReportFilter({
    this.reportType = ExpenseReportType.completeTrip,
    this.format = ExpenseReportFormat.pdf,
    this.datePreset = ExpenseDateRangePreset.allDates,
    this.customStartDate,
    this.customEndDate,
    this.selectedParticipantId,
    this.selectedCategory,
    this.paymentMethod,
    this.includeTripInfo = true,
    this.includeParticipantDetails = true,
    this.includeCategoryBreakdown = true,
    this.includePayments = true,
    this.includeSettlements = true,
    this.includeAdjustments = true,
    this.includeReceiptReferences = true,
    this.includeNotes = true,
  });

  ExpenseReportFilter copyWith({
    ExpenseReportType? reportType,
    ExpenseReportFormat? format,
    ExpenseDateRangePreset? datePreset,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? selectedParticipantId,
    String? selectedCategory,
    String? paymentMethod,
    bool? includeTripInfo,
    bool? includeParticipantDetails,
    bool? includeCategoryBreakdown,
    bool? includePayments,
    bool? includeSettlements,
    bool? includeAdjustments,
    bool? includeReceiptReferences,
    bool? includeNotes,
    bool clearParticipant = false,
    bool clearCategory = false,
  }) {
    return ExpenseReportFilter(
      reportType: reportType ?? this.reportType,
      format: format ?? this.format,
      datePreset: datePreset ?? this.datePreset,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      selectedParticipantId: clearParticipant ? null : (selectedParticipantId ?? this.selectedParticipantId),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      includeTripInfo: includeTripInfo ?? this.includeTripInfo,
      includeParticipantDetails: includeParticipantDetails ?? this.includeParticipantDetails,
      includeCategoryBreakdown: includeCategoryBreakdown ?? this.includeCategoryBreakdown,
      includePayments: includePayments ?? this.includePayments,
      includeSettlements: includeSettlements ?? this.includeSettlements,
      includeAdjustments: includeAdjustments ?? this.includeAdjustments,
      includeReceiptReferences: includeReceiptReferences ?? this.includeReceiptReferences,
      includeNotes: includeNotes ?? this.includeNotes,
    );
  }
}

/// Consolidated, immutable financial data bundle ready for report generation
class ExpenseReportData {
  final String tripId;
  final String tripName;
  final String? destination;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String currency;
  final DateTime generatedAt;
  final String generatedBy;
  final ExpenseReportFilter filter;

  // Filtered entities
  final List<TripParticipantModel> participants;
  final List<ExpenseModel> expenses;
  final List<GuestPaymentModel> payments;
  final List<SettlementAdjustmentModel> adjustments;

  // Precomputed authoritative metrics
  final double totalExpenses;
  final double totalContributed;
  final double totalOutstanding;
  final double averagePerParticipant;
  final int registeredCount;
  final int guestCount;
  final Map<String, double> categoryTotals;
  final Map<String, int> categoryCounts;
  final Map<String, ParticipantBalance> balances;
  final List<SettlementTransaction> optimizedSettlements;

  const ExpenseReportData({
    required this.tripId,
    required this.tripName,
    this.destination,
    this.tripStartDate,
    this.tripEndDate,
    required this.currency,
    required this.generatedAt,
    required this.generatedBy,
    required this.filter,
    required this.participants,
    required this.expenses,
    required this.payments,
    required this.adjustments,
    required this.totalExpenses,
    required this.totalContributed,
    required this.totalOutstanding,
    required this.averagePerParticipant,
    required this.registeredCount,
    required this.guestCount,
    required this.categoryTotals,
    required this.categoryCounts,
    required this.balances,
    required this.optimizedSettlements,
  });

  bool get isIndividualParticipantReport => filter.selectedParticipantId != null;

  TripParticipantModel? get selectedParticipant {
    if (filter.selectedParticipantId == null) return null;
    return participants.cast<TripParticipantModel?>().firstWhere(
          (p) => p?.id == filter.selectedParticipantId,
          orElse: () => null,
        );
  }
}
