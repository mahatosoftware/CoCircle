import 'package:cloud_firestore/cloud_firestore.dart';

class LodgingModel {
  final String id;
  final String tripId;
  final String name;
  final String? address;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? confirmationNumber;
  final String? phoneNumber;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const LodgingModel({
    required this.id,
    required this.tripId,
    required this.name,
    this.address,
    required this.checkIn,
    required this.checkOut,
    this.confirmationNumber,
    this.phoneNumber,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  LodgingModel copyWith({
    String? id,
    String? tripId,
    String? name,
    String? address,
    DateTime? checkIn,
    DateTime? checkOut,
    String? confirmationNumber,
    String? phoneNumber,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return LodgingModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      address: address ?? this.address,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      confirmationNumber: confirmationNumber ?? this.confirmationNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notes: notes ?? this.notes,
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
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'confirmationNumber': confirmationNumber,
      'phoneNumber': phoneNumber,
      'notes': notes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LodgingModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return LodgingModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      checkIn: parseDate(json['checkIn']),
      checkOut: parseDate(json['checkOut']),
      confirmationNumber: json['confirmationNumber'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
