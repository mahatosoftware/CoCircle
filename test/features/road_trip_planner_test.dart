import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:cocircle/features/road_trip/domain/road_trip_route_model.dart';
import 'package:cocircle/features/road_trip/domain/vehicle_fuel_model.dart';
import 'package:cocircle/features/road_trip/domain/road_trip_budget_model.dart';
import 'package:cocircle/features/road_trip/domain/road_trip_utilities_model.dart';
import 'package:cocircle/features/road_trip/infrastructure/road_trip_routing_service.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/trips/domain/itinerary_item_model.dart';

void main() {
  group('Phase 1 – Multi-Stop Route Planner Tests', () {
    test('RouteStopModel serialization and deserialization works correctly', () {
      final stop = RouteStopModel(
        id: 'stop_1',
        tripId: 'trip_1',
        name: 'Mysuru Palace',
        address: 'Sayyaji Rao Rd, Mysuru',
        latitude: 12.3052,
        longitude: 76.6552,
        sequence: 1,
        stopType: StopType.attraction,
        estimatedDurationMinutes: 120,
        notes: 'Photography pass required',
        estimatedCost: 200.0,
        dayNumber: 2,
        isVisited: true,
        createdBy: 'user_1',
        createdAt: DateTime(2026, 11, 20),
      );

      final json = stop.toJson();
      expect(json['id'], 'stop_1');
      expect(json['name'], 'Mysuru Palace');
      expect(json['sequence'], 1);
      expect(json['stopType'], 'attraction');
      expect(json['isVisited'], true);

      final deserialized = RouteStopModel.fromJson(json);
      expect(deserialized.id, stop.id);
      expect(deserialized.name, stop.name);
      expect(deserialized.latitude, stop.latitude);
      expect(deserialized.longitude, stop.longitude);
      expect(deserialized.stopType, StopType.attraction);
      expect(deserialized.isVisited, true);
    });

    test('RoadTripRouteModel orderedStops returns stops sorted by sequence', () {
      final now = DateTime.now();
      final stop3 = RouteStopModel(
        id: 's3',
        tripId: 'trip_1',
        name: 'Stop 3',
        latitude: 12.0,
        longitude: 76.0,
        sequence: 3,
        createdBy: 'u1',
        createdAt: now,
      );
      final stop1 = RouteStopModel(
        id: 's1',
        tripId: 'trip_1',
        name: 'Stop 1',
        latitude: 12.2,
        longitude: 76.2,
        sequence: 1,
        createdBy: 'u1',
        createdAt: now,
      );
      final stop2 = RouteStopModel(
        id: 's2',
        tripId: 'trip_1',
        name: 'Stop 2',
        latitude: 12.4,
        longitude: 76.4,
        sequence: 2,
        createdBy: 'u1',
        createdAt: now,
      );

      final route = RoadTripRouteModel(
        id: 'r1',
        tripId: 'trip_1',
        originName: 'Bengaluru',
        originLat: 12.9716,
        originLng: 77.5946,
        destinationName: 'Coorg',
        destinationLat: 12.3375,
        destinationLng: 75.8069,
        stops: [stop3, stop1, stop2],
        createdBy: 'u1',
        updatedAt: now,
      );

      final ordered = route.orderedStops;
      expect(ordered[0].id, 's1');
      expect(ordered[1].id, 's2');
      expect(ordered[2].id, 's3');
    });

    test('RoadTripRoutingService Haversine calculation computes distance and duration', () {
      final points = [
        const LatLng(12.9716, 77.5946), // Bengaluru
        const LatLng(12.6518, 77.2089), // Channapatna
        const LatLng(12.2958, 76.6394), // Mysuru
      ];

      final computed = RoadTripRoutingService.calculateOfflineHaversineRoute(points);
      expect(computed.totalDistanceKm, greaterThan(130.0));
      expect(computed.estimatedDurationMinutes, greaterThan(120));
      expect(computed.polylinePoints.length, 3);
      expect(computed.legDistancesKm.length, 2);
    });

    test('RoadTripRoutingService buildGoogleMapsNavigationUri generates proper URI with waypoints', () {
      final now = DateTime.now();
      final waypoints = <RouteStopModel>[
        RouteStopModel(
          id: 's1',
          tripId: 'trip_1',
          name: 'Ramanagara',
          latitude: 12.7150,
          longitude: 77.2810,
          sequence: 1,
          createdBy: 'u1',
          createdAt: now,
        ),
        RouteStopModel(
          id: 's2',
          tripId: 'trip_1',
          name: 'Kushalnagar',
          latitude: 12.4578,
          longitude: 75.9610,
          sequence: 2,
          createdBy: 'u1',
          createdAt: now,
        ),
      ];

      final uri = RoadTripRoutingService.buildGoogleMapsNavigationUri(
        originLat: 12.9716,
        originLng: 77.5946,
        destinationLat: 12.3375,
        destinationLng: 75.8069,
        waypoints: waypoints,
        mode: TravelMode.car,
      );

      final urlString = uri.toString();
      expect(urlString, startsWith('https://www.google.com/maps/dir/'));
      expect(uri.queryParameters['origin'], '12.9716,77.5946');
      expect(uri.queryParameters['destination'], '12.3375,75.8069');
      expect(uri.queryParameters['travelmode'], 'driving');
      expect(uri.queryParameters['waypoints'], '12.715,77.281|12.4578,75.961');
    });
  });

  group('Phase 2 – Day-Wise Itinerary Integration Tests', () {
    test('ItineraryItemModel supports road trip extensions (dayNumber, stopId, category)', () {
      final now = DateTime.now();
      final item = ItineraryItemModel(
        id: 'act_1',
        tripId: 'trip_1',
        title: 'Abbey Falls Trek',
        type: 'sightseeing',
        category: 'sightseeing',
        location: 'Madikeri, Coorg',
        cost: 150.0,
        dayNumber: 3,
        stopId: 'stop_abbey',
        bookingRef: 'BOOK-1234',
        startTime: now,
        createdBy: 'user_1',
        createdAt: now,
      );

      final json = item.toJson();
      expect(json['dayNumber'], 3);
      expect(json['stopId'], 'stop_abbey');
      expect(json['category'], 'sightseeing');
      expect(json['bookingRef'], 'BOOK-1234');

      final deserialized = ItineraryItemModel.fromJson(json);
      expect(deserialized.dayNumber, 3);
      expect(deserialized.stopId, 'stop_abbey');
      expect(deserialized.category, 'sightseeing');
      expect(deserialized.bookingRef, 'BOOK-1234');
    });
  });

  group('Phase 3 – Fuel Cost Calculator Tests', () {
    test('TripFuelSummary single vehicle baseline calculation with guest participants', () {
      final summary = TripFuelSummary.calculate(
        totalDistanceKm: 600.0,
        vehicles: const [],
        totalParticipants: 5, // 3 registered + 2 guest members
        baselineMileage: 15.0, // 15 km/l
        baselinePrice: 100.0, // ₹100/l
      );

      // 600 km / 15 km/l = 40 litres
      expect(summary.totalFuelUnits, closeTo(40.0, 0.01));
      // 40 litres * ₹100 = ₹4,000
      expect(summary.totalEstimatedCost, closeTo(4000.0, 0.01));
      // ₹4,000 / 5 people = ₹800 per person
      expect(summary.costPerPerson, closeTo(800.0, 0.01));
      expect(summary.participantCount, 5);
    });

    test('TripFuelSummary multi-vehicle convoy calculation', () {
      final vehicle1 = VehicleFuelModel(
        id: 'v1',
        tripId: 'trip_1',
        vehicleName: 'SUV',
        fuelType: FuelType.diesel,
        mileageKmPerUnit: 12.0, // 12 km/l
        fuelPricePerUnit: 90.0, // ₹90/l
        distanceAllocationKm: 500.0, // 500 / 12 = 41.67L => ₹3750
      );

      final vehicle2 = VehicleFuelModel(
        id: 'v2',
        tripId: 'trip_1',
        vehicleName: 'Hatchback',
        fuelType: FuelType.petrol,
        mileageKmPerUnit: 20.0, // 20 km/l
        fuelPricePerUnit: 100.0, // ₹100/l
        distanceAllocationKm: 500.0, // 500 / 20 = 25L => ₹2500
      );

      final summary = TripFuelSummary.calculate(
        totalDistanceKm: 500.0,
        vehicles: [vehicle1, vehicle2],
        totalParticipants: 8,
      );

      // Vehicle 1 fuel: 500 / 12 = 41.666L, Cost = 3750.0
      // Vehicle 2 fuel: 500 / 20 = 25L, Cost = 2500.0
      // Total Cost = 3750 + 2500 = 6250.0
      // Per person = 6250 / 8 = 781.25
      expect(summary.totalFuelUnits, closeTo(66.67, 0.1));
      expect(summary.totalEstimatedCost, closeTo(6250.0, 0.1));
      expect(summary.costPerPerson, closeTo(781.25, 0.1));
    });
  });

  group('Phase 4 – Trip Budget Planner & Health Reports Tests', () {
    test('BudgetUtilizationReport calculates spending ratio and health indicators', () {
      final now = DateTime.now();
      final budget = RoadTripBudgetModel(
        id: 'b1',
        tripId: 'trip_1',
        totalBudget: 50000.0,
        categoryBudgets: {
          RoadTripBudgetCategory.fuel: 10000.0,
          RoadTripBudgetCategory.food: 15000.0,
          RoadTripBudgetCategory.accommodation: 20000.0,
        },
        createdBy: 'u1',
        updatedAt: now,
      );

      final expenses = [
        ExpenseModel(
          id: 'e1',
          tripId: 'trip_1',
          title: 'Petrol Pump Refill',
          amount: 6000.0,
          payerId: 'u1',
          payers: {'u1': 6000.0},
          date: now,
          category: 'fuel',
          createdAt: now,
          createdBy: 'u1',
          splitType: SplitType.equal,
          splitDetails: {'u1': 3000.0, 'guest_1': 3000.0},
        ),
        ExpenseModel(
          id: 'e2',
          tripId: 'trip_1',
          title: 'Highway Dhaba Lunch',
          amount: 4000.0,
          payerId: 'u2',
          payers: {'u2': 4000.0},
          date: now,
          category: 'food',
          createdAt: now,
          createdBy: 'u2',
          splitType: SplitType.equal,
          splitDetails: {'u1': 2000.0, 'guest_1': 2000.0},
        ),
      ];

      // Total spent = 10,000 / 50,000 = 20% => Healthy (Green)
      final report = BudgetUtilizationReport.compute(
        budget: budget,
        actualExpenses: expenses,
        participantCount: 4,
      );

      expect(report.totalActualSpent, 10000.0);
      expect(report.remainingBudget, 40000.0);
      expect(report.utilizationPercentage, closeTo(20.0, 0.01));
      expect(report.health, BudgetHealth.healthy);
      expect(report.perPersonEstimatedBudget, 12500.0);
      expect(report.perPersonActualSpent, 2500.0);
      expect(report.categorySpent[RoadTripBudgetCategory.fuel], 6000.0);
      expect(report.categorySpent[RoadTripBudgetCategory.food], 4000.0);
    });

    test('Budget health turns exceeded (Red) when expenses exceed 100% of budget', () {
      final now = DateTime.now();
      final budget = RoadTripBudgetModel(
        id: 'b1',
        tripId: 'trip_1',
        totalBudget: 10000.0,
        createdBy: 'u1',
        updatedAt: now,
      );

      final expenses = [
        ExpenseModel(
          id: 'e1',
          tripId: 'trip_1',
          title: 'Emergency Vehicle Repair',
          amount: 12000.0,
          payerId: 'u1',
          payers: {'u1': 12000.0},
          date: now,
          category: 'emergency',
          createdAt: now,
          createdBy: 'u1',
          splitType: SplitType.equal,
          splitDetails: {'u1': 12000.0},
        ),
      ];

      final report = BudgetUtilizationReport.compute(
        budget: budget,
        actualExpenses: expenses,
        participantCount: 2,
      );

      expect(report.totalActualSpent, 12000.0);
      expect(report.remainingBudget, -2000.0);
      expect(report.utilizationPercentage, 120.0);
      expect(report.health, BudgetHealth.exceeded);
    });
  });

  group('Phase 5 – Lightweight Road Trip Utilities Tests', () {
    test('CashChangeResult gives exact Indian currency denomination breakdown', () {
      // Bill: ₹638, Cash Given: ₹1000 => Change to return = ₹362
      // Breakdown of ₹362:
      // ₹200 x 1 (rem 162)
      // ₹100 x 1 (rem 62)
      // ₹50 x 1 (rem 12)
      // ₹10 x 1 (rem 2)
      // ₹2 x 1 (rem 0)
      final result = CashChangeResult.calculate(
        billAmount: 638.0,
        cashReceived: 1000.0,
      );

      expect(result.changeToReturn, 362.0);
      expect(result.denominationBreakdown[200], 1);
      expect(result.denominationBreakdown[100], 1);
      expect(result.denominationBreakdown[50], 1);
      expect(result.denominationBreakdown[10], 1);
      expect(result.denominationBreakdown[2], 1);
      expect(result.denominationBreakdown[500], isNull);
    });

    test('CashChangeResult handles exact payment and underpayment', () {
      final exact = CashChangeResult.calculate(billAmount: 500.0, cashReceived: 500.0);
      expect(exact.changeToReturn, 0.0);
      expect(exact.denominationBreakdown.isEmpty, isTrue);

      final short = CashChangeResult.calculate(billAmount: 500.0, cashReceived: 400.0);
      expect(short.changeToReturn, 0.0);
      expect(short.denominationBreakdown.isEmpty, isTrue);
    });

    test('VehicleChecklistItem provides all 12 default pre-trip inspection items', () {
      final defaults = VehicleChecklistItem.defaultInspectionList();
      expect(defaults.length, 12);

      final categories = defaults.map((d) => d.category).toSet();
      expect(categories, contains('mechanical'));
      expect(categories, contains('documents'));
      expect(categories, contains('safety'));

      final titles = defaults.map((d) => d.title).toList();
      expect(titles.any((t) => t.contains('Tyres & Spare Tyre')), isTrue);
      expect(titles.any((t) => t.contains('Engine Oil')), isTrue);
      expect(titles.any((t) => t.contains('Driving Licences')), isTrue);
      expect(titles.any((t) => t.contains('Emergency Medical Kit')), isTrue);
    });
  });
}
