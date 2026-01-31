import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import '../domain/settlement_model.dart';
import '../domain/settlement_repository.dart';

part 'settlement_repository_impl.g.dart';

@Riverpod(keepAlive: true)
SettlementRepository settlementRepository(Ref ref) {
  return SettlementRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class SettlementRepositoryImpl implements SettlementRepository {
  final FirebaseFirestore _firestore;

  SettlementRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _settlements => _firestore.collection('settlements');

  @override
  Future<Either<Failure, SettlementModel>> createSettlement(SettlementModel settlement) async {
    try {
      print('SETTLEMENT_LOG: Writing settlement ${settlement.id} to Firestore...');
      await _settlements.doc(settlement.id).set(settlement.toJson());
      print('SETTLEMENT_LOG: Successfully wrote settlement ${settlement.id}');
      return right(settlement);
    } catch (e) {
      print('SETTLEMENT_WRITE_ERROR: Failed to write settlement: $e');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettlement(SettlementModel settlement) async {
    try {
      print('SETTLEMENT_LOG: Updating settlement ${settlement.id} in Firestore...');
      await _settlements.doc(settlement.id).update(settlement.toJson());
      print('SETTLEMENT_LOG: Successfully updated settlement ${settlement.id}');
      return right(null);
    } catch (e) {
      print('SETTLEMENT_UPDATE_ERROR: Failed to update settlement: $e');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SettlementModel>>> getSettlementsForTrip(String tripId) async {
    try {
      print('SETTLEMENT_LOG: Fetching all settlements for trip $tripId...');
      final query = await _settlements
          .where('tripId', isEqualTo: tripId)
          .orderBy('timestamp', descending: true)
          .get();
      
      final settlements = query.docs.map((d) {
        try {
          return SettlementModel.fromJson(d.data());
        } catch (e) {
          print('SETTLEMENT_PARSE_ERROR doc ${d.id}: $e');
          rethrow;
        }
      }).toList();
      print('SETTLEMENT_LOG: Fetched ${settlements.length} settlements');
      return right(settlements);
    } catch (e) {
      print('SETTLEMENT_FETCH_ERROR: $e');
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<SettlementModel>> getSettlementsStream(String tripId) {
    return _settlements
        .where('tripId', isEqualTo: tripId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs.map((d) {
              try {
                return SettlementModel.fromJson(d.data());
              } catch (e) {
                // This logs specifically which document failed to parse
                print('SETTLEMENT_PARSE_ERROR: Failed to parse doc ${d.id}: $e');
                rethrow;
              }
            }).toList();
          } catch (e) {
            print('SETTLEMENT_STREAM_ERROR: $e');
            rethrow;
          }
        });
  }
}
