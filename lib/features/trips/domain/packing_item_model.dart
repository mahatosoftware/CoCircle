import 'package:cloud_firestore/cloud_firestore.dart';

class PackingItemModel {
  final String id;
  final String tripId;
  final String title;
  final double quantity;
  final String? assignedTo; // userId of circle member bringing it
  final bool isPacked;
  final String createdBy;
  final DateTime createdAt;

  const PackingItemModel({
    required this.id,
    required this.tripId,
    required this.title,
    this.quantity = 1.0,
    this.assignedTo,
    this.isPacked = false,
    required this.createdBy,
    required this.createdAt,
  });

  PackingItemModel copyWith({
    String? id,
    String? tripId,
    String? title,
    double? quantity,
    String? assignedTo,
    bool? isPacked,
    String? createdBy,
    DateTime? createdAt,
    bool clearAssignedTo = false,
  }) {
    return PackingItemModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      assignedTo: clearAssignedTo ? null : (assignedTo ?? this.assignedTo),
      isPacked: isPacked ?? this.isPacked,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'quantity': quantity,
      'assignedTo': assignedTo,
      'isPacked': isPacked,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PackingItemModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return PackingItemModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      assignedTo: json['assignedTo'] as String?,
      isPacked: json['isPacked'] as bool? ?? false,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
