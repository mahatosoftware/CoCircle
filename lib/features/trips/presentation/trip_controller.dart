import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../circles/presentation/circle_controller.dart';
import '../../live_map/data/realtime_location_repository_impl.dart';
import '../data/trip_repository_impl.dart';
import '../data/trip_planner_repository_impl.dart';
import '../data/trip_participant_repository_impl.dart';
import 'trip_planner_controller.dart';
import '../domain/trip_model.dart';
import '../domain/trip_participant_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    double totalBudget = 0.0,
    String? category,
    List<TripParticipantModel>? initialParticipants,
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

    final participantIds = <String>{user.uid};
    if (initialParticipants != null) {
      for (final p in initialParticipants) {
        participantIds.add(p.id);
      }
    }

    final trip = TripModel(
      id: tripId,
      circleId: circleId,
      name: name,
      type: type,
      startDate: startDate,
      endDate: endDate,
      location: location,
      totalBudget: totalBudget,
      category: category,
      participantIds: participantIds.toList(),
      createdBy: user.uid,
      createdAt: now,
    );

    final result = await ref.read(tripRepositoryProvider).createTrip(trip);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) async {
        state = const AsyncData(null);
        showSnackBar(context, 'Trip created successfully!');

        // Add creator participant
        final participantRepo = ref.read(tripParticipantRepositoryProvider);
        final creatorParticipant = TripParticipantModel(
          id: user.uid,
          tripId: tripId,
          name: user.displayName.isNotEmpty ? user.displayName : 'Organizer',
          participantType: TripParticipantType.registered,
          userId: user.uid,
          avatarUrl: user.photoUrl,
          addedBy: user.uid,
          createdAt: now,
          status: 'active',
        );
        await participantRepo.addParticipant(creatorParticipant);

        // Add initial guests & circle participants
        if (initialParticipants != null) {
          for (final p in initialParticipants) {
            if (p.id != user.uid) {
              await participantRepo.addParticipant(p.copyWith(tripId: tripId));
            }
          }
        }

        if (location != null && location.trim().isNotEmpty) {
          try {
            await ref.read(realtimeLocationRepositoryProvider).setDestination(
              tripId: tripId,
              destinationId: 'dest_main',
              name: location.trim(),
              latitude: 12.9716, // Default baseline coordinate; can be refined on map
              longitude: 77.5946,
              order: 1,
            );
          } catch (e) {
            debugPrint("Failed to sync destination to live map: $e");
          }
        }
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

  Future<void> toggleTripActive({
    required TripModel trip,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final updatedTrip = trip.copyWith(isActive: !trip.isActive);
    final result = await ref.read(tripRepositoryProvider).updateTrip(updatedTrip);

    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to update trip status: ${l.message}');
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Trip marked as ${updatedTrip.isActive ? 'active' : 'inactive'}');
        ref.invalidate(tripDetailsProvider(trip.id));
        ref.invalidate(circleTripsProvider(trip.circleId));
      },
    );
  }

  Future<void> updateTripLifecycleStatus({
    required TripModel trip,
    required String newStatus,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final updatedTrip = trip.copyWith(
      status: newStatus,
      closedAt: newStatus == 'closed' ? DateTime.now() : trip.closedAt,
    );

    final result = await ref.read(tripRepositoryProvider).updateTrip(updatedTrip);
    result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, 'Failed to update status: ${l.message}');
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Trip status updated to ${newStatus.toUpperCase()}');
        ref.invalidate(tripDetailsProvider(trip.id));
        ref.invalidate(circleTripsProvider(trip.circleId));
        ref.invalidate(allUserTripsProvider);
      },
    );
  }

  Future<String?> duplicateTrip({
    required String sourceTripId,
    required String targetCircleId,
    required String newName,
    required DateTime newStartDate,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return null;
    }

    try {
      final sourceTrip = await ref.read(tripDetailsProvider(sourceTripId).future);
      final newTripId = const Uuid().v4();
      final now = DateTime.now();

      Duration shift = Duration.zero;
      DateTime? newEndDate;
      if (sourceTrip.startDate != null) {
        shift = newStartDate.difference(sourceTrip.startDate!);
        if (sourceTrip.endDate != null) {
          newEndDate = sourceTrip.endDate!.add(shift);
        }
      }

      final newTrip = TripModel(
        id: newTripId,
        circleId: targetCircleId,
        name: newName,
        type: sourceTrip.type,
        startDate: newStartDate,
        endDate: newEndDate,
        location: sourceTrip.location,
        createdBy: user.uid,
        createdAt: now,
      );

      final result = await ref.read(tripRepositoryProvider).createTrip(newTrip);

      return await result.fold(
        (l) {
          state = AsyncError(l.message, StackTrace.current);
          showSnackBar(context, 'Failed to duplicate trip: ${l.message}');
          return null;
        },
        (createdTrip) async {
          // 1. Copy Itinerary Items with shifted dates
          try {
            final itineraryItems = await ref.read(tripItineraryProvider(sourceTripId).future);
            for (final item in itineraryItems) {
              final shiftedStart = item.startTime.add(shift);
              final shiftedEnd = item.endTime?.add(shift);
              await ref.read(tripPlannerRepositoryProvider).createItineraryItem(
                item.copyWith(
                  id: const Uuid().v4(),
                  tripId: newTripId,
                  startTime: shiftedStart,
                  endTime: shiftedEnd,
                  createdBy: user.uid,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error duplicating itinerary: $e');
          }

          // 2. Copy Packing Items (unpacked state)
          try {
            final packingItems = await ref.read(tripPackingProvider(sourceTripId).future);
            for (final item in packingItems) {
              await ref.read(tripPlannerRepositoryProvider).createPackingItem(
                item.copyWith(
                  id: const Uuid().v4(),
                  tripId: newTripId,
                  isPacked: false,
                  clearAssignedTo: true,
                ),
              );
            }
          } catch (e) {
            debugPrint('Error duplicating packing list: $e');
          }

          state = const AsyncData(null);
          showSnackBar(context, 'Trip created from template! ✈️');
          ref.invalidate(circleTripsProvider(targetCircleId));
          ref.invalidate(allUserTripsProvider);
          return newTripId;
        },
      );
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      showSnackBar(context, 'Duplication failed: $e');
      return null;
    }
  }
}

@riverpod
Stream<List<TripModel>> circleTrips(Ref ref, String circleId) {
  return ref.watch(tripRepositoryProvider).getTripsStream(circleId);
}

@riverpod
Stream<List<TripModel>> allUserTrips(Ref ref) {
  final userCirclesAsync = ref.watch(userCirclesProvider);
  return userCirclesAsync.when(
    data: (circles) {
      if (circles.isEmpty) return Stream.value([]);
      final circleIds = circles.map((c) => c.id).toList();
      return FirebaseFirestore.instance
          .collection('trips')
          .where('circleId', whereIn: circleIds.take(10).toList())
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((d) {
                final data = Map<String, dynamic>.from(d.data());
                data['id'] = d.id;
                return TripModel.fromJson(data);
              }).toList());
    },
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err, stack),
  );
}

@riverpod
Future<TripModel> tripDetails(Ref ref, String tripId) async {
  final res = await ref.watch(tripRepositoryProvider).getTripById(tripId);
  return res.fold((l) => throw l, (r) => r);
}
