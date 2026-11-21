import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_logic.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_model.dart';

void main() {
  final now = DateTime.now();

  group('SettlementLogic with Adjustments and Waivers', () {
    test('Calculates simple settlement between two users correctly without adjustments', () {
      final expense = ExpenseModel(
        id: 'exp1',
        tripId: 'trip1',
        title: 'Dinner',
        amount: 1000.0,
        date: now,
        category: 'food',
        payerId: 'userA',
        splitType: SplitType.equal,
        payers: {'userA': 1000.0},
        splitDetails: {'userA': 500.0, 'userB': 500.0},
        createdBy: 'userA',
        createdAt: now,
      );

      final settlements = SettlementLogic.calculateSettlements([expense]);
      expect(settlements.length, equals(1));
      expect(settlements.first.fromUid, equals('userB'));
      expect(settlements.first.toUid, equals('userA'));
      expect(settlements.first.amount, equals(500.0));
    });

    test('Applies voluntary debt write-off/waiver to reduce settlement transaction', () {
      final expense = ExpenseModel(
        id: 'exp1',
        tripId: 'trip1',
        title: 'Dinner',
        amount: 1000.0,
        date: now,
        category: 'food',
        payerId: 'userA',
        splitType: SplitType.equal,
        payers: {'userA': 1000.0},
        splitDetails: {'userA': 500.0, 'userB': 500.0},
        createdBy: 'userA',
        createdAt: now,
      );

      // UserA waives 200 of UserB's debt
      final adjustment = SettlementAdjustmentModel(
        id: 'adj1',
        tripId: 'trip1',
        creditorUid: 'userA',
        debtorUid: 'userB',
        amount: 200.0,
        reason: 'Birthday discount / friendly treat',
        createdAt: now,
        approvedByCreditor: true,
      );

      final settlements = SettlementLogic.calculateSettlements([expense], [adjustment]);
      expect(settlements.length, equals(1));
      expect(settlements.first.fromUid, equals('userB'));
      expect(settlements.first.toUid, equals('userA'));
      expect(settlements.first.amount, equals(300.0));
    });

    test('Full waiver results in zero settlements required', () {
      final expense = ExpenseModel(
        id: 'exp1',
        tripId: 'trip1',
        title: 'Cab Ride',
        amount: 600.0,
        date: now,
        category: 'travel',
        payerId: 'userA',
        splitType: SplitType.equal,
        payers: {'userA': 600.0},
        splitDetails: {'userA': 300.0, 'userB': 300.0},
        createdBy: 'userA',
        createdAt: now,
      );

      // UserA waives all 300 of UserB's debt
      final adjustment = SettlementAdjustmentModel(
        id: 'adj2',
        tripId: 'trip1',
        creditorUid: 'userA',
        debtorUid: 'userB',
        amount: 300.0,
        reason: 'Covered as gift',
        createdAt: now,
        approvedByCreditor: true,
      );

      final settlements = SettlementLogic.calculateSettlements([expense], [adjustment]);
      expect(settlements.isEmpty, isTrue);
    });
  });
}
