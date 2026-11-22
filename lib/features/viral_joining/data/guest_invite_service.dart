import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/guest_invite_model.dart';

final guestInviteServiceProvider = Provider<GuestInviteService>((ref) {
  return GuestInviteService(firestore: FirebaseFirestore.instance);
});

final guestPreviewProvider =
    FutureProvider.family<GuestGroupPreview?, String>((ref, code) {
  return ref.watch(guestInviteServiceProvider).fetchGuestPreview(code);
});

class GuestInviteService {
  final FirebaseFirestore _firestore;

  GuestInviteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<GuestGroupPreview?> fetchGuestPreview(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return null;

    try {
      // 1. Look up circle by standard code
      var snapshot = await _firestore
          .collection('circles')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      // Fallback: Check one-time invite codes
      if (snapshot.docs.isEmpty) {
        snapshot = await _firestore
            .collection('circles')
            .where('oneTimeCodes', arrayContains: code)
            .limit(1)
            .get();
      }

      if (snapshot.docs.isEmpty) return null;

      final circleDoc = snapshot.docs.first;
      final circleData = circleDoc.data();
      final circleId = circleDoc.id;
      final circleName = circleData['name'] as String? ?? 'Group';
      final memberIds = List<String>.from(circleData['memberIds'] ?? []);
      final currency = circleData['currency'] as String? ?? 'INR';

      // Track invitation open
      _recordInviteOpen(code, circleId);

      // 2. Fetch active trip for this circle
      final tripsSnap = await _firestore
          .collection('trips')
          .where('circleId', isEqualTo: circleId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      String? tripId;
      String? tripName;
      String? location;
      String? datesString;
      double totalBudget = 0.0;
      final itineraryHighlights = <String>[];
      final openPolls = <GuestPollPreview>[];
      int pendingTasksCount = 0;

      if (tripsSnap.docs.isNotEmpty) {
        final tripDoc = tripsSnap.docs.first;
        final tripData = tripDoc.data();
        tripId = tripDoc.id;
        tripName = tripData['name'] as String?;
        location = tripData['location'] as String?;
        totalBudget = (tripData['targetBudget'] as num?)?.toDouble() ??
            (tripData['totalExpenses'] as num?)?.toDouble() ??
            0.0;

        final start = tripData['startDate'] is Timestamp
            ? (tripData['startDate'] as Timestamp).toDate()
            : null;
        final end = tripData['endDate'] is Timestamp
            ? (tripData['endDate'] as Timestamp).toDate()
            : null;

        if (start != null && end != null) {
          datesString =
              '${DateFormat.MMMd().format(start)} - ${DateFormat.MMMd().format(end)}';
        } else if (start != null) {
          datesString = 'Starting ${DateFormat.MMMd().format(start)}';
        }

        // 3. Itinerary highlights
        try {
          final itinSnap = await _firestore
              .collection('trips')
              .doc(tripId)
              .collection('itinerary')
              .orderBy('startTime')
              .limit(4)
              .get();
          for (final doc in itinSnap.docs) {
            final t = doc.data()['title'] as String?;
            if (t != null) itineraryHighlights.add(t);
          }
        } catch (_) {}

        // 4. Open polls
        try {
          final pollSnap = await _firestore
              .collection('trips')
              .doc(tripId)
              .collection('polls')
              .where('isActive', isEqualTo: true)
              .limit(3)
              .get();

          for (final doc in pollSnap.docs) {
            final d = doc.data();
            final options = (d['options'] as List?)
                    ?.map((e) => (e is Map ? e['text'] : e.toString()).toString())
                    .toList() ??
                [];
            final voteCounts = (d['options'] as List?)
                    ?.map((e) => e is Map ? ((e['voteCount'] as num?)?.toInt() ?? 0) : 0)
                    .toList() ??
                [];

            openPolls.add(
              GuestPollPreview(
                id: doc.id,
                question: d['question'] as String? ?? 'Poll',
                options: options,
                voteCounts: voteCounts,
                allowMultiple: d['allowMultipleSelections'] as bool? ?? false,
                isActive: true,
              ),
            );
          }
        } catch (_) {}

        // 5. Pending tasks count
        try {
          final taskSnap = await _firestore
              .collection('trips')
              .doc(tripId)
              .collection('tasks')
              .where('isCompleted', isEqualTo: false)
              .get();
          pendingTasksCount = taskSnap.docs.length;
        } catch (_) {}
      }

      return GuestGroupPreview(
        circleId: circleId,
        circleCode: code,
        circleName: circleName,
        tripId: tripId,
        tripName: tripName,
        location: location,
        datesString: datesString,
        memberCount: memberIds.length,
        itineraryHighlights: itineraryHighlights,
        openPolls: openPolls,
        totalBudget: totalBudget,
        pendingTasksCount: pendingTasksCount,
        currency: currency,
      );
    } catch (e) {
      debugPrint('[GuestInviteService] fetch preview error: $e');
      return null;
    }
  }

  Future<void> _recordInviteOpen(String code, String circleId) async {
    try {
      final docRef = _firestore.collection('referralAnalytics').doc(code);
      await docRef.set({
        'code': code,
        'circleId': circleId,
        'viewsCount': FieldValue.increment(1),
        'lastViewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static String generateViralInviteMessage({
    required String circleName,
    required String code,
    String? tripName,
    String? location,
    String? datesString,
  }) {
    final inviteLink = 'https://cocircle.mahato.in/join/$code';
    final detailsList = [
      if (tripName != null && tripName.isNotEmpty) '✈️ Trip: $tripName',
      if (location != null && location.isNotEmpty) '📍 Destination: $location',
      if (datesString != null && datesString.isNotEmpty) '🗓️ Dates: $datesString',
    ];

    final buffer = StringBuffer();
    buffer.writeln('🎉 You\'re invited to join "$circleName" on CoCircle!');
    if (detailsList.isNotEmpty) {
      buffer.writeln();
      for (final detail in detailsList) {
        buffer.writeln(detail);
      }
    }
    buffer.writeln();
    buffer.writeln('🌟 Preview our itinerary, vote on hotel & activity polls, and track expenses together:');
    buffer.writeln(inviteLink);
    buffer.writeln();
    buffer.write('(Or join in the CoCircle app using code: $code)');

    return buffer.toString();
  }
}
