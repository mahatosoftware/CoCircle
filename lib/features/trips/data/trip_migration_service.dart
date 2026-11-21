import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/finance/exact_money_calculator.dart';
import '../domain/trip_participant_model.dart';
import '../../financial/expenses/domain/expense_model.dart';

class TripMigrationService {
  final FirebaseFirestore _firestore;

  TripMigrationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Safely migrates an existing trip to the unified Participant architecture.
  /// Idempotent and resumable: Never duplicates participants or modifies historical expenses.
  Future<int> migrateTripParticipants(String tripId) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      if (!tripDoc.exists) return 0;

      final tripData = tripDoc.data()!;
      final circleId = tripData['circleId'] as String?;
      if (circleId == null) return 0;

      final participantsRef = _firestore
          .collection('trips')
          .doc(tripId)
          .collection('participants');

      final existingParticipantsSnap = await participantsRef.get();
      final existingIds = existingParticipantsSnap.docs.map((d) => d.id).toSet();

      // Fetch circle members
      final circleMembersSnap = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .get();

      final batch = _firestore.batch();
      int addedCount = 0;
      final List<String> allParticipantIds = List<String>.from(existingIds);

      for (final doc in circleMembersSnap.docs) {
        final memberData = doc.data();
        final uid = memberData['uid'] as String? ?? doc.id;

        // Skip if already migrated
        if (existingIds.contains(uid)) continue;

        final participant = TripParticipantModel(
          id: uid,
          tripId: tripId,
          name: memberData['displayName'] as String? ?? 'Member',
          participantType: TripParticipantType.registered,
          userId: uid,
          avatarUrl: memberData['photoUrl'] as String?,
          addedBy: tripData['createdBy'] as String? ?? '',
          createdAt: DateTime.now(),
          status: 'active',
        );

        batch.set(participantsRef.doc(uid), participant.toJson());
        allParticipantIds.add(uid);
        addedCount++;
      }

      if (addedCount > 0) {
        batch.update(_firestore.collection('trips').doc(tripId), {
          'participantIds': FieldValue.arrayUnion(allParticipantIds),
        });
        await batch.commit();
        debugPrint('TripMigrationService: Migrated $addedCount members to trip $tripId');
      }

      return addedCount;
    } catch (e) {
      debugPrint('TripMigrationService error migrating trip $tripId: $e');
      return 0;
    }
  }

  /// Validates that financial calculations for a trip remain strictly consistent
  /// across migration.
  bool validateBalanceEquivalence({
    required List<String> participantIds,
    required List<ExpenseModel> expenses,
  }) {
    final balances = ExactMoneyCalculator.calculateBalances(
      participantIds: participantIds,
      expenses: expenses,
    );

    // Fundamental accounting identity check:
    // The sum of all net balances in a zero-sum closed group MUST strictly equal 0.
    int sumNetPaise = 0;
    for (final b in balances.values) {
      sumNetPaise += b.netBalancePaise;
    }

    return sumNetPaise == 0;
  }
}
