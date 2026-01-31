import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import '../domain/trip_model.dart';
import '../domain/trip_repository.dart';

part 'trip_repository_impl.g.dart';

@Riverpod(keepAlive: true)
TripRepository tripRepository(Ref ref) {
  return TripRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class TripRepositoryImpl implements TripRepository {
  final FirebaseFirestore _firestore;

  TripRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _trips => _firestore.collection('trips');

  @override
  Future<Either<Failure, TripModel>> createTrip(TripModel trip) async {
    try {
      await _trips.doc(trip.id).set(trip.toJson());
      return right(trip);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TripModel>>> getTripsForCircle(String circleId) async {
    try {
      final query = await _trips
          .where('circleId', isEqualTo: circleId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final trips = query.docs.map((d) => TripModel.fromJson(d.data())).toList();
      return right(trips);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TripModel>> getTripById(String tripId) async {
    try {
      final doc = await _trips.doc(tripId).get();
      if (!doc.exists) return left(Failure('Trip not found'));
      return right(TripModel.fromJson(doc.data()!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTrip(TripModel trip) async {
    try {
      await _trips.doc(trip.id).update(trip.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<TripModel>> getTripsStream(String circleId) {
    return _trips
        .where('circleId', isEqualTo: circleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((d) => TripModel.fromJson(d.data())).toList();
        });
  }
}
