import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_location_model.freezed.dart';
part 'member_location_model.g.dart';

@freezed
abstract class MemberLocationModel with _$MemberLocationModel {
  const factory MemberLocationModel({
    required String userId,
    required String name,
    String? photoUrl,
    required double latitude,
    required double longitude,
    @Default(0.0) double heading,
    @Default(0.0) double speed,
    @Default(0.0) double accuracy,
    int? battery,
    @Default(false) bool online,
    required DateTime lastUpdated,
    String? vehicleId,
    String? destinationId,
    @Default('sharing') String sharingStatus, // 'sharing', 'paused', 'offline'
    @Default(false) bool isEmergency,
    String? vehicleName,
  }) = _MemberLocationModel;

  factory MemberLocationModel.fromJson(Map<String, dynamic> json) =>
      _$MemberLocationModelFromJson(json);
}
