import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'circle_model.freezed.dart';
part 'circle_model.g.dart';

@freezed
abstract class CircleModel with _$CircleModel {
  const factory CircleModel({
    required String id,
    required String name,
    required String description,
    required String code, // 7-char alphanumeric
    required String currency,
    String? imageUrl,
    required List<String> memberIds,
    @Default([]) List<String> pendingMemberIds,
    @Default([]) List<String> oneTimeCodes,
    required List<String> adminIds,
    required String createdBy,
    required DateTime createdAt,
    @Default(false) bool isPendingDelete,
  }) = _CircleModel;

  factory CircleModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    DateTime parsedCreatedAt;
    if (rawCreatedAt is String) {
      parsedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return CircleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      code: json['code'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      imageUrl: json['imageUrl'] as String?,
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      pendingMemberIds: (json['pendingMemberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      oneTimeCodes: (json['oneTimeCodes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      adminIds: (json['adminIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parsedCreatedAt,
      isPendingDelete: json['isPendingDelete'] as bool? ?? false,
    );
  }
}
