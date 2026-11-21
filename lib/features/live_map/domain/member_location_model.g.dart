// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberLocationModel _$MemberLocationModelFromJson(Map<String, dynamic> json) =>
    _MemberLocationModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      battery: (json['battery'] as num?)?.toInt(),
      online: json['online'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      vehicleId: json['vehicleId'] as String?,
      destinationId: json['destinationId'] as String?,
      sharingStatus: json['sharingStatus'] as String? ?? 'sharing',
      isEmergency: json['isEmergency'] as bool? ?? false,
      vehicleName: json['vehicleName'] as String?,
    );

Map<String, dynamic> _$MemberLocationModelToJson(
  _MemberLocationModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'photoUrl': instance.photoUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'heading': instance.heading,
  'speed': instance.speed,
  'accuracy': instance.accuracy,
  'battery': instance.battery,
  'online': instance.online,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'vehicleId': instance.vehicleId,
  'destinationId': instance.destinationId,
  'sharingStatus': instance.sharingStatus,
  'isEmergency': instance.isEmergency,
  'vehicleName': instance.vehicleName,
};
