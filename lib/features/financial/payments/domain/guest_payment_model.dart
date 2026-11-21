class GuestPaymentModel {
  final String id;
  final String tripId;
  final String fromMemberId;
  final String toMemberId;
  final double amount;
  final String paymentMethod; // 'cash', 'upi', 'bank_transfer', 'other'
  final DateTime paymentDate;
  final String? referenceNumber;
  final String? receiptUrl;
  final String recordedBy;
  final bool recordedOnBehalfOfGuest;
  final String paymentStatus; // 'pending', 'completed', 'verified', 'settled'
  final String? notes;
  final DateTime createdAt;

  const GuestPaymentModel({
    required this.id,
    required this.tripId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.referenceNumber,
    this.receiptUrl,
    required this.recordedBy,
    this.recordedOnBehalfOfGuest = false,
    this.paymentStatus = 'completed',
    this.notes,
    required this.createdAt,
  });

  GuestPaymentModel copyWith({
    String? id,
    String? tripId,
    String? fromMemberId,
    String? toMemberId,
    double? amount,
    String? paymentMethod,
    DateTime? paymentDate,
    String? referenceNumber,
    String? receiptUrl,
    String? recordedBy,
    bool? recordedOnBehalfOfGuest,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
  }) {
    return GuestPaymentModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      fromMemberId: fromMemberId ?? this.fromMemberId,
      toMemberId: toMemberId ?? this.toMemberId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedOnBehalfOfGuest: recordedOnBehalfOfGuest ?? this.recordedOnBehalfOfGuest,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'fromMemberId': fromMemberId,
      'toMemberId': toMemberId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
      'referenceNumber': referenceNumber,
      'receiptUrl': receiptUrl,
      'recordedBy': recordedBy,
      'recordedOnBehalfOfGuest': recordedOnBehalfOfGuest,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GuestPaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return GuestPaymentModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      fromMemberId: json['fromMemberId'] as String? ?? '',
      toMemberId: json['toMemberId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      paymentDate: parseDate(json['paymentDate']),
      referenceNumber: json['referenceNumber'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      recordedBy: json['recordedBy'] as String? ?? '',
      recordedOnBehalfOfGuest: json['recordedOnBehalfOfGuest'] as bool? ?? false,
      paymentStatus: json['paymentStatus'] as String? ?? 'completed',
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
