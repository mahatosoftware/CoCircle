// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CircleModel _$CircleModelFromJson(Map<String, dynamic> json) => _CircleModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  code: json['code'] as String,
  currency: json['currency'] as String,
  imageUrl: json['imageUrl'] as String?,
  memberIds: (json['memberIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pendingMemberIds:
      (json['pendingMemberIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  oneTimeCodes:
      (json['oneTimeCodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  adminIds: (json['adminIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isPendingDelete: json['isPendingDelete'] as bool? ?? false,
);

Map<String, dynamic> _$CircleModelToJson(_CircleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'code': instance.code,
      'currency': instance.currency,
      'imageUrl': instance.imageUrl,
      'memberIds': instance.memberIds,
      'pendingMemberIds': instance.pendingMemberIds,
      'oneTimeCodes': instance.oneTimeCodes,
      'adminIds': instance.adminIds,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'isPendingDelete': instance.isPendingDelete,
    };
