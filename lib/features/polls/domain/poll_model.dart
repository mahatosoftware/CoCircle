import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/utils/timestamp_converter.dart';

part 'poll_model.freezed.dart';
part 'poll_model.g.dart';

@freezed
abstract class PollOption with _$PollOption {
  const factory PollOption({
    required String text,
    @Default(0) int voteCount,
  }) = _PollOption;

  factory PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);
}

@freezed
abstract class PollModel with _$PollModel {
  const factory PollModel({
    required String id,
    required String tripId,
    required String creatorId,
    required String question,
    required List<PollOption> options,
    @Default({}) Map<String, List<int>> votes, // userId -> list of optionIndices
    @Default(false) bool allowMultipleSelections,
    @TimestampConverter() required DateTime createdAt,
    @Default(true) bool isActive,
    @TimestampConverter() DateTime? closedAt,
  }) = _PollModel;

  factory PollModel.fromJson(Map<String, dynamic> json) => _$PollModelFromJson(json);
}
