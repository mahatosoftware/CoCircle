import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import '../domain/expense_model.dart';
import '../domain/audit_log_model.dart';
import '../domain/expense_repository.dart';

import '../../../notifications/domain/notification_event_model.dart';

part 'expense_repository_impl.g.dart';

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) {
  return ExpenseRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;

  ExpenseRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _expenses => _firestore.collection('expenses');
  CollectionReference<Map<String, dynamic>> get _auditLogs => _firestore.collection('audit_logs');
  CollectionReference<Map<String, dynamic>> get _notificationEvents => _firestore.collection('notification_events');

  Future<String> _resolveCircleId(String tripId) async {
    if (tripId.isEmpty) return '';
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      return tripDoc.data()?['circleId'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> createExpense(ExpenseModel expense) async {
    try {
      final circleId = await _resolveCircleId(expense.tripId);
      final eventId = 'evt_exp_created_${expense.id}';
      final event = NotificationEventModel(
        eventId: eventId,
        eventType: 'expense_created',
        expenseId: expense.id,
        tripId: expense.tripId,
        circleId: circleId,
        createdBy: expense.createdBy,
        status: 'pending',
        createdAt: DateTime.now(),
        metadata: {
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'splitDetails': expense.splitDetails,
          'payers': expense.payers,
          'payerId': expense.payerId,
        },
      );

      final batch = _firestore.batch();
      batch.set(_expenses.doc(expense.id), expense.toJson());
      batch.set(_notificationEvents.doc(eventId), event.toJson());
      await batch.commit();

      return right(expense);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseModel>> updateExpense(ExpenseModel expense) async {
    try {
      final circleId = await _resolveCircleId(expense.tripId);
      final eventId = 'evt_exp_updated_${expense.id}_${DateTime.now().millisecondsSinceEpoch}';

      // Check if split changed compared to stored expense
      String eventType = 'expense_updated';
      try {
        final existingDoc = await _expenses.doc(expense.id).get();
        if (existingDoc.exists) {
          final existing = ExpenseModel.fromJson(existingDoc.data()!);
          if (existing.calculateChanges(expense).containsKey('splitDetails')) {
            eventType = 'expense_split_changed';
          }
        }
      } catch (_) {}

      final event = NotificationEventModel(
        eventId: eventId,
        eventType: eventType,
        expenseId: expense.id,
        tripId: expense.tripId,
        circleId: circleId,
        createdBy: expense.createdBy,
        status: 'pending',
        createdAt: DateTime.now(),
        metadata: {
          'title': expense.title,
          'amount': expense.amount,
          'category': expense.category,
          'splitDetails': expense.splitDetails,
          'payers': expense.payers,
          'payerId': expense.payerId,
        },
      );

      final batch = _firestore.batch();
      batch.update(_expenses.doc(expense.id), expense.toJson());
      batch.set(_notificationEvents.doc(eventId), event.toJson());
      await batch.commit();

      return right(expense);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      final doc = await _expenses.doc(expenseId).get();
      final expenseData = doc.data() ?? {};
      final tripId = expenseData['tripId'] as String? ?? '';
      final circleId = await _resolveCircleId(tripId);
      final eventId = 'evt_exp_deleted_$expenseId';

      final event = NotificationEventModel(
        eventId: eventId,
        eventType: 'expense_deleted',
        expenseId: expenseId,
        tripId: tripId,
        circleId: circleId,
        createdBy: expenseData['createdBy'] as String? ?? '',
        status: 'pending',
        createdAt: DateTime.now(),
        metadata: {
          'title': expenseData['title'] ?? 'Expense',
          'amount': expenseData['amount'] ?? 0.0,
        },
      );

      final batch = _firestore.batch();
      batch.delete(_expenses.doc(expenseId));
      batch.set(_notificationEvents.doc(eventId), event.toJson());
      await batch.commit();

      return right(null);
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

  @override
  Stream<ExpenseModel> getExpenseStream(String expenseId) {
    return _expenses.doc(expenseId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Expense not found');
      }
      return ExpenseModel.fromJson(snapshot.data()!);
    });
  }

  @override
  Future<Either<Failure, void>> saveAuditLog(AuditLogModel log) async {
    try {
      await _auditLogs.doc(log.id).set(log.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<AuditLogModel>> getAuditLogsStream(String tripId) {
    return _auditLogs
        .where('tripId', isEqualTo: tripId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((d) => AuditLogModel.fromJson(d.data())).toList();
        });
  }
}
