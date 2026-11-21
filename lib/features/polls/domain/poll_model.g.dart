// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PollOption _$PollOptionFromJson(Map<String, dynamic> json) => _PollOption(
  text: json['text'] as String,
  voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PollOptionToJson(_PollOption instance) =>
    <String, dynamic>{'text': instance.text, 'voteCount': instance.voteCount};

_PollModel _$PollModelFromJson(Map<String, dynamic> json) => _PollModel(
  id: json['id'] as String,
  tripId: json['tripId'] as String,
  creatorId: json['creatorId'] as String,
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>)
      .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
      .toList(),
  votes:
      (json['votes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
      ) ??
      const {},
  allowMultipleSelections: json['allowMultipleSelections'] as bool? ?? false,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  isActive: json['isActive'] as bool? ?? true,
  closedAt: const TimestampConverter().fromJson(json['closedAt']),
  pollType: json['pollType'] as String? ?? 'standard',
  isAnonymous: json['isAnonymous'] as bool? ?? false,
  deadline: const TimestampConverter().fromJson(json['deadline']),
  aiRecommendation: json['aiRecommendation'] as String?,
  winningOptionIndex: (json['winningOptionIndex'] as num?)?.toInt(),
  convertedToAction: json['convertedToAction'] as bool? ?? false,
);

Map<String, dynamic> _$PollModelToJson(_PollModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'creatorId': instance.creatorId,
      'question': instance.question,
      'options': instance.options.map((e) => e.toJson()).toList(),
      'votes': instance.votes,
      'allowMultipleSelections': instance.allowMultipleSelections,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isActive': instance.isActive,
      'closedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.closedAt,
        const TimestampConverter().toJson,
      ),
      'pollType': instance.pollType,
      'isAnonymous': instance.isAnonymous,
      'deadline': _$JsonConverterToJson<dynamic, DateTime>(
        instance.deadline,
        const TimestampConverter().toJson,
      ),
      'aiRecommendation': instance.aiRecommendation,
      'winningOptionIndex': instance.winningOptionIndex,
      'convertedToAction': instance.convertedToAction,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
