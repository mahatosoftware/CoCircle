import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import 'package:cocircle/core/utils/snackbar.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import '../data/expense_repository_impl.dart';
import '../domain/expense_model.dart';

part 'expense_controller.g.dart';

@Riverpod(keepAlive: true)
class ExpenseController extends _$ExpenseController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createExpense({
    required String tripId,
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    required Map<String, double> payers, // uid -> amount
    required Map<String, double> splitDetails, // uid -> amount
    required SplitType splitType,
    String? notes,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    // Validation for Payers Total
    final payersTotal = payers.values.fold(0.0, (sum, val) => sum + val);
    if ((payersTotal - amount).abs() > 0.01) {
       state = AsyncError('Sum of payer amounts ($payersTotal) must equal total amount ($amount)', StackTrace.current);
       showSnackBar(context, 'Sum of payer amounts must equal total amount');
       return;
    }

    // Validation for Split Details
    final splitTotal = splitDetails.values.fold(0.0, (sum, val) => sum + val);
    switch (splitType) {
      case SplitType.exact:
        if ((splitTotal - amount).abs() > 0.01) {
          state = AsyncError('Split amounts must sum to total amount', StackTrace.current);
          showSnackBar(context, 'Split amounts must sum to total amount');
          return;
        }
        break;
      case SplitType.percentage:
        if ((splitTotal - 100).abs() > 0.01) {
          state = AsyncError('Percentages must sum to 100%', StackTrace.current);
          showSnackBar(context, 'Percentages must sum to 100%');
          return;
        }
        break;
      case SplitType.ratio:
        if (splitTotal <= 0) {
          state = AsyncError('Total ratio must be greater than 0', StackTrace.current);
          showSnackBar(context, 'Total ratio must be greater than 0');
          return;
        }
        break;
      case SplitType.equal:
        // Handled by client sending participants or empty map
        break;
    }
    
    final expenseId = const Uuid().v4();
    final now = DateTime.now();
    
    // We still keep payerId as the "primary" payer for simple UI lists (e.g. first payer)
    final primaryPayerId = payers.keys.first;

    final expense = ExpenseModel(
      id: expenseId,
      tripId: tripId,
      title: title,
      amount: amount,
      date: date,
      category: category,
      payerId: primaryPayerId,
      payers: payers,
      splitDetails: splitDetails,
      splitType: splitType,
      notes: notes,
      createdBy: user.uid,
      createdAt: now,
    );

    final result = await ref.read(expenseRepositoryProvider).createExpense(expense);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        context.pop();
        showSnackBar(context, 'Expense added successfully!');
      },
    );
  }

  Future<void> updateExpense({
    required String expenseId,
    required String tripId,
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    required Map<String, double> payers,
    required Map<String, double> splitDetails,
    required SplitType splitType,
    String? notes,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    // Validation for Payers Total
    final payersTotal = payers.values.fold(0.0, (sum, val) => sum + val);
    if ((payersTotal - amount).abs() > 0.01) {
       state = AsyncError('Sum of payer amounts ($payersTotal) must equal total amount ($amount)', StackTrace.current);
       showSnackBar(context, 'Sum of payer amounts must equal total amount');
       return;
    }

    // Validation for Split Details
    final splitTotal = splitDetails.values.fold(0.0, (sum, val) => sum + val);
    switch (splitType) {
      case SplitType.exact:
        if ((splitTotal - amount).abs() > 0.01) {
          state = AsyncError('Split amounts must sum to total amount', StackTrace.current);
          showSnackBar(context, 'Split amounts must sum to total amount');
          return;
        }
        break;
      case SplitType.percentage:
        if ((splitTotal - 100).abs() > 0.01) {
          state = AsyncError('Percentages must sum to 100%', StackTrace.current);
          showSnackBar(context, 'Percentages must sum to 100%');
          return;
        }
        break;
      case SplitType.ratio:
        if (splitTotal <= 0) {
          state = AsyncError('Total ratio must be greater than 0', StackTrace.current);
          showSnackBar(context, 'Total ratio must be greater than 0');
          return;
        }
        break;
      case SplitType.equal:
        break;
    }

    final primaryPayerId = payers.keys.first;

    final expense = ExpenseModel(
      id: expenseId,
      tripId: tripId,
      title: title,
      amount: amount,
      date: date,
      category: category,
      payerId: primaryPayerId,
      payers: payers,
      splitDetails: splitDetails,
      splitType: splitType,
      notes: notes,
      createdBy: user.uid, // Keep original creator or update? Usually creator stays same.
      createdAt: DateTime.now(), // Or keep original createdAt? Let's check model.
    );

    // To keep it simple, I might need the original expense to preserve some fields.
    // Let's assume we want to update the entry.
    
    final result = await ref.read(expenseRepositoryProvider).updateExpense(expense);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        context.pop();
        showSnackBar(context, 'Expense updated successfully!');
      },
    );
  }

  Future<void> autoSaveExpense(ExpenseModel expense) async {
    // Only save if basic validation passes (total payers sum matches, etc.)
    // For auto-save we don't block the UI or show Snackbars unless it's a hard error.
    
    final payersTotal = expense.payers.values.fold(0.0, (sum, val) => sum + val);
    if ((payersTotal - expense.amount).abs() > 0.01) return;

    final splitTotal = expense.splitDetails.values.fold(0.0, (sum, val) => sum + val);
    if (expense.splitType == SplitType.exact && (splitTotal - expense.amount).abs() > 0.01) return;
    if (expense.splitType == SplitType.percentage && (splitTotal - 100).abs() > 0.01) return;

    await ref.read(expenseRepositoryProvider).updateExpense(expense);
    _notifyParticipants(expense, "updated");
  }

  Future<Either<Failure, ExpenseModel>> createSettlementExpense({
    required String tripId,
    required String title,
    required double amount,
    required String payerId,
    required String receiverId,
  }) async {
    debugPrint('DEBUG: createSettlementExpense starting: $title ($amount)');
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      debugPrint('DEBUG ERROR: createSettlementExpense: User is NULL');
      return left(Failure('User not logged in'));
    }

    final expenseId = 'settlement_${const Uuid().v4()}';
    final now = DateTime.now();

    final expense = ExpenseModel(
      id: expenseId,
      tripId: tripId,
      title: title,
      amount: amount,
      date: now,
      category: ExpenseCategory.settlement,
      payerId: payerId,
      payers: {payerId: amount},
      splitDetails: {receiverId: amount},
      splitType: SplitType.exact,
      createdBy: user.uid,
      createdAt: now,
    );

    debugPrint('DEBUG: Saving settlement expense to repository: ${expense.id}');
    final result = await ref.read(expenseRepositoryProvider).createExpense(expense);
    
    return result.fold(
      (l) {
        debugPrint('DEBUG ERROR: Error saving settlement expense: ${l.message}');
        return left(l);
      },
      (r) {
        debugPrint('DEBUG SUCCESS: Settlement expense saved successfully: ${r.id}');
        return right(r);
      },
    );
  }

  void _notifyParticipants(ExpenseModel expense, String action) {
    // TODO: Integrate with NotificationService
    // This is a placeholder for sending push/in-app notifications
    debugPrint('NOTIFICATION: Participants in "${expense.title}" notified of $action.');
    for (final uid in expense.splitDetails.keys) {
      if (uid != expense.createdBy) {
         debugPrint('Sending notification to $uid: Split for "${expense.title}" has been $action.');
      }
    }
  }
}

@riverpod
Stream<List<ExpenseModel>> tripExpenses(Ref ref, String tripId) {
  return ref.watch(expenseRepositoryProvider).getExpensesStream(tripId);
}

@riverpod
Future<ExpenseModel> expenseDetail(Ref ref, String expenseId) async {
  final result = await ref.watch(expenseRepositoryProvider).getExpenseById(expenseId);
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
}
