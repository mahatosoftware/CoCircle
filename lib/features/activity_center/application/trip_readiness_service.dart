import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../live_map/data/realtime_location_repository_impl.dart';
import '../../tasks/presentation/task_controller.dart';
import '../../trips/presentation/trip_controller.dart';
import '../../trips/presentation/trip_planner_controller.dart';
import '../domain/trip_readiness_model.dart';

final tripReadinessProvider = Provider.family<TripReadinessModel, String>((ref, tripId) {
  final tripAsync = ref.watch(tripDetailsProvider(tripId));
  final trip = tripAsync.value;

  final tripName = trip?.name ?? 'Trip';

  // 1. Calculate trip duration
  int durationDays = 2;
  if (trip?.startDate != null && trip?.endDate != null) {
    final diff = trip!.endDate!.difference(trip.startDate!).inDays + 1;
    if (diff > 0) durationDays = diff;
  }

  // 2. Stays / Lodging
  final lodgings = ref.watch(tripLodgingProvider(tripId)).value ?? [];
  final targetLodgings = durationDays > 1 ? 1 : 0;
  final lodgingScore = durationDays <= 1
      ? 1.0
      : (lodgings.isNotEmpty ? 1.0 : 0.0);

  // 3. Itinerary Activities
  final itinerary = ref.watch(tripItineraryProvider(tripId)).value ?? [];
  final plannedDays = itinerary
      .map((item) => DateTime(item.startTime.year, item.startTime.month, item.startTime.day))
      .toSet()
      .length;
  final itineraryScore = durationDays > 0
      ? min(1.0, plannedDays / durationDays)
      : (itinerary.isNotEmpty ? 1.0 : 0.0);

  // 4. Vehicles & Travel
  final vehiclesMap = ref.watch(_tripVehiclesStreamProvider(tripId)).value ?? {};
  final vehiclesCount = vehiclesMap.length;
  final travelScore = vehiclesCount > 0 ? 1.0 : 0.4;

  // 5. Tasks
  final tasks = ref.watch(tripTasksProvider(tripId)).value ?? [];
  final completedTasks = tasks.where((t) => t.isCompleted).length;
  final taskScore = tasks.isEmpty ? 0.8 : (completedTasks / tasks.length);

  // 6. Packing & Supplies
  final packing = ref.watch(tripPackingProvider(tripId)).value ?? [];
  final packedItems = packing.where((p) => p.isPacked).length;
  final packingScore = packing.isEmpty ? 0.8 : (packedItems / packing.length);

  // Categories definition
  final categories = [
    ReadinessCategory(
      title: 'Stays & Lodging',
      completed: lodgings.length,
      total: max(1, targetLodgings),
      score: lodgingScore,
      icon: Icons.hotel_rounded,
      statusText: lodgings.isNotEmpty
          ? '${lodgings.length} booked'
          : (durationDays <= 1 ? 'Day trip' : 'Not booked'),
    ),
    ReadinessCategory(
      title: 'Itinerary Schedule',
      completed: plannedDays,
      total: durationDays,
      score: itineraryScore,
      icon: Icons.explore_rounded,
      statusText: '$plannedDays of $durationDays days planned',
    ),
    ReadinessCategory(
      title: 'Travel & Convoy',
      completed: vehiclesCount,
      total: max(1, vehiclesCount),
      score: travelScore,
      icon: Icons.directions_car_rounded,
      statusText: vehiclesCount > 0
          ? '$vehiclesCount vehicles ready'
          : 'No convoy vehicle',
    ),
    ReadinessCategory(
      title: 'Prep Tasks',
      completed: completedTasks,
      total: tasks.length,
      score: taskScore,
      icon: Icons.task_alt_rounded,
      statusText: tasks.isNotEmpty
          ? '$completedTasks/${tasks.length} completed'
          : 'No tasks added',
    ),
    ReadinessCategory(
      title: 'Packing Supplies',
      completed: packedItems,
      total: packing.length,
      score: packingScore,
      icon: Icons.backpack_rounded,
      statusText: packing.isNotEmpty
          ? '$packedItems/${packing.length} packed'
          : 'Checklist empty',
    ),
  ];

  // Weighted overall calculation:
  // Lodging: 25%, Itinerary: 25%, Travel: 15%, Tasks: 20%, Packing: 15%
  final weighted = (lodgingScore * 0.25) +
      (itineraryScore * 0.25) +
      (travelScore * 0.15) +
      (taskScore * 0.20) +
      (packingScore * 0.15);

  final overall = (weighted * 100).round().clamp(0, 100);

  // Identify Critical Blockers and Recommended Actions
  final blockers = <String>[];
  final recommendations = <String>[];

  if (durationDays > 1 && lodgings.isEmpty) {
    blockers.add('No hotel or stay confirmed for $durationDays-day trip.');
  }
  if (itinerary.isEmpty) {
    blockers.add('Itinerary is empty. Add day-wise sightseeing or stops.');
  }

  if (vehiclesCount == 0) {
    recommendations.add('Register a vehicle in the Live Convoy tab.');
  }
  final pendingTasksCount = tasks.where((t) => !t.isCompleted).length;
  if (pendingTasksCount > 0) {
    recommendations.add('Complete $pendingTasksCount pending preparation tasks.');
  }
  final neededPackingCount = packing.where((p) => !p.isPacked).length;
  if (neededPackingCount > 0) {
    recommendations.add('Pack or claim $neededPackingCount remaining items.');
  }
  if (itinerary.isNotEmpty && plannedDays < durationDays) {
    recommendations.add('Plan activities for the remaining ${durationDays - plannedDays} days.');
  }

  return TripReadinessModel(
    tripId: tripId,
    tripName: tripName,
    overallScore: overall,
    categories: categories,
    criticalBlockers: blockers,
    recommendedActions: recommendations,
  );
});

final _tripVehiclesStreamProvider = StreamProvider.family<Map<String, Map<String, dynamic>>, String>((ref, tripId) {
  return ref.watch(realtimeLocationRepositoryProvider).streamVehicles(tripId);
});
