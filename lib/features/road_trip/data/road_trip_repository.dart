import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/road_trip_route_model.dart';
import '../domain/vehicle_fuel_model.dart';
import '../domain/road_trip_budget_model.dart';
import '../domain/road_trip_utilities_model.dart';

final roadTripRepositoryProvider = Provider<RoadTripRepository>((ref) {
  return RoadTripRepository(FirebaseFirestore.instance);
});

class RoadTripRepository {
  final FirebaseFirestore _firestore;

  RoadTripRepository(this._firestore);

  DocumentReference<Map<String, dynamic>> _tripDoc(String tripId) =>
      _firestore.collection('trips').doc(tripId);

  // --- 1. Route Management ---
  Stream<RoadTripRouteModel?> getRouteStream(String tripId) {
    return _tripDoc(tripId).collection('roadTripRoutes').doc('current').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return RoadTripRouteModel.fromJson(doc.data()!);
    });
  }

  Future<void> saveRoute(RoadTripRouteModel route) async {
    await _tripDoc(route.tripId)
        .collection('roadTripRoutes')
        .doc('current')
        .set(route.toJson());
  }

  // --- 2. Vehicle & Fuel Management ---
  Stream<List<VehicleFuelModel>> getVehiclesStream(String tripId) {
    return _tripDoc(tripId).collection('vehicles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => VehicleFuelModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> saveVehicle(VehicleFuelModel vehicle) async {
    await _tripDoc(vehicle.tripId)
        .collection('vehicles')
        .doc(vehicle.id)
        .set(vehicle.toJson());
  }

  Future<void> deleteVehicle(String tripId, String vehicleId) async {
    await _tripDoc(tripId).collection('vehicles').doc(vehicleId).delete();
  }

  // --- 3. Road Trip Budget ---
  Stream<RoadTripBudgetModel?> getBudgetStream(String tripId) {
    return _tripDoc(tripId).collection('roadTripBudget').doc('primary').snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return RoadTripBudgetModel.fromJson(doc.data()!);
    });
  }

  Future<void> saveBudget(RoadTripBudgetModel budget) async {
    await _tripDoc(budget.tripId)
        .collection('roadTripBudget')
        .doc('primary')
        .set(budget.toJson());
  }

  // --- 4. Vehicle Readiness Checklist ---
  Stream<List<VehicleChecklistItem>> getChecklistStream(String tripId) {
    return _tripDoc(tripId).collection('vehicleChecklist').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return VehicleChecklistItem.defaultInspectionList();
      }
      return snapshot.docs.map((doc) => VehicleChecklistItem.fromJson(doc.data())).toList();
    });
  }

  Future<void> updateChecklistItem(String tripId, VehicleChecklistItem item) async {
    await _tripDoc(tripId)
        .collection('vehicleChecklist')
        .doc(item.id)
        .set(item.toJson());
  }

  Future<void> seedDefaultChecklist(String tripId) async {
    final batch = _firestore.batch();
    final items = VehicleChecklistItem.defaultInspectionList();
    for (final item in items) {
      final ref = _tripDoc(tripId).collection('vehicleChecklist').doc(item.id);
      batch.set(ref, item.toJson());
    }
    await batch.commit();
  }
}
