import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cocircle/core/utils/snackbar.dart';
import '../data/settlement_repository_impl.dart';
import '../domain/settlement_model.dart';
import '../domain/settlement_logic.dart';
import '../../expenses/presentation/expense_controller.dart';
import '../../../circles/presentation/circle_controller.dart';
import '../../../trips/presentation/trip_controller.dart';

part 'settlement_controller.g.dart';

@Riverpod(keepAlive: true)
class SettlementController extends _$SettlementController {
  @override
  FutureOr<void> build() {
    debugPrint('DEBUG: SettlementController built');
  }

  /// Record a settlement payment as an expense
  Future<void> settleUp({
    required String tripId,
    required String fromUid,
    required String toUid,
    required double amount,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    debugPrint('DEBUG: settleUp called for trip: $tripId, amount: $amount');

    try {
      // Get member names for title
      final trip = await ref.read(tripDetailsProvider(tripId).future);
      final membersResult = await ref.read(circleMembersProvider(trip.circleId).future);
      final payer = membersResult.firstWhereOrNull((m) => m.uid == fromUid);
      final receiver = membersResult.firstWhereOrNull((m) => m.uid == toUid);
      final title = 'Settlement: ${payer?.displayName ?? 'User'} to ${receiver?.displayName ?? 'User'}';

      debugPrint('DEBUG: Calling createSettlementExpense...');
      final result = await ref.read(expenseControllerProvider.notifier).createSettlementExpense(
        tripId: tripId,
        title: title,
        amount: amount,
        payerId: fromUid,
        receiverId: toUid,
      );

      if (!ref.mounted) {
        debugPrint('DEBUG: SettlementController unmounted after createSettlementExpense');
        return;
      }

      result.fold(
        (failure) {
          debugPrint('DEBUG ERROR: Settlement failed: ${failure.message}');
          state = AsyncError(failure.message, StackTrace.current);
          if (context.mounted) {
            showSnackBar(context, 'Failed to record settlement: ${failure.message}');
          }
        },
        (_) {
          debugPrint('DEBUG SUCCESS: Settlement recorded');
          state = const AsyncData(null);
          if (context.mounted) {
            showSnackBar(context, 'Settled up successfully!');
          }
        },
      );
    } catch (e, stack) {
      debugPrint('DEBUG EXCEPTION: $e\n$stack');
      if (ref.mounted) {
        state = AsyncError(e.toString(), stack);
        if (context.mounted) {
          showSnackBar(context, 'Error: $e');
        }
      }
    }
  }

  /// Legacy - kept for compatibility if needed elsewhere
  Future<void> syncSettlement(String tripId) async {
    // No-op for now as logic is derived on the fly
  }
}

@riverpod
Future<List<SettlementTransaction>> activeSettlements(Ref ref, String tripId) async {
  final expensesAsync = ref.watch(tripExpensesProvider(tripId));
  
  return expensesAsync.when(
    data: (expenses) {
      debugPrint('DEBUG: Recalculating active settlements for $tripId');
      return SettlementLogic.calculateSettlements(expenses);
    },
    loading: () => [],
    error: (err, _) {
       debugPrint('DEBUG ERROR: activeSettlements calculation error: $err');
       throw err;
    },
  );
}

@riverpod
Stream<List<SettlementModel>> tripSettlements(
  Ref ref,
  String tripId,
) {
  return ref
      .watch(settlementRepositoryProvider)
      .getSettlementsStream(tripId);
}
