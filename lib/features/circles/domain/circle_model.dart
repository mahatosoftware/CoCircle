import 'package:freezed_annotation/freezed_annotation.dart';

part 'circle_model.freezed.dart';
part 'circle_model.g.dart';

@freezed
abstract class CircleModel with _$CircleModel {
  const factory CircleModel({
    required String id,
    required String name,
    required String description,
    required String code, // 7-char alphanumeric
    required String currency,
    String? imageUrl,
    required List<String> memberIds,
    @Default([]) List<String> pendingMemberIds,
    required List<String> adminIds,
    required String createdBy,
    required DateTime createdAt,
    @Default(false) bool isPendingDelete,
  }) = _CircleModel;

  factory CircleModel.fromJson(Map<String, dynamic> json) => _$CircleModelFromJson(json);
}
