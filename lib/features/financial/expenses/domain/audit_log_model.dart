import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'audit_log_model.freezed.dart';
part 'audit_log_model.g.dart';

enum AuditAction { create, update, delete }

@freezed
abstract class AuditLogModel with _$AuditLogModel {
  const factory AuditLogModel({
    required String id,
    required String tripId,
    required String expenseId,
    required String userId,
    required AuditAction action,
    required String title,
    required double amount,
    @TimestampConverter() required DateTime timestamp,
    Map<String, dynamic>? changes, // Optional: store what changed (e.g. {'title': {'old': 'A', 'new': 'B'}})
  }) = _AuditLogModel;

  factory AuditLogModel.fromJson(Map<String, dynamic> json) => _$AuditLogModelFromJson(json);
}
