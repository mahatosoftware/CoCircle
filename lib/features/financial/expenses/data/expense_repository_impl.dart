import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import '../domain/expense_model.dart';
import '../domain/expense_repository.dart';

part 'expense_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _expenses => _firestore.collection('expenses');

  @override
  Future<Either<Failure, ExpenseModel>> createExpense(ExpenseModel expense) async {
    try {
      // Note: Ideally, we should use a batch write to also update the TripSummary here,
      // but per requirements, heavy logic like settlement/summary calculation might be moved to Cloud Functions.
      // For now, we just save the expense.
      await _expenses.doc(expense.id).set(expense.toJson());
      return right(expense);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> updateExpense(ExpenseModel expense) async {
    try {
      await _expenses.doc(expense.id).update(expense.toJson());
      return right(expense);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getExpensesForTrip(String tripId) async {
    try {
      final query = await _expenses
          .where('tripId', isEqualTo: tripId)
          .orderBy('date', descending: true)
          .get();
      
      final expenses = query.docs.map((d) => ExpenseModel.fromJson(d.data())).toList();
      return right(expenses);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> getExpenseById(String expenseId) async {
    try {
      final doc = await _expenses.doc(expenseId).get();
      if (!doc.exists) return left(Failure('Expense not found'));
      return right(ExpenseModel.fromJson(doc.data()!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<ExpenseModel>> getExpensesStream(String tripId) {
    return _expenses
        .where('tripId', isEqualTo: tripId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((d) => ExpenseModel.fromJson(d.data())).toList();
        });
  }
}
