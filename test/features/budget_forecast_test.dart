import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/money_predictor/domain/budget_forecast_model.dart';
import 'package:cocircle/features/money_predictor/data/budget_forecast_service.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_repository.dart';

class MockExpenseRepository implements ExpenseRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BudgetForecastService Tests', () {
    late BudgetForecastService service;

    setUp(() {
      service = BudgetForecastService(expenseRepository: MockExpenseRepository());
    });

    test('calculateForecast calculates totals, burn rate, and detects overruns', () {
      final now = DateTime.now();
      final expenses = [
        ExpenseModel(
          id: 'e1',
          tripId: 't1',
          title: 'Beach Resort Advance',
          amount: 35000.0,
          payerId: 'u1',
          payers: {'u1': 35000.0},
          date: now,
          category: 'accommodation',
          createdAt: now,
          createdBy: 'u1',
          splitType: SplitType.equal,
          splitDetails: {'u1': 17500.0, 'u2': 17500.0},
        ),
      ];

      final commitments = [
        BudgetCommitment(
          id: 'c1',
          tripId: 't1',
          title: 'Private Cab Hire',
          category: 'transport',
          estimatedCost: 25000.0,
          createdBy: 'u1',
          createdAt: now,
        ),
      ];

      // Target budget 80,000, spent 35,000, committed 25,000 => Available 20,000
      final result = service.calculateForecast(
        targetBudget: 80000.0,
        expenses: expenses,
        commitments: commitments,
        memberCount: 8,
      );

      expect(result.actualSpent, equals(35000.0));
      expect(result.committedTotal, equals(25000.0));
      expect(result.projectedFinalSpend, equals(60000.0));
      expect(result.availableBudget, equals(20000.0));
      expect(result.isOverBudget, isFalse);
      expect(result.spentPercentage, equals(43.75));
      expect(result.committedPercentage, equals(31.25));
      expect(result.projectedPerPerson, equals(7500.0));
    });

    test('runWhatIfSimulation recalculates cost per person on member dropouts', () {
      // 8 members, ₹80,000 total spend => ₹10,000/person
      final scenario = service.runWhatIfSimulation(
        currentProjectedSpend: 80000.0,
        currentMembers: 8,
        memberDelta: -2, // 2 members cancel => 6 members
        priceChangePercent: 0.0,
        durationDeltaDays: 0,
      );

      expect(scenario.simulatedPerPerson > scenario.basePerPerson, isTrue);
      expect(scenario.deltaPerPerson > 0, isTrue);
      expect(scenario.insight.contains('drop out'), isTrue);
    });
  });
}
