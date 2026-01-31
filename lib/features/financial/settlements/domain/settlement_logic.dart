import '../domain/settlement_model.dart';
import '../../expenses/domain/expense_model.dart';

class SettlementLogic {
  static List<SettlementTransaction> calculateSettlements(List<ExpenseModel> expenses) {
    // 1. Calculate net balance for each user
    // Positive balance = User paid more than their share (needs to receive)
    // Negative balance = User paid less than their share (needs to pay)
    final balances = <String, double>{};

    for (final expense in expenses) {
      // 🟢 Add what they paid (Creditor move)
      expense.payers.forEach((uid, paidAmount) {
        balances[uid] = (balances[uid] ?? 0.0) + paidAmount;
      });

      // 🔴 Subtract what they owe (Debtor move)
      final total = expense.amount;
      
      switch (expense.splitType) {
        case SplitType.equal:
          if (expense.splitDetails.isNotEmpty) {
            final share = total / expense.splitDetails.length;
            for (final uid in expense.splitDetails.keys) {
              balances[uid] = (balances[uid] ?? 0.0) - share;
            }
          }
          break;

        case SplitType.exact:
          expense.splitDetails.forEach((uid, share) {
            balances[uid] = (balances[uid] ?? 0.0) - share;
          });
          break;

        case SplitType.percentage:
          expense.splitDetails.forEach((uid, percent) {
            final share = (percent / 100) * total;
            balances[uid] = (balances[uid] ?? 0.0) - share;
          });
          break;

        case SplitType.ratio:
          final totalRatio = expense.splitDetails.values.fold<double>(
            0.0,
            (sum, val) => sum + val,
          );

          if (totalRatio > 0) {
            expense.splitDetails.forEach((uid, ratio) {
              final share = (ratio / totalRatio) * total;
              balances[uid] = (balances[uid] ?? 0.0) - share;
            });
          }
          break;
      }
    }

    // 2. Separate into debtors and creditors
    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    balances.forEach((uid, balance) {
      if (balance < -0.01) {
        debtors.add(MapEntry(uid, balance));
      } else if (balance > 0.01) {
        creditors.add(MapEntry(uid, balance));
      }
    });

    // Sort to optimize matching
    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    final transactions = <SettlementTransaction>[];

    // 3. Match debtors and creditors (Minimize cash flow)
    int i = 0; // creditor index
    int j = 0; // debtor index

    // Copy to avoid mutating original lists during iteration if needed, 
    // but here we just use values.
    final mutableDebtors = List<MapEntry<String, double>>.from(debtors);
    final mutableCreditors = List<MapEntry<String, double>>.from(creditors);

    while (i < mutableCreditors.length && j < mutableDebtors.length) {
      final creditor = mutableCreditors[i];
      final debtor = mutableDebtors[j];

      final amountToSettle = (creditor.value < -debtor.value)
          ? creditor.value
          : -debtor.value;

      transactions.add(
        SettlementTransaction(
          fromUid: debtor.key,
          toUid: creditor.key,
          amount: double.parse(amountToSettle.toStringAsFixed(2)),
          // suggested transactions are not yet confirmed
          payerConfirmed: false,
          receiverConfirmed: false,
          isCompleted: false,
        ),
      );

      final remainingCredit = creditor.value - amountToSettle;
      final remainingDebt = debtor.value + amountToSettle;

      if (remainingCredit < 0.01) {
        i++;
      } else {
        mutableCreditors[i] = MapEntry(creditor.key, remainingCredit);
      }

      if (remainingDebt > -0.01) {
        j++;
      } else {
        mutableDebtors[j] = MapEntry(debtor.key, remainingDebt);
      }
    }

    return transactions;
  }
}
