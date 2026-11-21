import 'scanned_bill_model.dart';

class BillSplitResult {
  final Map<String, double> memberShares;
  final Map<String, double> itemSubtotals;
  final Map<String, double> memberTaxes;
  final Map<String, double> memberDiscounts;
  final double totalCalculated;
  final double grandTotal;
  final bool isBalanced;

  const BillSplitResult({
    required this.memberShares,
    required this.itemSubtotals,
    required this.memberTaxes,
    required this.memberDiscounts,
    required this.totalCalculated,
    required this.grandTotal,
    required this.isBalanced,
  });
}

class BillSplitCalculator {
  /// Computes fair, proportional item-level splits with tax and discount allocation
  static BillSplitResult calculate({
    required ScannedBill bill,
    required List<String> allMemberIds,
  }) {
    if (allMemberIds.isEmpty) {
      return const BillSplitResult(
        memberShares: {},
        itemSubtotals: {},
        memberTaxes: {},
        memberDiscounts: {},
        totalCalculated: 0.0,
        grandTotal: 0.0,
        isBalanced: true,
      );
    }

    final itemSubtotals = <String, double>{
      for (final id in allMemberIds) id: 0.0,
    };

    // 1. Distribute items
    for (final item in bill.items) {
      // If no member is explicitly selected, default to all members sharing this item
      final targetMembers = item.assignedMemberIds.isEmpty
          ? allMemberIds
          : item.assignedMemberIds;

      final splitPerPerson = item.totalPrice / targetMembers.length;
      for (final uid in targetMembers) {
        if (itemSubtotals.containsKey(uid)) {
          itemSubtotals[uid] = (itemSubtotals[uid] ?? 0.0) + splitPerPerson;
        }
      }
    }

    final totalItemsSubtotal = itemSubtotals.values.fold(0.0, (a, b) => a + b);
    final totalAdditionalCharges = bill.taxAmount + bill.serviceCharge;
    final totalDiscount = bill.discountAmount;

    final memberTaxes = <String, double>{};
    final memberDiscounts = <String, double>{};
    final memberShares = <String, double>{};

    for (final uid in allMemberIds) {
      final subtotal = itemSubtotals[uid] ?? 0.0;
      final ratio = totalItemsSubtotal > 0 ? (subtotal / totalItemsSubtotal) : (1.0 / allMemberIds.length);

      final taxShare = totalAdditionalCharges * ratio;
      final discountShare = totalDiscount * ratio;
      final netShare = subtotal + taxShare - discountShare;

      memberTaxes[uid] = double.parse(taxShare.toStringAsFixed(2));
      memberDiscounts[uid] = double.parse(discountShare.toStringAsFixed(2));
      memberShares[uid] = double.parse(netShare.clamp(0.0, double.infinity).toStringAsFixed(2));
    }

    // 2. Exact Rebalance against bill.grandTotal
    final targetTotal = double.parse(bill.grandTotal.toStringAsFixed(2));
    double sumCalculated = memberShares.values.fold(0.0, (a, b) => a + b);
    sumCalculated = double.parse(sumCalculated.toStringAsFixed(2));

    final discrepancy = double.parse((targetTotal - sumCalculated).toStringAsFixed(2));
    if (discrepancy.abs() > 0.001 && allMemberIds.isNotEmpty) {
      // Find the member with the largest share to absorb the penny rounding difference
      String maxMember = allMemberIds.first;
      double maxShare = -1.0;
      for (final entry in memberShares.entries) {
        if (entry.value > maxShare) {
          maxShare = entry.value;
          maxMember = entry.key;
        }
      }

      final correctedShare = (memberShares[maxMember] ?? 0.0) + discrepancy;
      memberShares[maxMember] = double.parse(correctedShare.toStringAsFixed(2));
      sumCalculated = targetTotal;
    }

    return BillSplitResult(
      memberShares: memberShares,
      itemSubtotals: itemSubtotals,
      memberTaxes: memberTaxes,
      memberDiscounts: memberDiscounts,
      totalCalculated: sumCalculated,
      grandTotal: targetTotal,
      isBalanced: (sumCalculated - targetTotal).abs() < 0.01,
    );
  }
}
