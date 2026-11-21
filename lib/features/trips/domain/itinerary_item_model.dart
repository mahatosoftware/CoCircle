import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItemModel {
  final String id;
  final String tripId;
  final String title;
  final String type; // travel, lodging, dining, sightseeing, general, fuel, activity, etc.
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  final String? notes;
  final double? cost;
  final String createdBy;
  final DateTime createdAt;

  // Road trip & day-wise additions (backward compatible)
  final int dayNumber;
  final String? stopId;
  final String category;
  final double? latitude;
  final double? longitude;
  final String? bookingRef;
  final List<String> assignedUserIds;
  final bool isOptional;
  final bool isCompleted;
  final bool hasStartTime;

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
    this.dayNumber = 1,
    this.stopId,
    this.category = 'general',
    this.latitude,
    this.longitude,
    this.bookingRef,
    this.assignedUserIds = const [],
    this.isOptional = false,
    this.isCompleted = false,
    this.hasStartTime = true,
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
    int? dayNumber,
    String? stopId,
    String? category,
    double? latitude,
    double? longitude,
    String? bookingRef,
    List<String>? assignedUserIds,
    bool? isOptional,
    bool? isCompleted,
    bool? hasStartTime,
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
      dayNumber: dayNumber ?? this.dayNumber,
      stopId: stopId ?? this.stopId,
      category: category ?? this.category,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bookingRef: bookingRef ?? this.bookingRef,
      assignedUserIds: assignedUserIds ?? this.assignedUserIds,
      isOptional: isOptional ?? this.isOptional,
      isCompleted: isCompleted ?? this.isCompleted,
      hasStartTime: hasStartTime ?? this.hasStartTime,
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
      'dayNumber': dayNumber,
      'stopId': stopId,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'bookingRef': bookingRef,
      'assignedUserIds': assignedUserIds,
      'isOptional': isOptional,
      'isCompleted': isCompleted,
      'hasStartTime': hasStartTime,
    };
  }

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
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

    final rawAssigned = json['assignedUserIds'] as List<dynamic>? ?? [];
    final assigned = rawAssigned.map((e) => e.toString()).toList();

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
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      stopId: json['stopId'] as String?,
      category: json['category'] as String? ?? (json['type'] as String? ?? 'general'),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bookingRef: json['bookingRef'] as String?,
      assignedUserIds: assigned,
      isOptional: json['isOptional'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      hasStartTime: json['hasStartTime'] as bool? ?? true,
    );
  }
}
