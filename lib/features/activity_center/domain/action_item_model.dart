import 'package:flutter/material.dart';

enum ActionItemType {
  task,
  poll,
  settlement,
  shopping,
  invitation,
  lodging,
  itinerary,
  readiness,
}

enum ActionItemUrgency {
  urgent, // within 24 hours or critical blocker
  high,   // pending vote or unassigned task
  normal, // general to-do or recommendation
}

class ActionItemModel {
  final String id;
  final String? tripId;
  final String? tripName;
  final String? circleId;
  final String? circleName;
  final ActionItemType type;
  final String title;
  final String subtitle;
  final ActionItemUrgency urgency;
  final DateTime timestamp;
  final String actionRoute;
  final String actionLabel;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic>? metadata;

  const ActionItemModel({
    required this.id,
    this.tripId,
    this.tripName,
    this.circleId,
    this.circleName,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.urgency,
    required this.timestamp,
    required this.actionRoute,
    required this.actionLabel,
    required this.icon,
    required this.iconColor,
    this.metadata,
  });

  Color get urgencyColor {
    switch (urgency) {
      case ActionItemUrgency.urgent:
        return const Color(0xFFEF4444); // Crimson
      case ActionItemUrgency.high:
        return const Color(0xFFF59E0B); // Amber
      case ActionItemUrgency.normal:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  String get urgencyLabel {
    switch (urgency) {
      case ActionItemUrgency.urgent:
        return 'Urgent';
      case ActionItemUrgency.high:
        return 'Action Required';
      case ActionItemUrgency.normal:
        return 'To Do';
    }
  }
}
