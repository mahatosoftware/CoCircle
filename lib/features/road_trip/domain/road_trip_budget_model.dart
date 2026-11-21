import 'package:cloud_firestore/cloud_firestore.dart';

enum RoadTripBudgetCategory {
  fuel,
  accommodation,
  food,
  toll,
  parking,
  transport,
  activities,
  shopping,
  emergency,
  misc,
}

extension RoadTripBudgetCategoryExtension on RoadTripBudgetCategory {
  String get displayName {
    switch (this) {
      case RoadTripBudgetCategory.fuel:
        return 'Fuel & Gas';
      case RoadTripBudgetCategory.accommodation:
        return 'Accommodation & Stays';
      case RoadTripBudgetCategory.food:
        return 'Food & Dining';
      case RoadTripBudgetCategory.toll:
        return 'Tolls & Fastag';
      case RoadTripBudgetCategory.parking:
        return 'Parking Fees';
      case RoadTripBudgetCategory.transport:
        return 'Local Transport / Rentals';
      case RoadTripBudgetCategory.activities:
        return 'Activities & Tickets';
      case RoadTripBudgetCategory.shopping:
        return 'Shopping & Souvenirs';
      case RoadTripBudgetCategory.emergency:
        return 'Emergency Reserve';
      case RoadTripBudgetCategory.misc:
        return 'Miscellaneous';
    }
  }

  String get shortName {
    switch (this) {
      case RoadTripBudgetCategory.fuel:
        return 'Fuel';
      case RoadTripBudgetCategory.accommodation:
        return 'Stays';
      case RoadTripBudgetCategory.food:
        return 'Food';
      case RoadTripBudgetCategory.toll:
        return 'Toll';
      case RoadTripBudgetCategory.parking:
        return 'Parking';
      case RoadTripBudgetCategory.transport:
        return 'Transport';
      case RoadTripBudgetCategory.activities:
        return 'Activities';
      case RoadTripBudgetCategory.shopping:
        return 'Shopping';
      case RoadTripBudgetCategory.emergency:
        return 'Emergency';
      case RoadTripBudgetCategory.misc:
        return 'Misc';
    }
  }
}

enum BudgetHealth {
  healthy, // < 80% (Green)
  warning, // 80% - 100% (Amber)
  exceeded, // > 100% (Red)
}

class RoadTripBudgetModel {
  final String id;
  final String tripId;
  final double totalBudget;
  final String currency;
  final Map<RoadTripBudgetCategory, double> categoryBudgets;
  final Map<int, double> dailyBudgets; // dayNumber -> allocated budget
  final String createdBy;
  final DateTime updatedAt;

  const RoadTripBudgetModel({
    required this.id,
    required this.tripId,
    required this.totalBudget,
    this.currency = '₹',
    this.categoryBudgets = const {},
    this.dailyBudgets = const {},
    required this.createdBy,
    required this.updatedAt,
  });

  RoadTripBudgetModel copyWith({
    String? id,
    String? tripId,
    double? totalBudget,
    String? currency,
    Map<RoadTripBudgetCategory, double>? categoryBudgets,
    Map<int, double>? dailyBudgets,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return RoadTripBudgetModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      dailyBudgets: dailyBudgets ?? this.dailyBudgets,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'totalBudget': totalBudget,
      'currency': currency,
      'categoryBudgets': categoryBudgets.map((k, v) => MapEntry(k.name, v)),
      'dailyBudgets': dailyBudgets.map((k, v) => MapEntry(k.toString(), v)),
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RoadTripBudgetModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    final rawCat = json['categoryBudgets'] as Map<String, dynamic>? ?? {};
    final categoryBudgets = <RoadTripBudgetCategory, double>{};
    for (final entry in rawCat.entries) {
      final cat = RoadTripBudgetCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == entry.key.toLowerCase(),
        orElse: () => RoadTripBudgetCategory.misc,
      );
      categoryBudgets[cat] = (entry.value as num?)?.toDouble() ?? 0.0;
    }

    final rawDaily = json['dailyBudgets'] as Map<String, dynamic>? ?? {};
    final dailyBudgets = <int, double>{};
    for (final entry in rawDaily.entries) {
      final day = int.tryParse(entry.key) ?? 1;
      dailyBudgets[day] = (entry.value as num?)?.toDouble() ?? 0.0;
    }

    return RoadTripBudgetModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      totalBudget: (json['totalBudget'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? '₹',
      categoryBudgets: categoryBudgets,
      dailyBudgets: dailyBudgets,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

class BudgetUtilizationReport {
  final double targetBudget;
  final double totalActualSpent;
  final double remainingBudget;
  final double utilizationPercentage;
  final BudgetHealth health;
  final double perPersonEstimatedBudget;
  final double perPersonActualSpent;
  final int totalParticipants;
  final Map<RoadTripBudgetCategory, double> categorySpent;
  final Map<RoadTripBudgetCategory, double> categoryBudgetLimits;
  final Map<int, double> daySpent;
  final Map<int, double> dayBudgetLimits;

  const BudgetUtilizationReport({
    required this.targetBudget,
    required this.totalActualSpent,
    required this.remainingBudget,
    required this.utilizationPercentage,
    required this.health,
    required this.perPersonEstimatedBudget,
    required this.perPersonActualSpent,
    required this.totalParticipants,
    required this.categorySpent,
    required this.categoryBudgetLimits,
    required this.daySpent,
    required this.dayBudgetLimits,
  });

  factory BudgetUtilizationReport.compute({
    required RoadTripBudgetModel budget,
    required List<dynamic> actualExpenses, // List of ExpenseModel
    required int participantCount,
  }) {
    double spentTotal = 0.0;
    final catSpent = <RoadTripBudgetCategory, double>{};
    final daySpentMap = <int, double>{};

    for (final exp in actualExpenses) {
      final amt = (exp.amount as num?)?.toDouble() ?? 0.0;
      spentTotal += amt;

      // Map expense category string to RoadTripBudgetCategory
      final catStr = (exp.category as String? ?? '').toLowerCase();
      final cat = _mapExpenseCategory(catStr);
      catSpent[cat] = (catSpent[cat] ?? 0.0) + amt;

      // If expense has a day or date, map to day
      final dayNum = _resolveDayNumber(exp);
      if (dayNum != null) {
        daySpentMap[dayNum] = (daySpentMap[dayNum] ?? 0.0) + amt;
      }
    }

    final target = budget.totalBudget > 0 ? budget.totalBudget : 0.0;
    final remaining = target - spentTotal;
    final pct = target > 0 ? (spentTotal / target) * 100 : 0.0;

    BudgetHealth h;
    if (pct < 80.0) {
      h = BudgetHealth.healthy;
    } else if (pct <= 100.0) {
      h = BudgetHealth.warning;
    } else {
      h = BudgetHealth.exceeded;
    }

    final perPersonBudget = participantCount > 0 ? target / participantCount : target;
    final perPersonSpent = participantCount > 0 ? spentTotal / participantCount : spentTotal;

    return BudgetUtilizationReport(
      targetBudget: target,
      totalActualSpent: spentTotal,
      remainingBudget: remaining,
      utilizationPercentage: pct,
      health: h,
      perPersonEstimatedBudget: perPersonBudget,
      perPersonActualSpent: perPersonSpent,
      totalParticipants: participantCount,
      categorySpent: catSpent,
      categoryBudgetLimits: budget.categoryBudgets,
      daySpent: daySpentMap,
      dayBudgetLimits: budget.dailyBudgets,
    );
  }

  static RoadTripBudgetCategory _mapExpenseCategory(String cat) {
    if (cat.contains('fuel') || cat.contains('gas')) return RoadTripBudgetCategory.fuel;
    if (cat.contains('stay') || cat.contains('hotel') || cat.contains('accommodation')) return RoadTripBudgetCategory.accommodation;
    if (cat.contains('food') || cat.contains('dining') || cat.contains('restaurant')) return RoadTripBudgetCategory.food;
    if (cat.contains('toll')) return RoadTripBudgetCategory.toll;
    if (cat.contains('park')) return RoadTripBudgetCategory.parking;
    if (cat.contains('transport') || cat.contains('travel') || cat.contains('cab')) return RoadTripBudgetCategory.transport;
    if (cat.contains('activit') || cat.contains('ticket') || cat.contains('sightseeing')) return RoadTripBudgetCategory.activities;
    if (cat.contains('shop')) return RoadTripBudgetCategory.shopping;
    if (cat.contains('emerg')) return RoadTripBudgetCategory.emergency;
    return RoadTripBudgetCategory.misc;
  }

  static int? _resolveDayNumber(dynamic exp) {
    // If expense object has dayNumber field or notes tag like #day1
    final notes = (exp.notes as String? ?? '').toLowerCase();
    final dayMatch = RegExp(r'day\s*(\d+)').firstMatch(notes);
    if (dayMatch != null) {
      return int.tryParse(dayMatch.group(1)!);
    }
    return null;
  }
}
