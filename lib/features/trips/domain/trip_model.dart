import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/timestamp_converter.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

enum TripType { trip, event }

@freezed
abstract class TripModel with _$TripModel {
  const factory TripModel({
    required String id,
    required String circleId,
    required String name,
    required TripType type,
    @TimestampConverter() DateTime? startDate,
    @TimestampConverter() DateTime? endDate,
    String? location,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
    @Default(true) bool isActive,
    // Read-optimized summary
    @Default(0.0) double totalExpenses, 
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);
}
