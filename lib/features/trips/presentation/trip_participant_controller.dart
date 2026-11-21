import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/finance/exact_money_calculator.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../financial/expenses/presentation/expense_controller.dart';
import '../../financial/payments/domain/guest_payment_model.dart';
import '../data/trip_participant_repository_impl.dart';
import '../domain/trip_participant_model.dart';

final tripParticipantsProvider =
    StreamProvider.family<List<TripParticipantModel>, String>((ref, tripId) {
  return ref
      .watch(tripParticipantRepositoryProvider)
      .getTripParticipantsStream(tripId);
});

final tripPaymentsProvider =
    StreamProvider.family<List<GuestPaymentModel>, String>((ref, tripId) {
  return ref
      .watch(tripParticipantRepositoryProvider)
      .getTripPaymentsStream(tripId);
});

final tripParticipantBalancesProvider =
    FutureProvider.family<Map<String, ParticipantBalance>, String>((ref, tripId) async {
  final participants = await ref.watch(tripParticipantsProvider(tripId).future);
  final expenses = await ref.watch(tripExpensesProvider(tripId).future);
  final payments = await ref.watch(tripPaymentsProvider(tripId).future);

  final participantIds = participants.map((p) => p.id).toList();

  return ExactMoneyCalculator.calculateBalances(
    participantIds: participantIds,
    expenses: expenses,
    guestPayments: payments,
  );
});

final tripParticipantControllerProvider =
    NotifierProvider<TripParticipantController, AsyncValue<void>>(
  TripParticipantController.new,
);

class TripParticipantController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> addGuestParticipant({
    required String tripId,
    required String name,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? notes,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      showSnackBar(context, 'Please log in to add a participant');
      return false;
    }

    final res = await ref.read(tripParticipantRepositoryProvider).addGuestParticipant(
          tripId: tripId,
          name: name,
          phoneNumber: phoneNumber,
          email: email,
          avatarUrl: avatarUrl,
          notes: notes,
          addedBy: user.uid,
        );

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to add guest: ${l.message}');
        return false;
      },
      (guest) {
        state = const AsyncData(null);
        showSnackBar(context, '${guest.name} added as guest participant! 🎉');
        ref.invalidate(tripParticipantsProvider(tripId));
        ref.invalidate(tripParticipantBalancesProvider(tripId));
        return true;
      },
    );
  }

  Future<bool> addCircleMemberToTrip({
    required String tripId,
    required String userId,
    required String displayName,
    String? photoUrl,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
    if (currentUser == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return false;
    }

    final participant = TripParticipantModel(
      id: userId,
      tripId: tripId,
      name: displayName,
      participantType: TripParticipantType.registered,
      userId: userId,
      avatarUrl: photoUrl,
      addedBy: currentUser.uid,
      createdAt: DateTime.now(),
      status: 'active',
    );

    final res = await ref.read(tripParticipantRepositoryProvider).addParticipant(participant);

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to add member: ${l.message}');
        return false;
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, '${r.name} added to the trip!');
        ref.invalidate(tripParticipantsProvider(tripId));
        ref.invalidate(tripParticipantBalancesProvider(tripId));
        return true;
      },
    );
  }

  Future<bool> updateParticipant({
    required TripParticipantModel participant,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripParticipantRepositoryProvider).updateParticipant(participant);

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Update failed: ${l.message}');
        return false;
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Participant details updated successfully');
        ref.invalidate(tripParticipantsProvider(participant.tripId));
        return true;
      },
    );
  }

  Future<bool> removeParticipant({
    required String tripId,
    required String participantId,
    required String participantName,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return false;
    }

    final res = await ref.read(tripParticipantRepositoryProvider).removeParticipant(
          tripId: tripId,
          participantId: participantId,
          removedBy: user.uid,
        );

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        showSnackBar(context, '$participantName removed from trip.');
        ref.invalidate(tripParticipantsProvider(tripId));
        ref.invalidate(tripParticipantBalancesProvider(tripId));
        return true;
      },
    );
  }

  Future<bool> convertGuestToRegistered({
    required String tripId,
    required String participantId,
    required String registeredUserId,
    required String registeredDisplayName,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
    if (currentUser == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return false;
    }

    final res = await ref.read(tripParticipantRepositoryProvider).convertGuestToRegistered(
          tripId: tripId,
          participantId: participantId,
          registeredUserId: registeredUserId,
          registeredDisplayName: registeredDisplayName,
          convertedBy: currentUser.uid,
        );

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Conversion failed: ${l.message}');
        return false;
      },
      (converted) {
        state = const AsyncData(null);
        showSnackBar(
          context,
          '${converted.name} successfully linked to registered CoCircle account! All financial history preserved.',
        );
        ref.invalidate(tripParticipantsProvider(tripId));
        ref.invalidate(tripParticipantBalancesProvider(tripId));
        return true;
      },
    );
  }

  Future<bool> recordPayment({
    required String tripId,
    required String fromMemberId,
    required String toMemberId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? referenceNumber,
    String? notes,
    required bool onBehalfOfGuest,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
    if (currentUser == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return false;
    }

    final payment = GuestPaymentModel(
      id: 'pay_${const Uuid().v4().substring(0, 8)}',
      tripId: tripId,
      fromMemberId: fromMemberId,
      toMemberId: toMemberId,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate ?? DateTime.now(),
      referenceNumber: referenceNumber,
      notes: notes,
      recordedBy: currentUser.uid,
      recordedOnBehalfOfGuest: onBehalfOfGuest,
      paymentStatus: 'completed',
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripParticipantRepositoryProvider).recordPayment(payment);

    return res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to record payment: ${l.message}');
        return false;
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Payment of ₹${amount.toStringAsFixed(0)} recorded successfully! 🤝');
        ref.invalidate(tripPaymentsProvider(tripId));
        ref.invalidate(tripParticipantBalancesProvider(tripId));
        return true;
      },
    );
  }
}
