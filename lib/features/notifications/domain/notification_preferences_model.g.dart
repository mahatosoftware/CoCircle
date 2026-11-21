// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferencesModel(
  expensesEnabled: json['expensesEnabled'] as bool? ?? true,
  tripRemindersEnabled: json['tripRemindersEnabled'] as bool? ?? true,
  taskRemindersEnabled: json['taskRemindersEnabled'] as bool? ?? true,
  pollRemindersEnabled: json['pollRemindersEnabled'] as bool? ?? true,
  quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? true,
  hideAmountsOnLockScreen: json['hideAmountsOnLockScreen'] as bool? ?? false,
  mutedTrips:
      (json['mutedTrips'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  mutedCircles:
      (json['mutedCircles'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$NotificationPreferencesModelToJson(
  _NotificationPreferencesModel instance,
) => <String, dynamic>{
  'expensesEnabled': instance.expensesEnabled,
  'tripRemindersEnabled': instance.tripRemindersEnabled,
  'taskRemindersEnabled': instance.taskRemindersEnabled,
  'pollRemindersEnabled': instance.pollRemindersEnabled,
  'quietHoursEnabled': instance.quietHoursEnabled,
  'hideAmountsOnLockScreen': instance.hideAmountsOnLockScreen,
  'mutedTrips': instance.mutedTrips,
  'mutedCircles': instance.mutedCircles,
};
