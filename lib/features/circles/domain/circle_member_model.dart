import 'package:freezed_annotation/freezed_annotation.dart';

part 'circle_member_model.freezed.dart';
part 'circle_member_model.g.dart';

enum CircleRole { admin, member }

@freezed
abstract class CircleMemberModel with _$CircleMemberModel {
  const factory CircleMemberModel({
    required String uid,
    required String circleId,
    required String displayName,
    String? photoUrl,
    required CircleRole role,
    required DateTime joinedAt,
  }) = _CircleMemberModel;

  factory CircleMemberModel.fromJson(Map<String, dynamic> json) => _$CircleMemberModelFromJson(json);
}
