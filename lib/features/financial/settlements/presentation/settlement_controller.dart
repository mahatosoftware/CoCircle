import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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

  Future<void> recordWriteOff({
    required String tripId,
    required String creditorUid,
    required String debtorUid,
    required double amount,
    required String reason,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final adjustment = SettlementAdjustmentModel(
      id: const Uuid().v4(),
      tripId: tripId,
      creditorUid: creditorUid,
      debtorUid: debtorUid,
      amount: amount,
      reason: reason,
      createdAt: DateTime.now(),
      approvedByCreditor: true,
    );

    final res = await ref.read(settlementRepositoryProvider).recordAdjustment(adjustment);
    res.fold(
      (err) {
        state = AsyncError(err.message, StackTrace.current);
        showSnackBar(context, 'Write-off failed: ${err.message}');
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Debt write-off recorded: ₹${amount.toStringAsFixed(0)} waived');
        ref.invalidate(tripAdjustmentsProvider(tripId));
      },
    );
  }

  /// Legacy - kept for compatibility if needed elsewhere
  Future<void> syncSettlement(String tripId) async {
    // No-op for now as logic is derived on the fly
  }
}

@riverpod
Future<List<SettlementTransaction>> activeSettlements(Ref ref, String tripId) async {
  final expensesAsync = ref.watch(tripExpensesProvider(tripId));
  final adjustmentsAsync = ref.watch(tripAdjustmentsProvider(tripId));

  final expenses = expensesAsync.value ?? [];
  final adjustments = adjustmentsAsync.value ?? [];

  return SettlementLogic.calculateSettlements(expenses, adjustments);
}

@riverpod
Stream<List<SettlementAdjustmentModel>> tripAdjustments(
  Ref ref,
  String tripId,
) {
  return ref
      .watch(settlementRepositoryProvider)
      .getAdjustmentsStream(tripId);
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
