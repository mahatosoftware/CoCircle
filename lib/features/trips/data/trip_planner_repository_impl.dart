import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/failure.dart';
import '../domain/itinerary_item_model.dart';
import '../domain/lodging_model.dart';
import '../domain/idea_model.dart';
import '../domain/packing_item_model.dart';
import '../domain/trip_planner_repository.dart';

part 'trip_planner_repository_impl.g.dart';

@Riverpod(keepAlive: true)
TripPlannerRepository tripPlannerRepository(Ref ref) {
  return TripPlannerRepositoryImpl(FirebaseFirestore.instance);
}

class TripPlannerRepositoryImpl implements TripPlannerRepository {
  final FirebaseFirestore _firestore;

  TripPlannerRepositoryImpl(this._firestore);

  // Itinerary
  @override
  Future<Either<Failure, ItineraryItemModel>> createItineraryItem(ItineraryItemModel item) async {
    try {
      await _firestore.collection('itineraries').doc(item.id).set(item.toJson());
      return right(item);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItineraryItem(ItineraryItemModel item) async {
    try {
      await _firestore.collection('itineraries').doc(item.id).update(item.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItineraryItem(String itemId) async {
    try {
      await _firestore.collection('itineraries').doc(itemId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<ItineraryItemModel>> getItineraryStream(String tripId) {
    return _firestore
        .collection('itineraries')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((d) => ItineraryItemModel.fromJson(d.data())).toList();
          items.sort((a, b) => a.startTime.compareTo(b.startTime));
          return items;
        });
  }

  // Lodging
  @override
  Future<Either<Failure, LodgingModel>> createLodging(LodgingModel lodging) async {
    try {
      await _firestore.collection('lodgings').doc(lodging.id).set(lodging.toJson());
      return right(lodging);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLodging(LodgingModel lodging) async {
    try {
      await _firestore.collection('lodgings').doc(lodging.id).update(lodging.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLodging(String lodgingId) async {
    try {
      await _firestore.collection('lodgings').doc(lodgingId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<LodgingModel>> getLodgingStream(String tripId) {
    return _firestore
        .collection('lodgings')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((d) => LodgingModel.fromJson(d.data())).toList();
          items.sort((a, b) => a.checkIn.compareTo(b.checkIn));
          return items;
        });
  }

  // Idea Board
  @override
  Future<Either<Failure, IdeaModel>> createIdea(IdeaModel idea) async {
    try {
      await _firestore.collection('ideas').doc(idea.id).set(idea.toJson());
      return right(idea);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleVoteIdea(String ideaId, String userId) async {
    try {
      final docRef = _firestore.collection('ideas').doc(ideaId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) throw Exception("Idea does not exist");
        final idea = IdeaModel.fromJson(snapshot.data()!);
        List<String> updatedVotes = List.from(idea.votes);
        if (updatedVotes.contains(userId)) {
          updatedVotes.remove(userId);
        } else {
          updatedVotes.add(userId);
        }
        transaction.update(docRef, {'votes': updatedVotes});
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteIdea(String ideaId) async {
    try {
      await _firestore.collection('ideas').doc(ideaId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> promoteIdeaToItinerary(String ideaId, ItineraryItemModel itineraryItem) async {
    try {
      final batch = _firestore.batch();
      final ideaRef = _firestore.collection('ideas').doc(ideaId);
      final itineraryRef = _firestore.collection('itineraries').doc(itineraryItem.id);

      batch.update(ideaRef, {'isConverted': true});
      batch.set(itineraryRef, itineraryItem.toJson());

      await batch.commit();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<IdeaModel>> getIdeasStream(String tripId) {
    return _firestore
        .collection('ideas')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((d) => IdeaModel.fromJson(d.data())).toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  // Packing
  @override
  Future<Either<Failure, PackingItemModel>> createPackingItem(PackingItemModel item) async {
    try {
      await _firestore.collection('packing_items').doc(item.id).set(item.toJson());
      return right(item);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> togglePackingItem(String itemId, bool isPacked) async {
    try {
      await _firestore.collection('packing_items').doc(itemId).update({'isPacked': isPacked});
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignPackingItem(String itemId, String? userId) async {
    try {
      await _firestore.collection('packing_items').doc(itemId).update({'assignedTo': userId});
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePackingItem(String itemId) async {
    try {
      await _firestore.collection('packing_items').doc(itemId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<PackingItemModel>> getPackingStream(String tripId) {
    return _firestore
        .collection('packing_items')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((d) => PackingItemModel.fromJson(d.data())).toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }
}
