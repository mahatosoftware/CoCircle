import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../financial/expenses/data/expense_repository_impl.dart';
import '../../financial/expenses/domain/expense_repository.dart';
import '../../financial/expenses/domain/expense_model.dart';
import '../domain/budget_forecast_model.dart';

final budgetForecastServiceProvider = Provider<BudgetForecastService>((ref) {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  return BudgetForecastService(
    firestore: FirebaseFirestore.instance,
    expenseRepository: expenseRepo,
  );
});

final tripCommitmentsProvider =
    StreamProvider.family<List<BudgetCommitment>, String>((ref, tripId) {
  return ref.watch(budgetForecastServiceProvider).getCommitmentsStream(tripId);
});

class BudgetForecastService {
  final FirebaseFirestore? _firestore;

  BudgetForecastService({
    FirebaseFirestore? firestore,
    ExpenseRepository? expenseRepository,
  })  : _firestore = firestore;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _commitmentsRef(String tripId) {
    return firestore
        .collection('trips')
        .doc(tripId)
        .collection('budgetCommitments');
  }

  Stream<List<BudgetCommitment>> getCommitmentsStream(String tripId) {
    return _commitmentsRef(tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BudgetCommitment.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> addCommitment(BudgetCommitment commitment) async {
    await _commitmentsRef(commitment.tripId)
        .doc(commitment.id)
        .set(commitment.toJson());
  }

  Future<void> deleteCommitment(String tripId, String commitmentId) async {
    await _commitmentsRef(tripId).doc(commitmentId).delete();
  }

  Future<void> updateTargetBudget(String tripId, double targetBudget) async {
    await firestore.collection('trips').doc(tripId).set({
      'targetBudget': targetBudget,
    }, SetOptions(merge: true));
  }

  BudgetForecastResult calculateForecast({
    required double targetBudget,
    required List<ExpenseModel> expenses,
    required List<BudgetCommitment> commitments,
    required int memberCount,
  }) {
    final actualSpent = expenses.fold(0.0, (total, e) => total + e.amount);
    final committedTotal =
        commitments.fold(0.0, (total, c) => total + c.estimatedCost);

    // If targetBudget is not explicitly configured, provide a default estimate
    final effectiveBudget = targetBudget > 0
        ? targetBudget
        : (actualSpent + committedTotal > 0
            ? (actualSpent + committedTotal) * 1.2
            : 50000.0);

    final projectedFinalSpend = actualSpent + committedTotal;
    final availableBudget = effectiveBudget - projectedFinalSpend;
    final isOverBudget = projectedFinalSpend > effectiveBudget;
    final overrunAmount =
        isOverBudget ? (projectedFinalSpend - effectiveBudget) : 0.0;

    final spentPercentage = effectiveBudget > 0
        ? ((actualSpent / effectiveBudget) * 100).clamp(0.0, 100.0)
        : 0.0;
    final committedPercentage = effectiveBudget > 0
        ? ((committedTotal / effectiveBudget) * 100).clamp(0.0, 100.0)
        : 0.0;

    final count = memberCount > 0 ? memberCount : 1;
    final projectedPerPerson = projectedFinalSpend / count;

    // Category breakdown
    final categoryMap = <String, Map<String, double>>{};
    for (final e in expenses) {
      final cat = e.category.toLowerCase();
      categoryMap.putIfAbsent(cat, () => {'spent': 0.0, 'committed': 0.0});
      categoryMap[cat]!['spent'] = (categoryMap[cat]!['spent'] ?? 0.0) + e.amount;
    }

    for (final c in commitments) {
      final cat = c.category.toLowerCase();
      categoryMap.putIfAbsent(cat, () => {'spent': 0.0, 'committed': 0.0});
      categoryMap[cat]!['committed'] =
          (categoryMap[cat]!['committed'] ?? 0.0) + c.estimatedCost;
    }

    final categoryBreakdown = <String, CategorySpendSummary>{};
    categoryMap.forEach((cat, vals) {
      final s = vals['spent'] ?? 0.0;
      final c = vals['committed'] ?? 0.0;
      categoryBreakdown[cat] = CategorySpendSummary(
        category: cat,
        spent: s,
        committed: c,
        totalProjected: s + c,
      );
    });

    // Anomaly Detection
    final anomalies = <String>[];
    if (isOverBudget) {
      anomalies.add(
        'Projected final spending exceeds your group budget by ₹${overrunAmount.toStringAsFixed(0)}.',
      );
    }

    for (final e in expenses) {
      if (effectiveBudget > 0 && e.amount > (effectiveBudget * 0.35)) {
        anomalies.add(
          'Single large expense alert: "${e.title}" accounts for ${(e.amount / effectiveBudget * 100).toStringAsFixed(0)}% of total group budget.',
        );
        break;
      }
    }

    categoryBreakdown.forEach((cat, summary) {
      if (effectiveBudget > 0 && summary.totalProjected > (effectiveBudget * 0.45)) {
        anomalies.add(
          'Category alert: $cat spending represents ${(summary.totalProjected / effectiveBudget * 100).toStringAsFixed(0)}% of total estimated budget.',
        );
      }
    });

    return BudgetForecastResult(
      totalBudget: effectiveBudget,
      actualSpent: actualSpent,
      committedTotal: committedTotal,
      availableBudget: availableBudget,
      projectedFinalSpend: projectedFinalSpend,
      isOverBudget: isOverBudget,
      overrunAmount: overrunAmount,
      spentPercentage: spentPercentage,
      committedPercentage: committedPercentage,
      projectedPerPerson: projectedPerPerson,
      anomalies: anomalies,
      categoryBreakdown: categoryBreakdown,
    );
  }

  WhatIfSimulationScenario runWhatIfSimulation({
    required double currentProjectedSpend,
    required int currentMembers,
    int memberDelta = 0,
    double priceChangePercent = 0.0,
    int durationDeltaDays = 0,
    int baseDays = 3,
  }) {
    final originalMembers = currentMembers > 0 ? currentMembers : 1;
    final newMembers = (originalMembers + memberDelta).clamp(1, 50);

    // Fixed costs (hotels, vehicle rentals, advances ~ 60%) vs Variable costs (meals, tickets ~ 40%)
    final fixedPortion = currentProjectedSpend * 0.60;
    final variablePortion = currentProjectedSpend * 0.40;

    // Price inflation
    final inflationFactor = 1.0 + (priceChangePercent / 100.0);

    // Duration scaling for variable costs + lodging
    final days = baseDays > 0 ? baseDays : 3;
    final durationFactor = (days + durationDeltaDays).clamp(1, 30) / days;

    // Scaled variable costs with new members and duration
    final scaledVariable = variablePortion *
        (newMembers / originalMembers) *
        durationFactor *
        inflationFactor;

    // Scaled fixed costs (constant across members, but influenced by price and duration)
    final scaledFixed = fixedPortion * inflationFactor * (1.0 + (durationDeltaDays * 0.15));

    final simulatedTotal = scaledFixed + scaledVariable;
    final simulatedPerPerson = simulatedTotal / newMembers;
    final basePerPerson = currentProjectedSpend / originalMembers;
    final deltaPerPerson = simulatedPerPerson - basePerPerson;

    String insight = '';
    if (memberDelta < 0) {
      insight =
          'If ${memberDelta.abs()} members drop out, fixed costs (lodging, cabs) are distributed among fewer people, increasing each member\'s share by ₹${deltaPerPerson.abs().toStringAsFixed(0)}.';
    } else if (memberDelta > 0) {
      insight =
          'Adding $memberDelta members reduces individual cost burden by ₹${deltaPerPerson.abs().toStringAsFixed(0)} per person due to shared fixed expenses.';
    } else if (priceChangePercent > 0) {
      insight =
          'A $priceChangePercent% price hike would raise the total budget by ₹${(simulatedTotal - currentProjectedSpend).toStringAsFixed(0)}.';
    } else {
      insight =
          'Baseline projection holds steady at ₹${simulatedPerPerson.toStringAsFixed(0)} per person.';
    }

    return WhatIfSimulationScenario(
      memberDelta: memberDelta,
      priceChangePercent: priceChangePercent,
      durationDeltaDays: durationDeltaDays,
      basePerPerson: basePerPerson,
      simulatedTotal: simulatedTotal,
      simulatedPerPerson: simulatedPerPerson,
      deltaPerPerson: deltaPerPerson,
      insight: insight,
    );
  }
}
