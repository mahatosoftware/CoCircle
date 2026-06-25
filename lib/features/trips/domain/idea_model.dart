import 'package:cloud_firestore/cloud_firestore.dart';

class IdeaModel {
  final String id;
  final String tripId;
  final String title;
  final String? description;
  final String? location;
  final List<String> votes; // List of userIds who voted
  final String createdBy;
  final DateTime createdAt;
  final bool isConverted;

  const IdeaModel({
    required this.id,
    required this.tripId,
    required this.title,
    this.description,
    this.location,
    this.votes = const [],
    required this.createdBy,
    required this.createdAt,
    this.isConverted = false,
  });

  IdeaModel copyWith({
    String? id,
    String? tripId,
    String? title,
    String? description,
    String? location,
    List<String>? votes,
    String? createdBy,
    DateTime? createdAt,
    bool? isConverted,
  }) {
    return IdeaModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      votes: votes ?? this.votes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isConverted: isConverted ?? this.isConverted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'description': description,
      'location': location,
      'votes': votes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isConverted': isConverted,
    };
  }

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return IdeaModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      votes: List<String>.from(json['votes'] as List? ?? []),
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      isConverted: json['isConverted'] as bool? ?? false,
    );
  }
}
