import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListModel {
  final String id;
  final String circleId;
  final String name;
  final String createdBy;
  final DateTime createdAt;

  const ShoppingListModel({
    required this.id,
    required this.circleId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
  });

  ShoppingListModel copyWith({
    String? id,
    String? circleId,
    String? name,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'circleId': circleId,
      'name': name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }
    
    return ShoppingListModel(
      id: json['id'] as String? ?? '',
      circleId: json['circleId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class ShoppingItemModel {
  final String id;
  final String listId;
  final String title;
  final double quantity;
  final String unit;
  final String createdBy;
  final DateTime createdAt;
  final bool isCompleted;
  final String? completedBy;
  final DateTime? completedAt;

  const ShoppingItemModel({
    required this.id,
    required this.listId,
    required this.title,
    this.quantity = 1.0,
    this.unit = '',
    required this.createdBy,
    required this.createdAt,
    this.isCompleted = false,
    this.completedBy,
    this.completedAt,
  });

  ShoppingItemModel copyWith({
    String? id,
    String? listId,
    String? title,
    double? quantity,
    String? unit,
    String? createdBy,
    DateTime? createdAt,
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
    bool clearCompletedBy = false,
    bool clearCompletedAt = false,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
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
      'listId': listId,
      'title': title,
      'quantity': quantity,
      'unit': unit,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
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

    return ShoppingItemModel(
      id: json['id'] as String? ?? '',
      listId: json['listId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedBy: json['completedBy'] as String?,
      completedAt: parseNullableDate(json['completedAt']),
    );
  }
}
