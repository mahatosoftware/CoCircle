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
    required String category,
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

  const ExpenseModel._();

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);

  Map<String, Map<String, dynamic>> calculateChanges(ExpenseModel other) {
    final changes = <String, Map<String, dynamic>>{};

    if (title != other.title) {
      changes['title'] = {'old': title, 'new': other.title};
    }
    if (amount != other.amount) {
      changes['amount'] = {'old': amount, 'new': other.amount};
    }
    if (date.millisecondsSinceEpoch != other.date.millisecondsSinceEpoch) {
      changes['date'] = {'old': date.toIso8601String(), 'new': other.date.toIso8601String()};
    }
    if (category != other.category) {
      changes['category'] = {'old': category, 'new': other.category};
    }
    if (splitType != other.splitType) {
      changes['splitType'] = {'old': splitType.name, 'new': other.splitType.name};
    }
    if (notes != other.notes) {
      changes['notes'] = {'old': notes, 'new': other.notes};
    }
    
    // Compare Payers
    if (!_isMapEqual(payers, other.payers)) {
      changes['payers'] = {'old': payers, 'new': other.payers};
    }

    // Compare Split Details
    if (!_isMapEqual(splitDetails, other.splitDetails)) {
      changes['splitDetails'] = {'old': splitDetails, 'new': other.splitDetails};
    }

    return changes;
  }

  bool _isMapEqual(Map<String, double> m1, Map<String, double> m2) {
    if (m1.length != m2.length) return false;
    for (final key in m1.keys) {
      if (!m2.containsKey(key) || (m1[key]! - m2[key]!).abs() > 0.01) return false;
    }
    return true;
  }

  Map<String, Map<String, dynamic>> toAuditChanges() {
    return {
      'title': {'old': title, 'new': null},
      'amount': {'old': amount, 'new': null},
      'date': {'old': date.toIso8601String(), 'new': null},
      'category': {'old': category, 'new': null},
      'splitType': {'old': splitType.name, 'new': null},
      'notes': {'old': notes, 'new': null},
      'payers': {'old': payers, 'new': null},
      'splitDetails': {'old': splitDetails, 'new': null},
    };
  }
}
