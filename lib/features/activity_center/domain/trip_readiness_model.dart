import 'package:flutter/material.dart';

class ReadinessCategory {
  final String title;
  final int completed;
  final int total;
  final double score; // 0.0 to 1.0
  final IconData icon;
  final String statusText;

  const ReadinessCategory({
    required this.title,
    required this.completed,
    required this.total,
    required this.score,
    required this.icon,
    required this.statusText,
  });

  bool get isReady => score >= 0.99;
}

class TripReadinessModel {
  final String tripId;
  final String tripName;
  final int overallScore; // 0 to 100
  final List<ReadinessCategory> categories;
  final List<String> criticalBlockers;
  final List<String> recommendedActions;

  const TripReadinessModel({
    required this.tripId,
    required this.tripName,
    required this.overallScore,
    required this.categories,
    required this.criticalBlockers,
    required this.recommendedActions,
  });

  Color get scoreColor {
    if (overallScore >= 80) return const Color(0xFF10B981); // Emerald Green
    if (overallScore >= 50) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Crimson
  }

  String get scoreBadgeLabel {
    if (overallScore >= 85) return 'Ready to Travel! 🚀';
    if (overallScore >= 65) return 'Good Progress 👍';
    if (overallScore >= 40) return 'In Planning 📝';
    return 'Action Needed ⚠️';
  }
}
