import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/trip_planner_repository_impl.dart';
import '../domain/itinerary_item_model.dart';
import '../domain/lodging_model.dart';
import '../domain/idea_model.dart';
import '../domain/packing_item_model.dart';

part 'trip_planner_controller.g.dart';

@Riverpod(keepAlive: true)
class TripPlannerController extends _$TripPlannerController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  // Itinerary
  Future<void> createItineraryItem({
    required String tripId,
    required String title,
    required String type,
    required DateTime startTime,
    DateTime? endTime,
    String? location,
    String? notes,
    double? cost,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final item = ItineraryItemModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      type: type,
      startTime: startTime,
      endTime: endTime,
      location: location,
      notes: notes,
      cost: cost,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).createItineraryItem(item);
    res.fold(
      (l) {
        debugPrint('Create itinerary item failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity added!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> updateItineraryItem({
    required ItineraryItemModel item,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).updateItineraryItem(item);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity updated!');
      },
    );
  }

  Future<void> deleteItineraryItem({
    required String itemId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).deleteItineraryItem(itemId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Activity deleted');
      },
    );
  }

  // Lodging
  Future<void> createLodging({
    required String tripId,
    required String name,
    String? address,
    required DateTime checkIn,
    required DateTime checkOut,
    String? confirmationNumber,
    String? phoneNumber,
    String? notes,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final lodging = LodgingModel(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
      confirmationNumber: confirmationNumber,
      phoneNumber: phoneNumber,
      notes: notes,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).createLodging(lodging);
    res.fold(
      (l) {
        debugPrint('Create lodging failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay added!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> updateLodging({
    required LodgingModel lodging,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).updateLodging(lodging);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay updated!');
      },
    );
  }

  Future<void> deleteLodging({
    required String lodgingId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).deleteLodging(lodgingId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Lodging stay deleted');
      },
    );
  }

  // Ideas
  Future<void> createIdea({
    required String tripId,
    required String title,
    String? description,
    String? location,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final idea = IdeaModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      description: description,
      location: location,
      votes: [],
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).createIdea(idea);
    res.fold(
      (l) {
        debugPrint('Create idea failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea added to board!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> toggleVoteIdea({
    required String ideaId,
    required String userId,
    required BuildContext context,
  }) async {
    final res = await ref.read(tripPlannerRepositoryProvider).toggleVoteIdea(ideaId, userId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Future<void> promoteIdeaToItinerary({
    required IdeaModel idea,
    required DateTime startTime,
    required String type,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final itineraryItem = ItineraryItemModel(
      id: const Uuid().v4(),
      tripId: idea.tripId,
      title: idea.title,
      type: type,
      startTime: startTime,
      location: idea.location,
      notes: idea.description,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).promoteIdeaToItinerary(idea.id, itineraryItem);
    res.fold(
      (l) {
        debugPrint('Promote idea failed: ${l.message}');
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea promoted to Itinerary!');
        Navigator.pop(context);
      },
    );
  }

  Future<void> deleteIdea({
    required String ideaId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).deleteIdea(ideaId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Idea deleted');
      },
    );
  }

  // Packing List
  Future<void> createPackingItem({
    required String tripId,
    required String title,
    double quantity = 1.0,
    String? assignedTo,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    final item = PackingItemModel(
      id: const Uuid().v4(),
      tripId: tripId,
      title: title,
      quantity: quantity,
      assignedTo: assignedTo,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    final res = await ref.read(tripPlannerRepositoryProvider).createPackingItem(item);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Item added to packing list!');
      },
    );
  }

  Future<void> togglePackingItem({
    required String itemId,
    required bool isPacked,
    required BuildContext context,
  }) async {
    final res = await ref.read(tripPlannerRepositoryProvider).togglePackingItem(itemId, isPacked);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Future<void> assignPackingItem({
    required String itemId,
    required String? userId,
    required BuildContext context,
  }) async {
    final res = await ref.read(tripPlannerRepositoryProvider).assignPackingItem(itemId, userId);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  Future<void> deletePackingItem({
    required String itemId,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();
    final res = await ref.read(tripPlannerRepositoryProvider).deletePackingItem(itemId);
    res.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        showSnackBar(context, l.message);
      },
      (r) {
        state = const AsyncData(null);
        showSnackBar(context, 'Item deleted');
      },
    );
  }
}

@riverpod
Stream<List<ItineraryItemModel>> tripItinerary(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getItineraryStream(tripId);
}

@riverpod
Stream<List<LodgingModel>> tripLodging(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getLodgingStream(tripId);
}

@riverpod
Stream<List<IdeaModel>> tripIdeas(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getIdeasStream(tripId);
}

@riverpod
Stream<List<PackingItemModel>> tripPacking(Ref ref, String tripId) {
  return ref.watch(tripPlannerRepositoryProvider).getPackingStream(tripId);
}
