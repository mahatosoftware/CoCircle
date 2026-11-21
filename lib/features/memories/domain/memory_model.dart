import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MemoryCategory {
  all,
  beaches,
  food,
  sunset,
  activities,
  group,
  general,
}

class MemoryItem {
  final String id;
  final String tripId;
  final String mediaUrl;
  final String caption;
  final String category; // beaches, food, sunset, activities, group, general
  final String? locationName;
  final String uploadedBy;
  final String uploaderName;
  final DateTime uploadedAt;
  final List<String> likes;

  const MemoryItem({
    required this.id,
    required this.tripId,
    required this.mediaUrl,
    required this.caption,
    this.category = 'general',
    this.locationName,
    required this.uploadedBy,
    required this.uploaderName,
    required this.uploadedAt,
    this.likes = const [],
  });

  MemoryItem copyWith({
    String? id,
    String? tripId,
    String? mediaUrl,
    String? caption,
    String? category,
    String? locationName,
    String? uploadedBy,
    String? uploaderName,
    DateTime? uploadedAt,
    List<String>? likes,
  }) {
    return MemoryItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      caption: caption ?? this.caption,
      category: category ?? this.category,
      locationName: locationName ?? this.locationName,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'category': category,
        'locationName': locationName,
        'uploadedBy': uploadedBy,
        'uploaderName': uploaderName,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
        'likes': likes,
      };

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.now();
    }

    return MemoryItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      tripId: json['tripId'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      locationName: json['locationName'] as String?,
      uploadedBy: json['uploadedBy'] as String? ?? '',
      uploaderName: json['uploaderName'] as String? ?? 'Member',
      uploadedAt: parseDate(json['uploadedAt']),
      likes: (json['likes'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TripScrapbook {
  final String id;
  final String tripId;
  final String title;
  final String subtitle;
  final String story;
  final List<String> highlights;
  final Map<String, String> superlatives; // e.g. "Foodie": "Alice", "Sunset Lover": "Bob"
  final DateTime createdAt;

  const TripScrapbook({
    required this.id,
    required this.tripId,
    required this.title,
    required this.subtitle,
    required this.story,
    this.highlights = const [],
    this.superlatives = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'title': title,
        'subtitle': subtitle,
        'story': story,
        'highlights': highlights,
        'superlatives': superlatives,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory TripScrapbook.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.now();
    }

    return TripScrapbook(
      id: json['id'] as String? ?? const Uuid().v4(),
      tripId: json['tripId'] as String? ?? '',
      title: json['title'] as String? ?? 'Our Trip Diaries',
      subtitle: json['subtitle'] as String? ?? '',
      story: json['story'] as String? ?? '',
      highlights: (json['highlights'] as List?)?.map((e) => e.toString()).toList() ?? [],
      superlatives: (json['superlatives'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {},
      createdAt: parseDate(json['createdAt']),
    );
  }
}
