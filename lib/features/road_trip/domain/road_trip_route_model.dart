import 'package:cloud_firestore/cloud_firestore.dart';

enum TravelMode {
  car,
  motorcycle,
  suv,
  van,
}

enum StopType {
  origin,
  intermediate,
  fuel,
  meal,
  attraction,
  stay,
  destination,
}

class RouteStopModel {
  final String id;
  final String tripId;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final int sequence;
  final int dayNumber;
  final StopType stopType;
  final int estimatedDurationMinutes;
  final double estimatedCost;
  final bool isOptional;
  final bool isVisited;
  final String? notes;
  final String? linkedActivityId;
  final String createdBy;
  final DateTime createdAt;

  const RouteStopModel({
    required this.id,
    required this.tripId,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.dayNumber = 1,
    this.stopType = StopType.intermediate,
    this.estimatedDurationMinutes = 30,
    this.estimatedCost = 0.0,
    this.isOptional = false,
    this.isVisited = false,
    this.notes,
    this.linkedActivityId,
    required this.createdBy,
    required this.createdAt,
  });

  RouteStopModel copyWith({
    String? id,
    String? tripId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? sequence,
    int? dayNumber,
    StopType? stopType,
    int? estimatedDurationMinutes,
    double? estimatedCost,
    bool? isOptional,
    bool? isVisited,
    String? notes,
    String? linkedActivityId,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return RouteStopModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sequence: sequence ?? this.sequence,
      dayNumber: dayNumber ?? this.dayNumber,
      stopType: stopType ?? this.stopType,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isOptional: isOptional ?? this.isOptional,
      isVisited: isVisited ?? this.isVisited,
      notes: notes ?? this.notes,
      linkedActivityId: linkedActivityId ?? this.linkedActivityId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'dayNumber': dayNumber,
      'stopType': stopType.name,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'estimatedCost': estimatedCost,
      'isOptional': isOptional,
      'isVisited': isVisited,
      'notes': notes,
      'linkedActivityId': linkedActivityId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    StopType parseStopType(dynamic value) {
      if (value is String) {
        return StopType.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
          orElse: () => StopType.intermediate,
        );
      }
      return StopType.intermediate;
    }

    return RouteStopModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      stopType: parseStopType(json['stopType']),
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 30,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      isOptional: json['isOptional'] as bool? ?? false,
      isVisited: json['isVisited'] as bool? ?? false,
      notes: json['notes'] as String?,
      linkedActivityId: json['linkedActivityId'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class RoadTripRouteModel {
  final String id;
  final String tripId;
  final String originName;
  final double originLat;
  final double originLng;
  final String destinationName;
  final double destinationLat;
  final double destinationLng;
  final String? returnDestinationName;
  final double? returnDestinationLat;
  final double? returnDestinationLng;
  final TravelMode travelMode;
  final List<RouteStopModel> stops;
  final double totalDistanceKm;
  final int estimatedDurationMinutes;
  final String? routePolyline;
  final String createdBy;
  final DateTime updatedAt;

  const RoadTripRouteModel({
    required this.id,
    required this.tripId,
    required this.originName,
    required this.originLat,
    required this.originLng,
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
    this.returnDestinationName,
    this.returnDestinationLat,
    this.returnDestinationLng,
    this.travelMode = TravelMode.car,
    this.stops = const [],
    this.totalDistanceKm = 0.0,
    this.estimatedDurationMinutes = 0,
    this.routePolyline,
    required this.createdBy,
    required this.updatedAt,
  });

  /// Returns stops ordered by their sequence number
  List<RouteStopModel> get orderedStops =>
      List<RouteStopModel>.from(stops)..sort((a, b) => a.sequence.compareTo(b.sequence));

  RoadTripRouteModel copyWith({
    String? id,
    String? tripId,
    String? originName,
    double? originLat,
    double? originLng,
    String? destinationName,
    double? destinationLat,
    double? destinationLng,
    String? returnDestinationName,
    double? returnDestinationLat,
    double? returnDestinationLng,
    TravelMode? travelMode,
    List<RouteStopModel>? stops,
    double? totalDistanceKm,
    int? estimatedDurationMinutes,
    String? routePolyline,
    String? createdBy,
    DateTime? updatedAt,
  }) {
    return RoadTripRouteModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      originName: originName ?? this.originName,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationName: destinationName ?? this.destinationName,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      returnDestinationName: returnDestinationName ?? this.returnDestinationName,
      returnDestinationLat: returnDestinationLat ?? this.returnDestinationLat,
      returnDestinationLng: returnDestinationLng ?? this.returnDestinationLng,
      travelMode: travelMode ?? this.travelMode,
      stops: stops ?? this.stops,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      routePolyline: routePolyline ?? this.routePolyline,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'originName': originName,
      'originLat': originLat,
      'originLng': originLng,
      'destinationName': destinationName,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'returnDestinationName': returnDestinationName,
      'returnDestinationLat': returnDestinationLat,
      'returnDestinationLng': returnDestinationLng,
      'travelMode': travelMode.name,
      'stops': stops.map((s) => s.toJson()).toList(),
      'totalDistanceKm': totalDistanceKm,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'routePolyline': routePolyline,
      'createdBy': createdBy,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory RoadTripRouteModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    TravelMode parseMode(dynamic value) {
      if (value is String) {
        return TravelMode.values.firstWhere(
          (e) => e.name.toLowerCase() == value.toLowerCase(),
          orElse: () => TravelMode.car,
        );
      }
      return TravelMode.car;
    }

    final rawStops = json['stops'] as List<dynamic>? ?? [];
    final stops = rawStops
        .map((s) => RouteStopModel.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList()
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    return RoadTripRouteModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      originName: json['originName'] as String? ?? '',
      originLat: (json['originLat'] as num?)?.toDouble() ?? 0.0,
      originLng: (json['originLng'] as num?)?.toDouble() ?? 0.0,
      destinationName: json['destinationName'] as String? ?? '',
      destinationLat: (json['destinationLat'] as num?)?.toDouble() ?? 0.0,
      destinationLng: (json['destinationLng'] as num?)?.toDouble() ?? 0.0,
      returnDestinationName: json['returnDestinationName'] as String?,
      returnDestinationLat: (json['returnDestinationLat'] as num?)?.toDouble(),
      returnDestinationLng: (json['returnDestinationLng'] as num?)?.toDouble(),
      travelMode: parseMode(json['travelMode']),
      stops: stops,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      routePolyline: json['routePolyline'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}
