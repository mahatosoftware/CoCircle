import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences_model.freezed.dart';
part 'notification_preferences_model.g.dart';

@freezed
abstract class NotificationPreferencesModel with _$NotificationPreferencesModel {
  const factory NotificationPreferencesModel({
    @Default(true) bool expensesEnabled,
    @Default(true) bool tripRemindersEnabled,
    @Default(true) bool taskRemindersEnabled,
    @Default(true) bool pollRemindersEnabled,
    @Default(true) bool quietHoursEnabled,
    @Default(false) bool hideAmountsOnLockScreen,
    @Default([]) List<String> mutedTrips,
    @Default([]) List<String> mutedCircles,
  }) = _NotificationPreferencesModel;

  const NotificationPreferencesModel._();

  bool isTripMuted(String tripId) => mutedTrips.contains(tripId);
  bool isCircleMuted(String circleId) => mutedCircles.contains(circleId);

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);
}
