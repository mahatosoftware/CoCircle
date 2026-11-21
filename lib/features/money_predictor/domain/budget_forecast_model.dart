import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BudgetCommitment {
  final String id;
  final String tripId;
  final String title;
  final String category; // accommodation, transport, food, activities, misc
  final double estimatedCost;
  final bool isBooked;
  final DateTime? dueDate;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const BudgetCommitment({
    required this.id,
    required this.tripId,
    required this.title,
    required this.category,
    required this.estimatedCost,
    this.isBooked = false,
    this.dueDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  BudgetCommitment copyWith({
    String? id,
    String? tripId,
    String? title,
    String? category,
    double? estimatedCost,
    bool? isBooked,
    DateTime? dueDate,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return BudgetCommitment(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isBooked: isBooked ?? this.isBooked,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'title': title,
        'category': category,
        'estimatedCost': estimatedCost,
        'isBooked': isBooked,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'notes': notes,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory BudgetCommitment.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.now();
    }

    return BudgetCommitment(
      id: json['id'] as String? ?? const Uuid().v4(),
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? 'Commitment',
      category: json['category'] as String? ?? 'misc',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      isBooked: json['isBooked'] as bool? ?? false,
      dueDate: json['dueDate'] != null ? parseDate(json['dueDate']) : null,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class CategorySpendSummary {
  final String category;
  final double spent;
  final double committed;
  final double totalProjected;

  const CategorySpendSummary({
    required this.category,
    required this.spent,
    required this.committed,
    required this.totalProjected,
  });
}

class BudgetForecastResult {
  final double totalBudget;
  final double actualSpent;
  final double committedTotal;
  final double availableBudget;
  final double projectedFinalSpend;
  final bool isOverBudget;
  final double overrunAmount;
  final double spentPercentage;
  final double committedPercentage;
  final double projectedPerPerson;
  final List<String> anomalies;
  final Map<String, CategorySpendSummary> categoryBreakdown;

  const BudgetForecastResult({
    required this.totalBudget,
    required this.actualSpent,
    required this.committedTotal,
    required this.availableBudget,
    required this.projectedFinalSpend,
    required this.isOverBudget,
    required this.overrunAmount,
    required this.spentPercentage,
    required this.committedPercentage,
    required this.projectedPerPerson,
    required this.anomalies,
    required this.categoryBreakdown,
  });
}

class WhatIfSimulationScenario {
  final int memberDelta; // e.g. -2
  final double priceChangePercent; // e.g. +15%
  final int durationDeltaDays; // e.g. +1
  final double basePerPerson;
  final double simulatedTotal;
  final double simulatedPerPerson;
  final double deltaPerPerson;
  final String insight;

  const WhatIfSimulationScenario({
    required this.memberDelta,
    required this.priceChangePercent,
    required this.durationDeltaDays,
    required this.basePerPerson,
    required this.simulatedTotal,
    required this.simulatedPerPerson,
    required this.deltaPerPerson,
    required this.insight,
  });
}
