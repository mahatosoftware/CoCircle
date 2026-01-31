import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/trip_repository_impl.dart';
import '../domain/trip_model.dart';

part 'trip_controller.g.dart';

@riverpod
class TripController extends _$TripController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> createTrip({
    required String circleId,
    required String name,
    required TripType type,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final tripId = const Uuid().v4();
    final now = DateTime.now();

    final trip = TripModel(
      id: tripId,
      circleId: circleId,
      name: name,
      type: type,
      startDate: startDate,
      endDate: endDate,
      location: location,
      createdBy: user.uid,
      createdAt: now,
    );

    final result = await ref.read(tripRepositoryProvider).createTrip(trip);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Trip created successfully!');
        context.pop();
      },
    );
  }

  Future<void> updateTripName({
    required TripModel trip,
    required String newName,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    
    final updatedTrip = trip.copyWith(name: newName);
    
    final result = await ref.read(tripRepositoryProvider).updateTrip(updatedTrip);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to update trip name: ${l.message}');
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Trip name updated successfully');
        // Invalidate provider to refresh details
        ref.invalidate(tripDetailsProvider(trip.id));
        ref.invalidate(circleTripsProvider(trip.circleId));
      },
    );
  }
}

@riverpod
Stream<List<TripModel>> circleTrips(Ref ref, String circleId) {
  return ref.watch(tripRepositoryProvider).getTripsStream(circleId);
}

@riverpod
Future<TripModel> tripDetails(Ref ref, String tripId) async {
  final res = await ref.watch(tripRepositoryProvider).getTripById(tripId);
  return res.fold((l) => throw l, (r) => r);
}
