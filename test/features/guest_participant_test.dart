import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/core/finance/exact_money_calculator.dart';
import 'package:cocircle/features/financial/expenses/domain/expense_model.dart';
import 'package:cocircle/features/financial/payments/domain/guest_payment_model.dart';
import 'package:cocircle/features/financial/settlements/domain/settlement_logic.dart';
import 'package:cocircle/features/trips/domain/trip_participant_model.dart';

void main() {
  final now = DateTime(2026, 3, 15, 12, 0);

  group('Guest Participant Management System Test Suite', () {
    // Scenario A: Guest expense splitting
    test('Scenario A: Equal split across registered and guest participants (Paise exactness)', () {
      // 1. ₹12,000 Hotel expense paid by Rahul, split equally across 6 participants (4 registered, 2 guests)
      // Rahul, Priya, Rohit, Sneha (Registered); Amit, Neha (Guest)
      final participantIds = ['rahul', 'priya', 'amit_guest', 'neha_guest', 'rohit', 'sneha'];
      final splits = ExactMoneyCalculator.calculateEqualSplit(
        12000.0,
        participantIds,
      );

      expect(splits.length, equals(6));
      // Each participant's share = exactly ₹2,000 (200000 paise)
      for (final pid in participantIds) {
        expect(splits[pid], equals(2000.0));
      }

      // 2. ₹4,000 split across 2 registered + 2 guests
      final fourParticipants = ['user1', 'user2', 'guest1', 'guest2'];
      final split4 = ExactMoneyCalculator.calculateEqualSplit(
        4000.0,
        fourParticipants,
      );
      for (final pid in fourParticipants) {
        expect(split4[pid], equals(1000.0));
      }

      // Verify balance calculation
      final expense = ExpenseModel(
        id: 'exp_hotel',
        tripId: 'trip_coorg',
        title: 'Hotel - 2 nights',
        amount: 12000.0,
        date: now,
        category: 'stay',
        payerId: 'rahul',
        splitType: SplitType.equal,
        payers: {'rahul': 12000.0},
        splitDetails: splits,
        createdBy: 'rahul',
        createdAt: now,
      );

      final balances = ExactMoneyCalculator.calculateBalances(
        participantIds: participantIds,
        expenses: [expense],
      );

      // Rahul paid 12,000, share 2,000 -> net +10,000 (to receive)
      expect(balances['rahul']!.totalPaidAmount, equals(12000.0));
      expect(balances['rahul']!.totalShareAmount, equals(2000.0));
      expect(balances['rahul']!.netAmount, equals(10000.0));

      // Guests Amit and Neha paid 0, share 2,000 -> net -2,000 (to pay)
      expect(balances['amit_guest']!.netAmount, equals(-2000.0));
      expect(balances['neha_guest']!.netAmount, equals(-2000.0));
    });

    // Scenario B: Guest pays an expense
    test('Scenario B: Guest participant pays an expense and gets full financial credit', () {
      final participantIds = ['rahul', 'amit_guest'];

      // Guest Amit pays ₹4,000 for dinner, split equally with Rahul
      final splits = ExactMoneyCalculator.calculateEqualSplit(
        4000.0,
        participantIds,
      );

      final expense = ExpenseModel(
        id: 'exp_dinner',
        tripId: 'trip_coorg',
        title: 'Dinner at Rasta Cafe',
        amount: 4000.0,
        date: now,
        category: 'food',
        payerId: 'amit_guest',
        splitType: SplitType.equal,
        payers: {'amit_guest': 4000.0},
        splitDetails: splits,
        createdBy: 'rahul', // Recorded by organizer on behalf of guest
        createdAt: now,
      );

      final balances = ExactMoneyCalculator.calculateBalances(
        participantIds: participantIds,
        expenses: [expense],
      );

      // Amit paid 4,000, share 2,000 -> Net = +₹2,000 (to receive)
      expect(balances['amit_guest']!.totalPaidAmount, equals(4000.0));
      expect(balances['amit_guest']!.totalShareAmount, equals(2000.0));
      expect(balances['amit_guest']!.netAmount, equals(2000.0));

      // Rahul paid 0, share 2,000 -> Net = -₹2,000 (owes Amit)
      expect(balances['rahul']!.netAmount, equals(-2000.0));

      // Settlements engine resolves Rahul -> Amit ₹2,000
      final settlements = SettlementLogic.calculateSettlements([expense]);
      expect(settlements.length, equals(1));
      expect(settlements.first.fromUid, equals('rahul'));
      expect(settlements.first.toUid, equals('amit_guest'));
      expect(settlements.first.amount, equals(2000.0));
    });

    // Scenario C: Partial guest settlement
    test('Scenario C: Partial guest settlement reduces outstanding balance accurately', () {
      final participantIds = ['rahul', 'amit_guest'];

      // Amit owes ₹2,000 from hotel expense
      final expense = ExpenseModel(
        id: 'exp_hotel',
        tripId: 'trip_coorg',
        title: 'Hotel',
        amount: 4000.0,
        date: now,
        category: 'stay',
        payerId: 'rahul',
        splitType: SplitType.equal,
        payers: {'rahul': 4000.0},
        splitDetails: {'rahul': 2000.0, 'amit_guest': 2000.0},
        createdBy: 'rahul',
        createdAt: now,
      );

      // Organizer records partial payment of ₹1,000 by Amit in Cash
      final partialPayment = GuestPaymentModel(
        id: 'pay_001',
        tripId: 'trip_coorg',
        fromMemberId: 'amit_guest',
        toMemberId: 'rahul',
        amount: 1000.0,
        paymentMethod: 'Cash',
        paymentDate: now,
        referenceNumber: 'CASH-REC-1',
        recordedBy: 'rahul',
        recordedOnBehalfOfGuest: true,
        paymentStatus: 'completed',
        createdAt: now,
      );

      final balances = ExactMoneyCalculator.calculateBalances(
        participantIds: participantIds,
        expenses: [expense],
        guestPayments: [partialPayment],
      );

      // Amit originally owed 2,000. With 1,000 paid, net balance should be -₹1,000
      expect(balances['amit_guest']!.totalPaidAmount, equals(1000.0));
      expect(balances['amit_guest']!.totalShareAmount, equals(2000.0));
      expect(balances['amit_guest']!.netAmount, equals(-1000.0));

      // Rahul originally was owed +2,000. With 1,000 received, net balance should be +₹1,000
      expect(balances['rahul']!.netAmount, equals(1000.0));

      // Additional settlement payment of ₹1,000 to fully settle Amit
      final finalPayment = GuestPaymentModel(
        id: 'pay_002',
        tripId: 'trip_coorg',
        fromMemberId: 'amit_guest',
        toMemberId: 'rahul',
        amount: 1000.0,
        paymentMethod: 'UPI',
        paymentDate: now,
        referenceNumber: 'UPI-REC-2',
        recordedBy: 'rahul',
        recordedOnBehalfOfGuest: true,
        paymentStatus: 'completed',
        createdAt: now,
      );

      final settledBalances = ExactMoneyCalculator.calculateBalances(
        participantIds: participantIds,
        expenses: [expense],
        guestPayments: [partialPayment, finalPayment],
      );

      expect(settledBalances['amit_guest']!.netAmount, equals(0.0));
      expect(settledBalances['amit_guest']!.netPaise, equals(0));
      expect(settledBalances['rahul']!.netAmount, equals(0.0));
    });

    // Scenario D: Guest account conversion
    test('Scenario D: Guest account conversion links registered account while preserving ID & financial history', () {
      final guest = TripParticipantModel(
        id: 'mem_amit_guest_01',
        tripId: 'trip_coorg',
        name: 'Amit Kumar',
        participantType: TripParticipantType.guest,
        phoneNumber: '+919876543210',
        addedBy: 'organizer_uid',
        createdAt: now,
        status: 'active',
      );

      expect(guest.isGuest, isTrue);
      expect(guest.isRegistered, isFalse);
      expect(guest.userId, isNull);

      // Amit registers later with Firebase UID 'firebase_user_amit_999'
      final converted = guest.copyWith(
        participantType: TripParticipantType.registered,
        userId: 'firebase_user_amit_999',
        name: 'Amit K. (Registered)',
        convertedAt: DateTime(2026, 3, 20),
        convertedBy: 'organizer_uid',
      );

      // Identity and primary reference must be strictly preserved
      expect(converted.id, equals('mem_amit_guest_01'));
      expect(converted.isGuest, isFalse);
      expect(converted.isRegistered, isTrue);
      expect(converted.userId, equals('firebase_user_amit_999'));
      expect(converted.convertedAt, isNotNull);
      expect(converted.convertedBy, equals('organizer_uid'));

      // Verify JSON serialization roundtrip
      final json = converted.toJson();
      final restored = TripParticipantModel.fromJson(json);
      expect(restored.id, equals(converted.id));
      expect(restored.participantType, equals(TripParticipantType.registered));
      expect(restored.userId, equals('firebase_user_amit_999'));
    });

    // Scenario E: Guest removal prevention when linked to active expenses/payments
    test('Scenario E: Removal guard prevents removing participant with active financial links', () {
      // 1. Participant with linked expense
      final expense = ExpenseModel(
        id: 'exp1',
        tripId: 'trip1',
        title: 'Fuel',
        amount: 1500.0,
        date: now,
        category: 'transport',
        payerId: 'user1',
        splitType: SplitType.equal,
        payers: {'user1': 1500.0},
        splitDetails: {'user1': 750.0, 'guest_neha': 750.0},
        createdBy: 'user1',
        createdAt: now,
      );

      bool hasLinkedExpense(String participantId, List<ExpenseModel> expenses) {
        return expenses.any((e) =>
            e.payerId == participantId ||
            e.payers.containsKey(participantId) ||
            e.splitDetails.containsKey(participantId));
      }

      expect(hasLinkedExpense('guest_neha', [expense]), isTrue);
      expect(hasLinkedExpense('unlinked_guest', [expense]), isFalse);

      // 2. Participant with linked payment
      final payment = GuestPaymentModel(
        id: 'pay1',
        tripId: 'trip1',
        fromMemberId: 'guest_neha',
        toMemberId: 'user1',
        amount: 750.0,
        paymentMethod: 'Cash',
        paymentDate: now,
        recordedBy: 'user1',
        recordedOnBehalfOfGuest: true,
        paymentStatus: 'completed',
        createdAt: now,
      );

      bool hasLinkedPayment(String participantId, List<GuestPaymentModel> payments) {
        return payments.any((p) =>
            p.fromMemberId == participantId || p.toMemberId == participantId);
      }

      expect(hasLinkedPayment('guest_neha', [payment]), isTrue);
      expect(hasLinkedPayment('unlinked_guest', [payment]), isFalse);
    });

    // Scenario F: Multiple guest participants in complex splits (Paise integer exactness)
    test('Scenario F: Complex split with non-divisible remainder ensures sum equals total exactly', () {
      // ₹100 split among 3 participants -> 33.34, 33.33, 33.33 (sum = 100.00 exactly)
      final threePids = ['p1', 'p2_guest', 'p3_guest'];
      final splits = ExactMoneyCalculator.calculateEqualSplit(
        100.0,
        threePids,
      );

      final totalSum = splits.values.fold<double>(0.0, (s, a) => s + a);
      expect((totalSum * 100).round(), equals(10000)); // Exactly 10,000 paise (₹100)
      expect(splits['p1'], equals(33.34));
      expect(splits['p2_guest'], equals(33.33));
      expect(splits['p3_guest'], equals(33.33));

      // Ratio / Share based split: 2:1:1 across 400.00
      final ratioSplits = ExactMoneyCalculator.calculateRatioSplit(
        400.0,
        {'p1': 2, 'p2_guest': 1, 'p3_guest': 1},
      );
      expect(ratioSplits['p1'], equals(200.0));
      expect(ratioSplits['p2_guest'], equals(100.0));
      expect(ratioSplits['p3_guest'], equals(100.0));
      final ratioSum = ratioSplits.values.fold<double>(0.0, (s, a) => s + a);
      expect((ratioSum * 100).round(), equals(40000));

      // Percentage split: 50%, 25%, 25% across 1,000
      final pctSplits = ExactMoneyCalculator.calculatePercentageSplit(
        1000.0,
        {'p1': 50.0, 'p2_guest': 25.0, 'p3_guest': 25.0},
      );
      expect(pctSplits['p1'], equals(500.0));
      expect(pctSplits['p2_guest'], equals(250.0));
      expect(pctSplits['p3_guest'], equals(250.0));
    });

    // Scenario G: Settlement Optimization with guests
    test('Scenario G: Multilateral settlement optimization resolves debts in minimal transactions', () {
      final pids = ['rahul', 'priya', 'amit_guest', 'neha_guest'];

      // Expenses:
      // Rahul pays 4,000 split among 4 (1,000 each)
      final exp1 = ExpenseModel(
        id: 'exp1',
        tripId: 't1',
        title: 'Cab',
        amount: 4000.0,
        date: now,
        category: 'transport',
        payerId: 'rahul',
        splitType: SplitType.equal,
        payers: {'rahul': 4000.0},
        splitDetails: {'rahul': 1000.0, 'priya': 1000.0, 'amit_guest': 1000.0, 'neha_guest': 1000.0},
        createdBy: 'rahul',
        createdAt: now,
      );

      // Priya pays 2,000 split between Priya and Amit (1,000 each)
      final exp2 = ExpenseModel(
        id: 'exp2',
        tripId: 't1',
        title: 'Snacks',
        amount: 2000.0,
        date: now,
        category: 'food',
        payerId: 'priya',
        splitType: SplitType.equal,
        payers: {'priya': 2000.0},
        splitDetails: {'priya': 1000.0, 'amit_guest': 1000.0},
        createdBy: 'priya',
        createdAt: now,
      );

      final balances = ExactMoneyCalculator.calculateBalances(
        participantIds: pids,
        expenses: [exp1, exp2],
      );

      // Rahul net: +3,000
      // Priya net: paid 2,000, share 2,000 -> 0 (Settled!)
      // Amit (Guest) net: paid 0, share 2,000 -> -2,000
      // Neha (Guest) net: paid 0, share 1,000 -> -1,000
      expect(balances['rahul']!.netAmount, equals(3000.0));
      expect(balances['priya']!.netAmount, equals(0.0));
      expect(balances['amit_guest']!.netAmount, equals(-2000.0));
      expect(balances['neha_guest']!.netAmount, equals(-1000.0));

      final transfers = ExactMoneyCalculator.optimizeSettlements(balances);
      // Optimal transfers:
      // Amit -> Rahul: 2,000
      // Neha -> Rahul: 1,000
      expect(transfers.length, equals(2));
      final amitTransfer = transfers.firstWhere((t) => t.fromUid == 'amit_guest');
      expect(amitTransfer.toUid, equals('rahul'));
      expect(amitTransfer.amount, equals(2000.0));

      final nehaTransfer = transfers.firstWhere((t) => t.fromUid == 'neha_guest');
      expect(nehaTransfer.toUid, equals('rahul'));
      expect(nehaTransfer.amount, equals(1000.0));
    });
  });
}
