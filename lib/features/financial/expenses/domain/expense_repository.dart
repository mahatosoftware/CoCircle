import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../domain/expense_model.dart';

abstract interface class ExpenseRepository {
  Future<Either<Failure, ExpenseModel>> createExpense(ExpenseModel expense);
  Future<Either<Failure, ExpenseModel>> updateExpense(ExpenseModel expense);
  Future<Either<Failure, List<ExpenseModel>>> getExpensesForTrip(String tripId);
  Future<Either<Failure, ExpenseModel>> getExpenseById(String expenseId);
  Stream<List<ExpenseModel>> getExpensesStream(String tripId);
}
