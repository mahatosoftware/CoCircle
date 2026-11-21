import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/bill_scanner/domain/scanned_bill_model.dart';
import 'package:cocircle/features/bill_scanner/domain/bill_split_calculator.dart';

void main() {
  group('BillSplitCalculator Tests', () {
    test('Calculates item-level splitting with taxes and discounts accurately', () {
      final members = ['user_alice', 'user_bob', 'user_charlie'];

      // Bill:
      // Item 1: Kingfish ₹800 (Alice only)
      // Item 2: Butter Garlic Prawns ₹600 (Bob only)
      // Item 3: Veg Fried Rice ₹400 (Charlie only)
      // Item 4: Shared Starter ₹600 (Shared by Alice, Bob, Charlie => ₹200 each)
      // Subtotal = 800 + 600 + 400 + 600 = ₹2,400
      // Tax (GST) = ₹120 (5%)
      // Discount = ₹60 (2.5%)
      // Grand Total = 2400 + 120 - 60 = ₹2,460
      final bill = ScannedBill(
        merchantName: 'Goa Shack Test',
        items: [
          ScannedBillItem(
            name: 'Kingfish',
            unitPrice: 800,
            totalPrice: 800,
            assignedMemberIds: ['user_alice'],
          ),
          ScannedBillItem(
            name: 'Butter Garlic Prawns',
            unitPrice: 600,
            totalPrice: 600,
            assignedMemberIds: ['user_bob'],
          ),
          ScannedBillItem(
            name: 'Veg Fried Rice',
            unitPrice: 400,
            totalPrice: 400,
            assignedMemberIds: ['user_charlie'],
          ),
          ScannedBillItem(
            name: 'Shared Starter',
            unitPrice: 600,
            totalPrice: 600,
            assignedMemberIds: ['user_alice', 'user_bob', 'user_charlie'],
          ),
        ],
        subtotal: 2400,
        taxAmount: 120,
        serviceCharge: 0,
        discountAmount: 60,
        grandTotal: 2460,
      );

      final result = BillSplitCalculator.calculate(
        bill: bill,
        allMemberIds: members,
      );

      expect(result.isBalanced, isTrue);
      expect(result.totalCalculated, equals(2460.0));

      // Alice: 800 + 200 = 1000 item subtotal (1000 / 2400 = 41.67%)
      // Bob: 600 + 200 = 800 item subtotal (800 / 2400 = 33.33%)
      // Charlie: 400 + 200 = 600 item subtotal (600 / 2400 = 25.0%)
      expect(result.itemSubtotals['user_alice'], equals(1000.0));
      expect(result.itemSubtotals['user_bob'], equals(800.0));
      expect(result.itemSubtotals['user_charlie'], equals(600.0));

      final sumShares = result.memberShares.values.fold(0.0, (a, b) => a + b);
      expect(sumShares, equals(2460.0));

      // Alice should pay more than Bob, Bob more than Charlie
      expect(result.memberShares['user_alice']! > result.memberShares['user_bob']!, isTrue);
      expect(result.memberShares['user_bob']! > result.memberShares['user_charlie']!, isTrue);
    });

    test('Rebalances rounding gaps to match grand total down to the cent', () {
      final members = ['u1', 'u2', 'u3'];
      // Grand total = 100 / 3 = 33.3333333...
      final bill = ScannedBill(
        merchantName: 'Split 100 by 3',
        items: [
          ScannedBillItem(name: 'Buffet', unitPrice: 100, totalPrice: 100),
        ],
        grandTotal: 100.0,
      );

      final result = BillSplitCalculator.calculate(
        bill: bill,
        allMemberIds: members,
      );

      expect(result.isBalanced, isTrue);
      expect(result.totalCalculated, equals(100.0));
      final totalShares = result.memberShares.values.fold(0.0, (a, b) => a + b);
      expect(totalShares, equals(100.0));
    });
  });
}
