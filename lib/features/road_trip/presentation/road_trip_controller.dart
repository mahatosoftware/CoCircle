import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../data/road_trip_repository.dart';
import '../domain/road_trip_route_model.dart';
import '../domain/vehicle_fuel_model.dart';
import '../domain/road_trip_budget_model.dart';
import '../domain/road_trip_utilities_model.dart';
import '../infrastructure/road_trip_routing_service.dart';

final roadTripRoutingServiceProvider = Provider<RoadTripRoutingService>((ref) {
  return RoadTripRoutingService();
});

final roadTripRouteStreamProvider =
    StreamProvider.family<RoadTripRouteModel?, String>((ref, tripId) {
  return ref.watch(roadTripRepositoryProvider).getRouteStream(tripId);
});

final roadTripVehiclesStreamProvider =
    StreamProvider.family<List<VehicleFuelModel>, String>((ref, tripId) {
  return ref.watch(roadTripRepositoryProvider).getVehiclesStream(tripId);
});

final roadTripBudgetStreamProvider =
    StreamProvider.family<RoadTripBudgetModel?, String>((ref, tripId) {
  return ref.watch(roadTripRepositoryProvider).getBudgetStream(tripId);
});

final roadTripChecklistStreamProvider =
    StreamProvider.family<List<VehicleChecklistItem>, String>((ref, tripId) {
  return ref.watch(roadTripRepositoryProvider).getChecklistStream(tripId);
});

final roadTripControllerProvider = Provider<RoadTripController>((ref) {
  return RoadTripController(ref);
});

class RoadTripController {
  final Ref _ref;

  RoadTripController(this._ref);

  RoadTripRepository get _repo => _ref.read(roadTripRepositoryProvider);
  RoadTripRoutingService get _routingService => _ref.read(roadTripRoutingServiceProvider);

  // --- Route & Stops Actions ---

  /// Seeds or updates base route origin and destination
  Future<void> initializeRoute({
    required String tripId,
    required String originName,
    required double originLat,
    required double originLng,
    required String destinationName,
    required double destinationLat,
    required double destinationLng,
    String? returnDestinationName,
    double? returnDestinationLat,
    double? returnDestinationLng,
    TravelMode mode = TravelMode.car,
  }) async {
    final user = await _ref.read(authRepositoryProvider).getCurrentUser();
    final uid = user?.uid ?? 'organizer';

    // Calculate routing
    final calc = await _routingService.calculateRoute(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      returnDestinationLat: returnDestinationLat,
      returnDestinationLng: returnDestinationLng,
      mode: mode,
    );

    final route = RoadTripRouteModel(
      id: const Uuid().v4(),
      tripId: tripId,
      originName: originName,
      originLat: originLat,
      originLng: originLng,
      destinationName: destinationName,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      returnDestinationName: returnDestinationName,
      returnDestinationLat: returnDestinationLat,
      returnDestinationLng: returnDestinationLng,
      travelMode: mode,
      stops: const [],
      totalDistanceKm: calc.totalDistanceKm,
      estimatedDurationMinutes: calc.estimatedDurationMinutes,
      routePolyline: calc.polylinePoints.isNotEmpty ? 'calculated' : null,
      createdBy: uid,
      updatedAt: DateTime.now(),
    );

    await _repo.saveRoute(route);
  }

  /// Adds a new intermediate stop and recalculates route totals
  Future<void> addStop(String tripId, RouteStopModel stop) async {
    final currentRoute = await _ref.read(roadTripRouteStreamProvider(tripId).future);
    if (currentRoute == null) return;

    final updatedStops = List<RouteStopModel>.from(currentRoute.stops);
    final newSequence = updatedStops.isEmpty ? 1 : updatedStops.length + 1;
    final configuredStop = stop.copyWith(sequence: newSequence);
    updatedStops.add(configuredStop);

    // Recalculate route
    final calc = await _routingService.calculateRoute(
      originLat: currentRoute.originLat,
      originLng: currentRoute.originLng,
      destinationLat: currentRoute.destinationLat,
      destinationLng: currentRoute.destinationLng,
      returnDestinationLat: currentRoute.returnDestinationLat,
      returnDestinationLng: currentRoute.returnDestinationLng,
      intermediateStops: updatedStops,
      mode: currentRoute.travelMode,
    );

    final updatedRoute = currentRoute.copyWith(
      stops: updatedStops,
      totalDistanceKm: calc.totalDistanceKm,
      estimatedDurationMinutes: calc.estimatedDurationMinutes,
      updatedAt: DateTime.now(),
    );

    await _repo.saveRoute(updatedRoute);
  }

  /// Updates an existing stop
  Future<void> updateStop(String tripId, RouteStopModel stop) async {
    final currentRoute = await _ref.read(roadTripRouteStreamProvider(tripId).future);
    if (currentRoute == null) return;

    final updatedStops = currentRoute.stops.map((s) => s.id == stop.id ? stop : s).toList();

    final calc = await _routingService.calculateRoute(
      originLat: currentRoute.originLat,
      originLng: currentRoute.originLng,
      destinationLat: currentRoute.destinationLat,
      destinationLng: currentRoute.destinationLng,
      returnDestinationLat: currentRoute.returnDestinationLat,
      returnDestinationLng: currentRoute.returnDestinationLng,
      intermediateStops: updatedStops,
      mode: currentRoute.travelMode,
    );

    final updatedRoute = currentRoute.copyWith(
      stops: updatedStops,
      totalDistanceKm: calc.totalDistanceKm,
      estimatedDurationMinutes: calc.estimatedDurationMinutes,
      updatedAt: DateTime.now(),
    );

    await _repo.saveRoute(updatedRoute);
  }

  /// Removes a stop and shifts sequence indices
  Future<void> removeStop(String tripId, String stopId) async {
    final currentRoute = await _ref.read(roadTripRouteStreamProvider(tripId).future);
    if (currentRoute == null) return;

    final remainingStops = currentRoute.stops.where((s) => s.id != stopId).toList();
    for (int i = 0; i < remainingStops.length; i++) {
      remainingStops[i] = remainingStops[i].copyWith(sequence: i + 1);
    }

    final calc = await _routingService.calculateRoute(
      originLat: currentRoute.originLat,
      originLng: currentRoute.originLng,
      destinationLat: currentRoute.destinationLat,
      destinationLng: currentRoute.destinationLng,
      returnDestinationLat: currentRoute.returnDestinationLat,
      returnDestinationLng: currentRoute.returnDestinationLng,
      intermediateStops: remainingStops,
      mode: currentRoute.travelMode,
    );

    final updatedRoute = currentRoute.copyWith(
      stops: remainingStops,
      totalDistanceKm: calc.totalDistanceKm,
      estimatedDurationMinutes: calc.estimatedDurationMinutes,
      updatedAt: DateTime.now(),
    );

    await _repo.saveRoute(updatedRoute);
  }

  /// Reorders stops from drag-and-drop
  Future<void> reorderStops(String tripId, int oldIndex, int newIndex) async {
    final currentRoute = await _ref.read(roadTripRouteStreamProvider(tripId).future);
    if (currentRoute == null) return;

    final stops = List<RouteStopModel>.from(currentRoute.stops);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);

    for (int i = 0; i < stops.length; i++) {
      stops[i] = stops[i].copyWith(sequence: i + 1);
    }

    final calc = await _routingService.calculateRoute(
      originLat: currentRoute.originLat,
      originLng: currentRoute.originLng,
      destinationLat: currentRoute.destinationLat,
      destinationLng: currentRoute.destinationLng,
      returnDestinationLat: currentRoute.returnDestinationLat,
      returnDestinationLng: currentRoute.returnDestinationLng,
      intermediateStops: stops,
      mode: currentRoute.travelMode,
    );

    final updatedRoute = currentRoute.copyWith(
      stops: stops,
      totalDistanceKm: calc.totalDistanceKm,
      estimatedDurationMinutes: calc.estimatedDurationMinutes,
      updatedAt: DateTime.now(),
    );

    await _repo.saveRoute(updatedRoute);
  }

  // --- Vehicles & Fuel ---
  Future<void> saveVehicle(VehicleFuelModel vehicle) async {
    await _repo.saveVehicle(vehicle);
  }

  Future<void> deleteVehicle(String tripId, String vehicleId) async {
    await _repo.deleteVehicle(tripId, vehicleId);
  }

  // --- Budget ---
  Future<void> saveBudget(RoadTripBudgetModel budget) async {
    await _repo.saveBudget(budget);
  }

  // --- Checklist ---
  Future<void> toggleChecklistItem(String tripId, String itemId, bool isCompleted, String? memberName) async {
    final items = await _ref.read(roadTripChecklistStreamProvider(tripId).future);
    final target = items.firstWhere((it) => it.id == itemId, orElse: () => VehicleChecklistItem(id: itemId, title: '', description: '', category: ''));
    final updated = target.copyWith(
      isCompleted: isCompleted,
      assignedMemberName: memberName,
      completedAt: isCompleted ? DateTime.now() : null,
    );
    await _repo.updateChecklistItem(tripId, updated);
  }
}
