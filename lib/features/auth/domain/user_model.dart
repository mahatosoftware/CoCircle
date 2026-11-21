import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? country,
    String? vpa,
    String? photoUrl,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
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

    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
          ? (json['displayName'] as String).trim()
          : 'User',
      country: json['country'] as String?,
      vpa: json['vpa'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: parsedCreatedAt,
    );
  }
}
