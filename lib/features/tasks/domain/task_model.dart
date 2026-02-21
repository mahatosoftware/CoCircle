import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String tripId;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final bool isCompleted;
  final String? completedBy;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.createdBy,
    required this.createdAt,
    this.isCompleted = false,
    this.completedBy,
    this.completedAt,
  });

  TaskModel copyWith({
    String? id,
    String? tripId,
    String? title,
    String? createdBy,
    DateTime? createdAt,
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
    bool clearCompletedBy = false,
    bool clearCompletedAt = false,
  }) {
    return TaskModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: clearCompletedBy ? null : (completedBy ?? this.completedBy),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      if (value is DateTime) return value;
      return null;
    }

    return TaskModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedBy: json['completedBy'] as String?,
      completedAt: parseNullableDate(json['completedAt']),
    );
  }
}
