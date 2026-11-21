import '../domain/settlement_model.dart';
import '../../expenses/domain/expense_model.dart';
import '../../payments/domain/guest_payment_model.dart';
import '../../../../core/finance/exact_money_calculator.dart';

class SettlementLogic {
  /// Computes optimized settlement transfers across all participants (registered + guests)
  /// using exact integer minor currency units without floating-point inaccuracies.
  static List<SettlementTransaction> calculateSettlements(
    List<ExpenseModel> expenses, [
    List<SettlementAdjustmentModel>? adjustments,
    List<GuestPaymentModel>? guestPayments,
  ]) {
    // Collect all involved participant IDs
    final participantIds = <String>{};
    for (final e in expenses) {
      participantIds.add(e.payerId);
      participantIds.addAll(e.payers.keys);
      participantIds.addAll(e.splitDetails.keys);
    }
    if (adjustments != null) {
      for (final a in adjustments) {
        participantIds.add(a.creditorUid);
        participantIds.add(a.debtorUid);
      }
    }
    if (guestPayments != null) {
      for (final p in guestPayments) {
        participantIds.add(p.fromMemberId);
        participantIds.add(p.toMemberId);
      }
    }

    final balances = ExactMoneyCalculator.calculateBalances(
      participantIds: participantIds.toList(),
      expenses: expenses,
      guestPayments: guestPayments,
      adjustments: adjustments,
    );

    return ExactMoneyCalculator.optimizeSettlements(balances);
  }

  /// Calculates exact balance for each participant.
  /// Formula: Net Balance = Total Amount Paid - Total Expense Share
  static Map<String, ParticipantBalance> calculateBalances({
    required List<String> participantIds,
    required List<ExpenseModel> expenses,
    List<GuestPaymentModel>? guestPayments,
    List<SettlementAdjustmentModel>? adjustments,
  }) {
    return ExactMoneyCalculator.calculateBalances(
      participantIds: participantIds,
      expenses: expenses,
      guestPayments: guestPayments,
      adjustments: adjustments,
    );
  }
}
