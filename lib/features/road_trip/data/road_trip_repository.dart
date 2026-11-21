import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  Stream<RoadTripRouteModel?> getRouteStream(String tripId) async* {
    try {
      await for (final doc in _tripDoc(tripId).collection('roadTripRoutes').doc('current').snapshots()) {
        if (!doc.exists || doc.data() == null) {
          yield null;
        } else {
          try {
            yield RoadTripRouteModel.fromJson(doc.data()!);
          } catch (e) {
            debugPrint("RoadTripRepository: Error parsing RoadTripRouteModel: $e");
            yield null;
          }
        }
      }
    } catch (e) {
      debugPrint("RoadTripRepository: getRouteStream error: $e");
      yield null;
    }
  }

  Future<void> saveRoute(RoadTripRouteModel route) async {
    await _tripDoc(route.tripId)
        .collection('roadTripRoutes')
        .doc('current')
        .set(route.toJson());
  }

  // --- 2. Vehicle & Fuel Management ---
  Stream<List<VehicleFuelModel>> getVehiclesStream(String tripId) async* {
    try {
      await for (final snapshot in _tripDoc(tripId).collection('vehicles').snapshots()) {
        yield snapshot.docs.map((doc) => VehicleFuelModel.fromJson(doc.data())).toList();
      }
    } catch (e) {
      debugPrint("RoadTripRepository: getVehiclesStream error: $e");
      yield [];
    }
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
  Stream<RoadTripBudgetModel?> getBudgetStream(String tripId) async* {
    try {
      await for (final doc in _tripDoc(tripId).collection('roadTripBudget').doc('primary').snapshots()) {
        if (!doc.exists || doc.data() == null) {
          yield null;
        } else {
          try {
            yield RoadTripBudgetModel.fromJson(doc.data()!);
          } catch (e) {
            debugPrint("RoadTripRepository: Error parsing RoadTripBudgetModel: $e");
            yield null;
          }
        }
      }
    } catch (e) {
      debugPrint("RoadTripRepository: getBudgetStream error: $e");
      yield null;
    }
  }

  Future<void> saveBudget(RoadTripBudgetModel budget) async {
    await _tripDoc(budget.tripId)
        .collection('roadTripBudget')
        .doc('primary')
        .set(budget.toJson());
  }

  // --- 4. Vehicle Readiness Checklist ---
  Stream<List<VehicleChecklistItem>> getChecklistStream(String tripId) async* {
    try {
      await for (final snapshot in _tripDoc(tripId).collection('vehicleChecklist').snapshots()) {
        if (snapshot.docs.isEmpty) {
          yield VehicleChecklistItem.defaultInspectionList();
        } else {
          yield snapshot.docs.map((doc) => VehicleChecklistItem.fromJson(doc.data())).toList();
        }
      }
    } catch (e) {
      debugPrint("RoadTripRepository: getChecklistStream error: $e");
      yield VehicleChecklistItem.defaultInspectionList();
    }
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
