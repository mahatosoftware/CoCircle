import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/memory_model.dart';

final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  return MemoryRepository(firestore: FirebaseFirestore.instance);
});

final tripMemoriesProvider = StreamProvider.family<List<MemoryItem>, String>((ref, tripId) {
  return ref.watch(memoryRepositoryProvider).getMemoriesStream(tripId);
});

final tripScrapbookProvider = FutureProvider.family<TripScrapbook?, String>((ref, tripId) {
  return ref.watch(memoryRepositoryProvider).getScrapbook(tripId);
});

class MemoryRepository {
  final FirebaseFirestore _firestore;

  MemoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _memoriesRef(String tripId) {
    return _firestore.collection('trips').doc(tripId).collection('memories');
  }

  Stream<List<MemoryItem>> getMemoriesStream(String tripId) {
    return _memoriesRef(tripId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MemoryItem.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> addMemory(MemoryItem item) async {
    await _memoriesRef(item.tripId).doc(item.id).set(item.toJson());
  }

  Future<void> toggleLike(String tripId, String memoryId, String userId) async {
    final docRef = _memoriesRef(tripId).doc(memoryId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    final likes = List<String>.from(data?['likes'] ?? []);

    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await docRef.update({'likes': likes});
  }

  Future<void> deleteMemory(String tripId, String memoryId) async {
    await _memoriesRef(tripId).doc(memoryId).delete();
  }

  Future<void> saveScrapbook(TripScrapbook scrapbook) async {
    await _firestore
        .collection('trips')
        .doc(scrapbook.tripId)
        .collection('scrapbook')
        .doc('latest')
        .set(scrapbook.toJson());
  }

  Future<TripScrapbook?> getScrapbook(String tripId) async {
    final doc = await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('scrapbook')
        .doc('latest')
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return TripScrapbook.fromJson(doc.data()!);
  }
}
