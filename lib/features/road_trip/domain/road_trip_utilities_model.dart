class CashChangeResult {
  final double billAmount;
  final double cashReceived;
  final double changeToReturn;
  final Map<int, int> denominationBreakdown; // Note Value -> Count

  const CashChangeResult({
    required this.billAmount,
    required this.cashReceived,
    required this.changeToReturn,
    required this.denominationBreakdown,
  });

  factory CashChangeResult.calculate({
    required double billAmount,
    required double cashReceived,
  }) {
    if (cashReceived < billAmount) {
      return CashChangeResult(
        billAmount: billAmount,
        cashReceived: cashReceived,
        changeToReturn: 0.0,
        denominationBreakdown: {},
      );
    }

    final diff = cashReceived - billAmount;
    int remainingPaise = (diff * 100).round();

    // Standard Indian Rupee denominations in rupees
    const denominations = [500, 200, 100, 50, 20, 10, 5, 2, 1];
    final breakdown = <int, int>{};

    for (final denom in denominations) {
      final denomPaise = denom * 100;
      if (remainingPaise >= denomPaise) {
        final count = remainingPaise ~/ denomPaise;
        breakdown[denom] = count;
        remainingPaise %= denomPaise;
      }
    }

    return CashChangeResult(
      billAmount: billAmount,
      cashReceived: cashReceived,
      changeToReturn: diff,
      denominationBreakdown: breakdown,
    );
  }
}

class VehicleChecklistItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'mechanical', 'documents', 'safety'
  final bool isCompleted;
  final String? assignedMemberName;
  final DateTime? completedAt;

  const VehicleChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.isCompleted = false,
    this.assignedMemberName,
    this.completedAt,
  });

  VehicleChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    String? assignedMemberName,
    DateTime? completedAt,
  }) {
    return VehicleChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      assignedMemberName: assignedMemberName ?? this.assignedMemberName,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'assignedMemberName': assignedMemberName,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory VehicleChecklistItem.fromJson(Map<String, dynamic> json) {
    return VehicleChecklistItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'mechanical',
      isCompleted: json['isCompleted'] as bool? ?? false,
      assignedMemberName: json['assignedMemberName'] as String?,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
    );
  }

  static List<VehicleChecklistItem> defaultInspectionList() {
    return const [
      VehicleChecklistItem(
        id: 'chk_tyres',
        title: 'Tyres & Spare Tyre',
        description: 'Check tread depth and air pressure in all 4 wheels + spare wheel',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_brakes',
        title: 'Brake Pads & Fluid',
        description: 'Ensure brake pedal firmness and adequate brake fluid level',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_oil',
        title: 'Engine Oil Dipstick',
        description: 'Check engine oil level and color; top up if near minimum mark',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_coolant',
        title: 'Coolant & Radiator',
        description: 'Ensure coolant reservoir is filled to the MAX level',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_fuel',
        title: 'Fuel Tank Full',
        description: 'Fill tank before highway departure to avoid remote highway surcharges',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_lights',
        title: 'Headlights & Fog Lamps',
        description: 'Test high beam, low beam, hazard indicators, and tail lights',
        category: 'safety',
      ),
      VehicleChecklistItem(
        id: 'chk_battery',
        title: 'Car Battery & Terminals',
        description: 'Clean corrosion on terminals and check voltage health',
        category: 'mechanical',
      ),
      VehicleChecklistItem(
        id: 'chk_dl',
        title: 'Driving Licences (Originals)',
        description: 'Original DL for primary and backup designated drivers',
        category: 'documents',
      ),
      VehicleChecklistItem(
        id: 'chk_rc',
        title: 'Vehicle Registration (RC)',
        description: 'Original physical RC card or verified mParivahan digital copy',
        category: 'documents',
      ),
      VehicleChecklistItem(
        id: 'chk_insurance',
        title: 'Comprehensive Insurance',
        description: 'Valid policy document with roadside assistance (RSA) number saved',
        category: 'documents',
      ),
      VehicleChecklistItem(
        id: 'chk_puc',
        title: 'Pollution Certificate (PUC)',
        description: 'Valid emissions certificate to avoid interstate highway fines',
        category: 'documents',
      ),
      VehicleChecklistItem(
        id: 'chk_emergency',
        title: 'Emergency Medical Kit & Jack',
        description: 'Bandages, antiseptic, tire jack, wheel wrench, and warning triangle',
        category: 'safety',
      ),
    ];
  }
}
