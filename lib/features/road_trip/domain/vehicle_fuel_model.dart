enum FuelType {
  petrol,
  diesel,
  cng,
  ev,
}

class VehicleFuelModel {
  final String id;
  final String tripId;
  final String vehicleName;
  final FuelType fuelType;
  final double mileageKmPerUnit; // km/L or km/kg or km/kWh
  final double fuelPricePerUnit;  // e.g. ₹105/L
  final double distanceAllocationKm;
  final List<String> assignedMemberIds;
  final String? notes;

  const VehicleFuelModel({
    required this.id,
    required this.tripId,
    required this.vehicleName,
    this.fuelType = FuelType.petrol,
    this.mileageKmPerUnit = 15.0,
    this.fuelPricePerUnit = 105.0,
    this.distanceAllocationKm = 0.0,
    this.assignedMemberIds = const [],
    this.notes,
  });

  /// Fuel required in liters/kg/kWh
  double get fuelRequiredUnits {
    if (mileageKmPerUnit <= 0) return 0.0;
    return distanceAllocationKm / mileageKmPerUnit;
  }

  /// Total fuel cost
  double get estimatedFuelCost {
    return fuelRequiredUnits * fuelPricePerUnit;
  }

  /// Cost per assigned passenger
  double get costPerPassenger {
    if (assignedMemberIds.isEmpty) return estimatedFuelCost;
    return estimatedFuelCost / assignedMemberIds.length;
  }

  VehicleFuelModel copyWith({
    String? id,
    String? tripId,
    String? vehicleName,
    FuelType? fuelType,
    double? mileageKmPerUnit,
    double? fuelPricePerUnit,
    double? distanceAllocationKm,
    List<String>? assignedMemberIds,
    String? notes,
  }) {
    return VehicleFuelModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      vehicleName: vehicleName ?? this.vehicleName,
      fuelType: fuelType ?? this.fuelType,
      mileageKmPerUnit: mileageKmPerUnit ?? this.mileageKmPerUnit,
      fuelPricePerUnit: fuelPricePerUnit ?? this.fuelPricePerUnit,
      distanceAllocationKm: distanceAllocationKm ?? this.distanceAllocationKm,
      assignedMemberIds: assignedMemberIds ?? this.assignedMemberIds,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'vehicleName': vehicleName,
      'fuelType': fuelType.name,
      'mileageKmPerUnit': mileageKmPerUnit,
      'fuelPricePerUnit': fuelPricePerUnit,
      'distanceAllocationKm': distanceAllocationKm,
      'assignedMemberIds': assignedMemberIds,
      'notes': notes,
    };
  }

  factory VehicleFuelModel.fromJson(Map<String, dynamic> json) {
    FuelType parseFuelType(dynamic value) {
      if (value is String) {
        return FuelType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
          orElse: () => FuelType.petrol,
        );
      }
      return FuelType.petrol;
    }

    final members = (json['assignedMemberIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return VehicleFuelModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      vehicleName: json['vehicleName'] as String? ?? 'Vehicle',
      fuelType: parseFuelType(json['fuelType']),
      mileageKmPerUnit: (json['mileageKmPerUnit'] as num?)?.toDouble() ?? 15.0,
      fuelPricePerUnit: (json['fuelPricePerUnit'] as num?)?.toDouble() ?? 105.0,
      distanceAllocationKm: (json['distanceAllocationKm'] as num?)?.toDouble() ?? 0.0,
      assignedMemberIds: members,
      notes: json['notes'] as String?,
    );
  }
}

class TripFuelSummary {
  final double totalDistanceKm;
  final double totalFuelUnits;
  final double totalEstimatedCost;
  final double costPerPerson;
  final int participantCount;
  final List<VehicleFuelModel> vehicles;

  const TripFuelSummary({
    required this.totalDistanceKm,
    required this.totalFuelUnits,
    required this.totalEstimatedCost,
    required this.costPerPerson,
    required this.participantCount,
    required this.vehicles,
  });

  factory TripFuelSummary.calculate({
    required double totalDistanceKm,
    required List<VehicleFuelModel> vehicles,
    required int totalParticipants,
    double baselineMileage = 15.0,
    double baselinePrice = 105.0,
  }) {
    if (vehicles.isEmpty) {
      // Default single vehicle baseline
      final fuel = totalDistanceKm > 0 ? totalDistanceKm / baselineMileage : 0.0;
      final cost = fuel * baselinePrice;
      final perPerson = totalParticipants > 0 ? cost / totalParticipants : cost;

      return TripFuelSummary(
        totalDistanceKm: totalDistanceKm,
        totalFuelUnits: fuel,
        totalEstimatedCost: cost,
        costPerPerson: perPerson,
        participantCount: totalParticipants,
        vehicles: const [],
      );
    }

    double totalFuel = 0.0;
    double totalCost = 0.0;

    for (final v in vehicles) {
      totalFuel += v.fuelRequiredUnits;
      totalCost += v.estimatedFuelCost;
    }

    final perPerson = totalParticipants > 0 ? totalCost / totalParticipants : totalCost;

    return TripFuelSummary(
      totalDistanceKm: totalDistanceKm,
      totalFuelUnits: totalFuel,
      totalEstimatedCost: totalCost,
      costPerPerson: perPerson,
      participantCount: totalParticipants,
      vehicles: vehicles,
    );
  }
}
