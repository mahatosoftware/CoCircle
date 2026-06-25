import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItemModel {
  final String id;
  final String tripId;
  final String title;
  final String type; // travel, lodging, dining, sightseeing, general
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? notes;
  final double? cost;
  final String createdBy;
  final DateTime createdAt;

  const ItineraryItemModel({
    required this.id,
    required this.tripId,
    required this.title,
    required this.type,
    required this.startTime,
    this.endTime,
    this.location,
    this.notes,
    this.cost,
    required this.createdBy,
    required this.createdAt,
  });

  ItineraryItemModel copyWith({
    String? id,
    String? tripId,
    String? title,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? notes,
    double? cost,
    String? createdBy,
    DateTime? createdAt,
    bool clearEndTime = false,
  }) {
    return ItineraryItemModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      location: location ?? this.location,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'type': type,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'location': location,
      'notes': notes,
      'cost': cost,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
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

    return ItineraryItemModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      startTime: parseDate(json['startTime']),
      endTime: parseNullableDate(json['endTime']),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
