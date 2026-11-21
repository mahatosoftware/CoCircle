import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/timestamp_converter.dart';

class NotificationEventModel {
  final String eventId;
  final String eventType;
  final String expenseId;
  final String tripId;
  final String circleId;
  final String createdBy;
  final String status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int attempts;
  final String? lastError;
  final Map<String, dynamic> metadata;

  const NotificationEventModel({
    required this.eventId,
    required this.eventType,
    required this.expenseId,
    required this.tripId,
    required this.circleId,
    required this.createdBy,
    this.status = 'pending',
    required this.createdAt,
    this.processedAt,
    this.attempts = 0,
    this.lastError,
    this.metadata = const {},
  });

  factory NotificationEventModel.fromJson(Map<String, dynamic> json) {
    return NotificationEventModel(
      eventId: json['eventId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      expenseId: json['expenseId'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      circleId: json['circleId'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      processedAt: json['processedAt'] != null
          ? const TimestampConverter().fromJson(json['processedAt'])
          : null,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventType': eventType,
      'expenseId': expenseId,
      'tripId': tripId,
      'circleId': circleId,
      'createdBy': createdBy,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      if (processedAt != null) 'processedAt': Timestamp.fromDate(processedAt!),
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      'metadata': metadata,
    };
  }
}
