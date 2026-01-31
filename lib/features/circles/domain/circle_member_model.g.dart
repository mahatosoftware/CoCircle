// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CircleMemberModel _$CircleMemberModelFromJson(Map<String, dynamic> json) =>
    _CircleMemberModel(
      uid: json['uid'] as String,
      circleId: json['circleId'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      role: $enumDecode(_$CircleRoleEnumMap, json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$CircleMemberModelToJson(_CircleMemberModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'circleId': instance.circleId,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'role': _$CircleRoleEnumMap[instance.role]!,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

const _$CircleRoleEnumMap = {
  CircleRole.admin: 'admin',
  CircleRole.member: 'member',
};
