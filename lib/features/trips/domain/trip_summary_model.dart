import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_summary_model.freezed.dart';
part 'trip_summary_model.g.dart';

@freezed
abstract class TripSummaryModel with _$TripSummaryModel {
  const factory TripSummaryModel({
    required String tripId,
    required double totalExpenses,
    required Map<String, double> memberBalances, // uid -> net balance
    required int latestSettlementVersion,
    required DateTime lastUpdated,
  }) = _TripSummaryModel;

  factory TripSummaryModel.fromJson(Map<String, dynamic> json) => _$TripSummaryModelFromJson(json);
}
// Reparsed
