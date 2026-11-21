import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failure.dart';
import '../domain/trip_participant_model.dart';
import '../domain/trip_participant_repository.dart';
import '../../financial/payments/domain/guest_payment_model.dart';

final tripParticipantRepositoryProvider = Provider<TripParticipantRepository>((ref) {
  return TripParticipantRepositoryImpl(firestore: FirebaseFirestore.instance);
});

class TripParticipantRepositoryImpl implements TripParticipantRepository {
  final FirebaseFirestore _firestore;

  TripParticipantRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _participantsRef(String tripId) =>
      _firestore.collection('trips').doc(tripId).collection('participants');

  CollectionReference<Map<String, dynamic>> _paymentsRef(String tripId) =>
      _firestore.collection('trips').doc(tripId).collection('payments');

  CollectionReference<Map<String, dynamic>> _expensesRef(String tripId) =>
      _firestore.collection('trips').doc(tripId).collection('expenses');

  DocumentReference<Map<String, dynamic>> _tripDoc(String tripId) =>
      _firestore.collection('trips').doc(tripId);

  @override
  Stream<List<TripParticipantModel>> getTripParticipantsStream(String tripId) {
    return _participantsRef(tripId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => TripParticipantModel.fromJson(doc.data()))
            .toList();
      }

      // Fallback for legacy trips without explicit participant documents:
      // Synthesize participants from the circle members
      try {
        final tripDoc = await _tripDoc(tripId).get();
        if (!tripDoc.exists) return <TripParticipantModel>[];
        final circleId = tripDoc.data()?['circleId'] as String?;
        if (circleId == null) return <TripParticipantModel>[];

        final circleMembersSnap = await _firestore
            .collection('circles')
            .doc(circleId)
            .collection('members')
            .get();

        if (circleMembersSnap.docs.isNotEmpty) {
          final members = <TripParticipantModel>[];
          for (final doc in circleMembersSnap.docs) {
            final data = doc.data();
            final uid = data['uid'] as String? ?? doc.id;
            final name = data['displayName'] as String? ?? 'Member';
            final avatarUrl = data['photoUrl'] as String?;

            final participant = TripParticipantModel(
              id: uid,
              tripId: tripId,
              name: name,
              participantType: TripParticipantType.registered,
              userId: uid,
              avatarUrl: avatarUrl,
              addedBy: tripDoc.data()?['createdBy'] as String? ?? '',
              createdAt: DateTime.now(),
            );
            members.add(participant);
          }
          return members;
        }
      } catch (e) {
        // Fallback error, return empty
      }
      return <TripParticipantModel>[];
    });
  }

  @override
  Future<Either<Failure, List<TripParticipantModel>>> getTripParticipants(
      String tripId) async {
    try {
      final snap = await _participantsRef(tripId)
          .where('status', isEqualTo: 'active')
          .get();

      if (snap.docs.isNotEmpty) {
        final list = snap.docs
            .map((doc) => TripParticipantModel.fromJson(doc.data()))
            .toList();
        return right(list);
      }

      // Legacy fallback
      final tripDoc = await _tripDoc(tripId).get();
      if (!tripDoc.exists) return right(<TripParticipantModel>[]);
      final circleId = tripDoc.data()?['circleId'] as String?;
      if (circleId == null) return right(<TripParticipantModel>[]);

      final circleMembersSnap = await _firestore
          .collection('circles')
          .doc(circleId)
          .collection('members')
          .get();

      final members = <TripParticipantModel>[];
      for (final doc in circleMembersSnap.docs) {
        final data = doc.data();
        final uid = data['uid'] as String? ?? doc.id;
        final name = data['displayName'] as String? ?? 'Member';
        final avatarUrl = data['photoUrl'] as String?;

        members.add(
          TripParticipantModel(
            id: uid,
            tripId: tripId,
            name: name,
            participantType: TripParticipantType.registered,
            userId: uid,
            avatarUrl: avatarUrl,
            addedBy: tripDoc.data()?['createdBy'] as String? ?? '',
            createdAt: DateTime.now(),
          ),
        );
      }
      return right(members);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripParticipantModel>> getParticipantById(
      String tripId, String participantId) async {
    try {
      final doc = await _participantsRef(tripId).doc(participantId).get();
      if (doc.exists) {
        return right(TripParticipantModel.fromJson(doc.data()!));
      }
      return left(Failure('Participant not found'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripParticipantModel>> addParticipant(
      TripParticipantModel participant) async {
    try {
      final batch = _firestore.batch();
      final pRef = _participantsRef(participant.tripId).doc(participant.id);
      batch.set(pRef, participant.toJson());

      // Update participantIds array in Trip document
      final tRef = _tripDoc(participant.tripId);
      batch.update(tRef, {
        'participantIds': FieldValue.arrayUnion([participant.id]),
      });

      await batch.commit();
      return right(participant);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripParticipantModel>> addGuestParticipant({
    required String tripId,
    required String name,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? notes,
    required String addedBy,
  }) async {
    try {
      final guestId = 'guest_${const Uuid().v4().substring(0, 8)}';
      final guest = TripParticipantModel(
        id: guestId,
        tripId: tripId,
        name: name.trim(),
        participantType: TripParticipantType.guest,
        userId: null,
        phoneNumber: phoneNumber?.trim().isEmpty ?? true ? null : phoneNumber!.trim(),
        email: email?.trim().isEmpty ?? true ? null : email!.trim(),
        avatarUrl: avatarUrl,
        notes: notes?.trim().isEmpty ?? true ? null : notes!.trim(),
        addedBy: addedBy,
        createdAt: DateTime.now(),
        status: 'active',
      );

      return await addParticipant(guest);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripParticipantModel>> updateParticipant(
      TripParticipantModel participant) async {
    try {
      final updated = participant.copyWith(updatedAt: DateTime.now());
      await _participantsRef(participant.tripId)
          .doc(participant.id)
          .update(updated.toJson());
      return right(updated);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> canRemoveParticipant(
      String tripId, String participantId) async {
    try {
      // 1. Check if participant has recorded expenses as payer
      final asPayerSnap = await _expensesRef(tripId)
          .where('payerId', isEqualTo: participantId)
          .limit(1)
          .get();
      if (asPayerSnap.docs.isNotEmpty) {
        return left(Failure(
          'Cannot remove participant: they have logged expenses as a payer. Reassign or delete these expenses first.',
        ));
      }

      // 2. Check all expenses to see if they are in payers map or splitDetails
      final allExpensesSnap = await _expensesRef(tripId).get();
      for (final doc in allExpensesSnap.docs) {
        final data = doc.data();
        final payers = data['payers'] as Map<String, dynamic>? ?? {};
        if (payers.containsKey(participantId)) {
          return left(Failure(
            'Cannot remove participant: they are listed as a contributing payer in trip expenses.',
          ));
        }
        final splitDetails = data['splitDetails'] as Map<String, dynamic>? ?? {};
        if (splitDetails.containsKey(participantId)) {
          return left(Failure(
            'Cannot remove participant: they are included in expense splits for "${data['title'] ?? 'an expense'}". Remove them from the split first.',
          ));
        }
      }

      // 3. Check if they have recorded payments
      final paymentsFromSnap = await _paymentsRef(tripId)
          .where('fromMemberId', isEqualTo: participantId)
          .limit(1)
          .get();
      if (paymentsFromSnap.docs.isNotEmpty) {
        return left(Failure(
          'Cannot remove participant: active settlement payments are linked to them.',
        ));
      }

      final paymentsToSnap = await _paymentsRef(tripId)
          .where('toMemberId', isEqualTo: participantId)
          .limit(1)
          .get();
      if (paymentsToSnap.docs.isNotEmpty) {
        return left(Failure(
          'Cannot remove participant: active settlement payments are linked to them.',
        ));
      }

      return right(true);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant({
    required String tripId,
    required String participantId,
    required String removedBy,
  }) async {
    try {
      final canRemoveRes = await canRemoveParticipant(tripId, participantId);
      if (canRemoveRes.isLeft()) {
        final failure = canRemoveRes.getLeft().toNullable() ?? Failure('Cannot remove participant with active financial records');
        return left(failure);
      }

      final batch = _firestore.batch();
      // Soft-delete to preserve immutable logs
      final pRef = _participantsRef(tripId).doc(participantId);
      batch.update(pRef, {
        'status': 'removed',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Remove from trip's participantIds
      final tRef = _tripDoc(tripId);
      batch.update(tRef, {
        'participantIds': FieldValue.arrayRemove([participantId]),
      });

      await batch.commit();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripParticipantModel>> convertGuestToRegistered({
    required String tripId,
    required String participantId,
    required String registeredUserId,
    required String registeredDisplayName,
    required String convertedBy,
  }) async {
    try {
      final doc = await _participantsRef(tripId).doc(participantId).get();
      if (!doc.exists) {
        return left(Failure('Guest participant not found'));
      }
      final current = TripParticipantModel.fromJson(doc.data()!);
      if (!current.isGuest) {
        return left(Failure('Participant is already a registered member'));
      }

      // Check if registered user is already a member of this trip
      final existingUserCheck = await _participantsRef(tripId)
          .where('userId', isEqualTo: registeredUserId)
          .where('status', isEqualTo: 'active')
          .get();

      if (existingUserCheck.docs.isNotEmpty) {
        return left(Failure(
          'A trip participant linked to account "$registeredDisplayName" already exists in this trip.',
        ));
      }

      final converted = current.copyWith(
        name: registeredDisplayName.trim().isNotEmpty
            ? registeredDisplayName.trim()
            : current.name,
        participantType: TripParticipantType.registered,
        userId: registeredUserId,
        convertedAt: DateTime.now(),
        convertedBy: convertedBy,
        updatedAt: DateTime.now(),
      );

      // Preserve the exact same ID so all historical expense, split, and settlement records stay 100% intact!
      await _participantsRef(tripId).doc(participantId).update(converted.toJson());

      return right(converted);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GuestPaymentModel>> recordPayment(
      GuestPaymentModel payment) async {
    try {
      await _paymentsRef(payment.tripId).doc(payment.id).set(payment.toJson());
      return right(payment);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<GuestPaymentModel>> getTripPaymentsStream(String tripId) {
    return _paymentsRef(tripId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GuestPaymentModel.fromJson(doc.data()))
            .toList());
  }
}
