enum TripParticipantType {
  registered,
  guest,
}

class TripParticipantModel {
  final String id; // Unique member ID (e.g. "mem_123" or guest ID or Firebase UID)
  final String tripId;
  final String name;
  final TripParticipantType participantType;
  final String? userId; // Firebase Auth UID if registered, null if guest until converted
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? notes;
  final String addedBy; // Organizer's userId
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // 'active', 'removed'
  final DateTime? convertedAt;
  final String? convertedBy;

  const TripParticipantModel({
    required this.id,
    required this.tripId,
    required this.name,
    required this.participantType,
    this.userId,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.notes,
    required this.addedBy,
    required this.createdAt,
    this.updatedAt,
    this.status = 'active',
    this.convertedAt,
    this.convertedBy,
  });

  bool get isGuest => participantType == TripParticipantType.guest;
  bool get isRegistered => participantType == TripParticipantType.registered;
  bool get isActive => status == 'active';
  String get displayName => name;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  TripParticipantModel copyWith({
    String? id,
    String? tripId,
    String? name,
    TripParticipantType? participantType,
    String? userId,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? notes,
    String? addedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    DateTime? convertedAt,
    String? convertedBy,
  }) {
    return TripParticipantModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      participantType: participantType ?? this.participantType,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notes: notes ?? this.notes,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      convertedAt: convertedAt ?? this.convertedAt,
      convertedBy: convertedBy ?? this.convertedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'name': name,
      'participantType': participantType.name,
      'userId': userId,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'notes': notes,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
      'convertedAt': convertedAt?.toIso8601String(),
      'convertedBy': convertedBy,
    };
  }

  factory TripParticipantModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    final typeStr = json['participantType'] as String? ?? 'registered';
    final participantType = typeStr == 'guest'
        ? TripParticipantType.guest
        : TripParticipantType.registered;

    return TripParticipantModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      name: json['name'] as String? ?? 'Participant',
      participantType: participantType,
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      notes: json['notes'] as String?,
      addedBy: json['addedBy'] as String? ?? '',
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      status: json['status'] as String? ?? 'active',
      convertedAt: json['convertedAt'] != null ? parseDate(json['convertedAt']) : null,
      convertedBy: json['convertedBy'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripParticipantModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tripId == other.tripId &&
          participantType == other.participantType &&
          userId == other.userId &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ tripId.hashCode ^ name.hashCode;
}
