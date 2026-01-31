// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripSummaryModel _$TripSummaryModelFromJson(Map<String, dynamic> json) =>
    _TripSummaryModel(
      tripId: json['tripId'] as String,
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      memberBalances: (json['memberBalances'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      latestSettlementVersion: (json['latestSettlementVersion'] as num).toInt(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$TripSummaryModelToJson(_TripSummaryModel instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'totalExpenses': instance.totalExpenses,
      'memberBalances': instance.memberBalances,
      'latestSettlementVersion': instance.latestSettlementVersion,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
