import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

enum ExpenseCategory { food, travel, stay, shopping, fuel, misc, settlement }
enum SplitType { equal, ratio, percentage, exact }

@freezed
abstract class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String id,
    required String tripId,
    required String title,
    required double amount,
    @TimestampConverter() required DateTime date,
    required ExpenseCategory category,
    required String payerId, // Or Map<String, double> for multiple payers? Requirement 4.4.2: Multiple payers
    required Map<String, double> payers, // uid -> amount
    required Map<String, double> splitDetails, // uid -> amount/ratio/percentage dependent on splitType (stored as calculated amount usually for simplicity, or raw?)
    // Storing the calculated amount per user is safer for immutable history.
    required SplitType splitType,
    String? notes,
    @Default(false) bool isSupplemental,
    required String createdBy,
    @TimestampConverter() required DateTime createdAt,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
}
