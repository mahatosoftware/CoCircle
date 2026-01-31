import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/expense_model.dart';
import 'expense_repository_impl.dart';

part 'expense_stats_provider.g.dart';

@riverpod
Stream<Map<ExpenseCategory, double>> expenseCategoryStats(Ref ref, String tripId) {
  return ref.watch(expenseRepositoryProvider).getExpensesStream(tripId).map((expenses) {
    final Map<ExpenseCategory, double> stats = {};
    for (var expense in expenses) {
      if (expense.category == ExpenseCategory.settlement) continue;
      stats[expense.category] = (stats[expense.category] ?? 0) + expense.amount;
    }
    return stats;
  });
}

@riverpod
Stream<Map<String, double>> expenseMemberStats(Ref ref, String tripId) {
  return ref.watch(expenseRepositoryProvider).getExpensesStream(tripId).map((expenses) {
    final Map<String, double> stats = {};
    for (var expense in expenses) {
      if (expense.category == ExpenseCategory.settlement) continue;
      // Aggregate from 'payers' map to support multiple payers accurately
      for (var entry in expense.payers.entries) {
        stats[entry.key] = (stats[entry.key] ?? 0) + entry.value;
      }
    }
    return stats;
  });
}

@riverpod
Stream<Map<String, double>> expenseMemberShare(Ref ref, String tripId) {
  return ref.watch(expenseRepositoryProvider).getExpensesStream(tripId).map((expenses) {
    final Map<String, double> stats = {};
    for (var expense in expenses) {
      if (expense.category == ExpenseCategory.settlement) continue;
      final amount = expense.amount;
      final splitType = expense.splitType;
      final splitDetails = expense.splitDetails;

      if (splitDetails.isEmpty) continue;

      switch (splitType) {
        case SplitType.equal:
          final share = amount / splitDetails.length;
          for (var uid in splitDetails.keys) {
            stats[uid] = (stats[uid] ?? 0) + share;
          }
          break;
        case SplitType.exact:
          for (var entry in splitDetails.entries) {
            stats[entry.key] = (stats[entry.key] ?? 0) + entry.value;
          }
          break;
        case SplitType.percentage:
          for (var entry in splitDetails.entries) {
            final share = (entry.value / 100) * amount;
            stats[entry.key] = (stats[entry.key] ?? 0) + share;
          }
          break;
        case SplitType.ratio:
          final totalRatio = splitDetails.values.fold(0.0, (sum, val) => sum + val);
          if (totalRatio > 0) {
            for (var entry in splitDetails.entries) {
              final share = (entry.value / totalRatio) * amount;
              stats[entry.key] = (stats[entry.key] ?? 0) + share;
            }
          }
          break;
      }
    }
    return stats;
  });
}

@riverpod
Stream<double> tripTotalSpending(Ref ref, String tripId) {
  return ref.watch(expenseRepositoryProvider).getExpensesStream(tripId).map((expenses) {
    return expenses
        .where((e) => e.category != ExpenseCategory.settlement)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  });
}
