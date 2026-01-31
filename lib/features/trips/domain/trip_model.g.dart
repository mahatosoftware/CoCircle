// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripModel _$TripModelFromJson(Map<String, dynamic> json) => _TripModel(
  id: json['id'] as String,
  circleId: json['circleId'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$TripTypeEnumMap, json['type']),
  startDate: const TimestampConverter().fromJson(json['startDate']),
  endDate: const TimestampConverter().fromJson(json['endDate']),
  location: json['location'] as String?,
  createdBy: json['createdBy'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  isActive: json['isActive'] as bool? ?? true,
  totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$TripModelToJson(_TripModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'circleId': instance.circleId,
      'name': instance.name,
      'type': _$TripTypeEnumMap[instance.type]!,
      'startDate': _$JsonConverterToJson<dynamic, DateTime>(
        instance.startDate,
        const TimestampConverter().toJson,
      ),
      'endDate': _$JsonConverterToJson<dynamic, DateTime>(
        instance.endDate,
        const TimestampConverter().toJson,
      ),
      'location': instance.location,
      'createdBy': instance.createdBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
      'totalExpenses': instance.totalExpenses,
    };

const _$TripTypeEnumMap = {TripType.trip: 'trip', TripType.event: 'event'};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
