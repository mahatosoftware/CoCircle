import 'dart:math' as math;
import '../../features/financial/expenses/domain/expense_model.dart';
import '../../features/financial/payments/domain/guest_payment_model.dart';
import '../../features/financial/settlements/domain/settlement_model.dart';

class ParticipantBalance {
  final String participantId;
  final int totalPaidPaise;
  final int totalSharePaise;

  const ParticipantBalance({
    required this.participantId,
    required this.totalPaidPaise,
    required this.totalSharePaise,
  });

  int get netBalancePaise => totalPaidPaise - totalSharePaise;
  int get netPaise => netBalancePaise;
  double get totalPaid => totalPaidPaise / 100.0;
  double get totalPaidAmount => totalPaid;
  double get totalShare => totalSharePaise / 100.0;
  double get totalShareAmount => totalShare;
  double get netBalance => netBalancePaise / 100.0;
  double get netAmount => netBalance;

  bool get isSettled => netBalancePaise == 0;
  bool get shouldReceive => netBalancePaise > 0;
  bool get owes => netBalancePaise < 0;

  double get amountOwed => owes ? (-netBalancePaise / 100.0) : 0.0;
  double get amountToReceive => shouldReceive ? (netBalancePaise / 100.0) : 0.0;
}

class ExactMoneyCalculator {
  ExactMoneyCalculator._();

  static int toPaise(double amount) => (amount * 100).round();
  static double toCurrency(int paise) => paise / 100.0;

  /// Equal split across participants with integer remainder distribution.
  /// Guarantees sum of splits == totalAmount down to the exact paisa/cent.
  static Map<String, double> calculateEqualSplit(
    double totalAmount,
    List<String> participantIds,
  ) {
    if (participantIds.isEmpty) return {};
    final totalPaise = toPaise(totalAmount);
    final count = participantIds.length;
    final baseShare = totalPaise ~/ count;
    var remainder = totalPaise % count;

    final result = <String, double>{};
    for (int i = 0; i < count; i++) {
      final sharePaise = baseShare + (i < remainder ? 1 : 0);
      result[participantIds[i]] = toCurrency(sharePaise);
    }
    return result;
  }

  /// Percentage split with rounding remainder allocation to largest shareholder.
  static Map<String, double> calculatePercentageSplit(
    double totalAmount,
    Map<String, double> percentages,
  ) {
    if (percentages.isEmpty) return {};
    final totalPaise = toPaise(totalAmount);
    final result = <String, double>{};
    int runningSum = 0;
    String? maxKey;
    double maxPct = -1.0;

    for (final entry in percentages.entries) {
      if (entry.value > maxPct) {
        maxPct = entry.value;
        maxKey = entry.key;
      }
      final sharePaise = ((entry.value / 100.0) * totalPaise).round();
      result[entry.key] = toCurrency(sharePaise);
      runningSum += sharePaise;
    }

    final diff = totalPaise - runningSum;
    if (diff != 0 && maxKey != null) {
      final currentPaise = toPaise(result[maxKey]!);
      result[maxKey] = toCurrency(currentPaise + diff);
    }

    return result;
  }

  /// Share/Ratio-based split with exact integer remainder allocation.
  static Map<String, double> calculateRatioSplit(
    double totalAmount,
    Map<String, double> ratios,
  ) {
    if (ratios.isEmpty) return {};
    final totalRatio = ratios.values.fold<double>(0.0, (sum, val) => sum + val);
    if (totalRatio <= 0) return {};

    final totalPaise = toPaise(totalAmount);
    final result = <String, double>{};
    int runningSum = 0;
    String? maxKey;
    double maxRatio = -1.0;

    for (final entry in ratios.entries) {
      if (entry.value > maxRatio) {
        maxRatio = entry.value;
        maxKey = entry.key;
      }
      final sharePaise = ((entry.value / totalRatio) * totalPaise).round();
      result[entry.key] = toCurrency(sharePaise);
      runningSum += sharePaise;
    }

    final diff = totalPaise - runningSum;
    if (diff != 0 && maxKey != null) {
      final currentPaise = toPaise(result[maxKey]!);
      result[maxKey] = toCurrency(currentPaise + diff);
    }

    return result;
  }

  /// Calculates net balances for all participants across expenses, direct guest payments,
  /// and approved debt write-offs using integer minor currency units.
  /// Formula: Net Balance = Total Amount Paid - Total Expense Share
  static Map<String, ParticipantBalance> calculateBalances({
    required List<String> participantIds,
    required List<ExpenseModel> expenses,
    List<GuestPaymentModel>? guestPayments,
    List<SettlementAdjustmentModel>? adjustments,
  }) {
    final paidMap = <String, int>{};
    final shareMap = <String, int>{};

    for (final id in participantIds) {
      paidMap[id] = 0;
      shareMap[id] = 0;
    }

    // 1. Process Expenses
    for (final expense in expenses) {
      // Add contributions to payer
      if (expense.payers.isNotEmpty) {
        expense.payers.forEach((uid, amt) {
          paidMap[uid] = (paidMap[uid] ?? 0) + toPaise(amt);
        });
      } else {
        paidMap[expense.payerId] = (paidMap[expense.payerId] ?? 0) + toPaise(expense.amount);
      }

      // Add expense shares
      final totalPaise = toPaise(expense.amount);
      switch (expense.splitType) {
        case SplitType.equal:
          if (expense.splitDetails.isNotEmpty) {
            final count = expense.splitDetails.length;
            final baseShare = totalPaise ~/ count;
            var rem = totalPaise % count;
            var idx = 0;
            for (final uid in expense.splitDetails.keys) {
              final share = baseShare + (idx < rem ? 1 : 0);
              shareMap[uid] = (shareMap[uid] ?? 0) + share;
              idx++;
            }
          }
          break;

        case SplitType.exact:
          expense.splitDetails.forEach((uid, amt) {
            shareMap[uid] = (shareMap[uid] ?? 0) + toPaise(amt);
          });
          break;

        case SplitType.percentage:
          final split = calculatePercentageSplit(expense.amount, expense.splitDetails);
          split.forEach((uid, amt) {
            shareMap[uid] = (shareMap[uid] ?? 0) + toPaise(amt);
          });
          break;

        case SplitType.ratio:
          final split = calculateRatioSplit(expense.amount, expense.splitDetails);
          split.forEach((uid, amt) {
            shareMap[uid] = (shareMap[uid] ?? 0) + toPaise(amt);
          });
          break;
      }
    }

    // 2. Process Direct Payments (Recorded payments between members/guests)
    if (guestPayments != null) {
      for (final payment in guestPayments) {
        if (payment.paymentStatus == 'completed' || payment.paymentStatus == 'verified') {
          final amtPaise = toPaise(payment.amount);
          // Payer gave money (+paid)
          paidMap[payment.fromMemberId] = (paidMap[payment.fromMemberId] ?? 0) + amtPaise;
          // Receiver received money (+share / debt reduction)
          shareMap[payment.toMemberId] = (shareMap[payment.toMemberId] ?? 0) + amtPaise;
        }
      }
    }

    // 3. Process Debt Write-offs & Waivers
    if (adjustments != null) {
      for (final adj in adjustments) {
        if (adj.approvedByCreditor) {
          final amtPaise = toPaise(adj.amount);
          // Creditor waives credit
          paidMap[adj.creditorUid] = (paidMap[adj.creditorUid] ?? 0) - amtPaise;
          // Debtor debt reduced
          shareMap[adj.debtorUid] = (shareMap[adj.debtorUid] ?? 0) - amtPaise;
        }
      }
    }

    // Assemble final balances
    final balances = <String, ParticipantBalance>{};
    final allKeys = {...participantIds, ...paidMap.keys, ...shareMap.keys};

    for (final id in allKeys) {
      balances[id] = ParticipantBalance(
        participantId: id,
        totalPaidPaise: paidMap[id] ?? 0,
        totalSharePaise: shareMap[id] ?? 0,
      );
    }

    return balances;
  }

  /// Calculates simplified settlement transactions (Min-Cash-Flow)
  /// using exact integer arithmetic with zero floating point drift.
  static List<SettlementTransaction> optimizeSettlements(
    Map<String, ParticipantBalance> balances,
  ) {
    final debtors = <MapEntry<String, int>>[];
    final creditors = <MapEntry<String, int>>[];

    balances.forEach((id, b) {
      if (b.netBalancePaise < 0) {
        debtors.add(MapEntry(id, b.netBalancePaise));
      } else if (b.netBalancePaise > 0) {
        creditors.add(MapEntry(id, b.netBalancePaise));
      }
    });

    debtors.sort((a, b) => a.value.compareTo(b.value)); // Most negative first
    creditors.sort((a, b) => b.value.compareTo(a.value)); // Most positive first

    final mutableDebtors = List<MapEntry<String, int>>.from(debtors);
    final mutableCreditors = List<MapEntry<String, int>>.from(creditors);

    final transactions = <SettlementTransaction>[];
    int dIdx = 0;
    int cIdx = 0;

    while (dIdx < mutableDebtors.length && cIdx < mutableCreditors.length) {
      final debtor = mutableDebtors[dIdx];
      final creditor = mutableCreditors[cIdx];

      final debitAmount = -debtor.value;
      final creditAmount = creditor.value;

      final transferPaise = math.min(debitAmount, creditAmount);
      if (transferPaise > 0) {
        transactions.add(
          SettlementTransaction(
            fromUid: debtor.key,
            toUid: creditor.key,
            amount: toCurrency(transferPaise),
          ),
        );
      }

      final newDebtorValue = debtor.value + transferPaise;
      final newCreditorValue = creditor.value - transferPaise;

      mutableDebtors[dIdx] = MapEntry(debtor.key, newDebtorValue);
      mutableCreditors[cIdx] = MapEntry(creditor.key, newCreditorValue);

      if (newDebtorValue == 0) dIdx++;
      if (newCreditorValue == 0) cIdx++;
    }

    return transactions;
  }
}
