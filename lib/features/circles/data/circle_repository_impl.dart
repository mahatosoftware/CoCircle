import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import '../domain/circle_model.dart';
import '../domain/circle_repository.dart';

part 'circle_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CircleRepository circleRepository(Ref ref) {
  return CircleRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class CircleRepositoryImpl implements CircleRepository {
  final FirebaseFirestore _firestore;

  CircleRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _circles => _firestore.collection('circles');

  @override
  Future<Either<Failure, CircleModel>> createCircle({
    required String name,
    required String description,
    required String currency,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      final code = await _generateUniqueCode();
      final id = _circles.doc().id;
      final now = DateTime.now();

      final circle = CircleModel(
        id: id,
        name: name,
        description: description,
        code: code,
        currency: currency,
        imageUrl: imageUrl,
        memberIds: [userId],
        pendingMemberIds: [],
        adminIds: [userId],
        createdBy: userId,
        createdAt: now,
      );

      await _circles.doc(id).set(circle.toJson());
      
      return right(circle);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<String> _generateUniqueCode() async {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    String code;
    bool exists = true;

    do {
      code = String.fromCharCodes(Iterable.generate(
        7, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      
      final query = await _circles.where('code', isEqualTo: code).get();
      exists = query.docs.isNotEmpty;
    } while (exists);

    return code;
  }

  @override
  Future<Either<Failure, CircleModel>> getCircleById(String circleId) async {
    try {
      final doc = await _circles.doc(circleId).get();
      if (!doc.exists) return left(Failure('Circle not found'));
      return right(CircleModel.fromJson(doc.data()!));
    } catch (e) {
       return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CircleModel>> getCircleByCode(String code) async {
    try {
      // 1. Try regular code
      var query = await _circles.where('code', isEqualTo: code).limit(1).get();
      
      // 2. Try one-time code if not found
      if (query.docs.isEmpty) {
        query = await _circles.where('oneTimeCodes', arrayContains: code).limit(1).get();
      }

      if (query.docs.isEmpty) return left(Failure('Circle not found'));
      return right(CircleModel.fromJson(query.docs.first.data()));
    } catch (e) {
       return left(Failure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<CircleModel>>> getUserCircles(String userId) async {
    try {
      // Index required for this query: memberIds array-contains
      final query = await _circles.where('memberIds', arrayContains: userId).get();
      final circles = query.docs.map((d) => CircleModel.fromJson(d.data())).toList();
      return right(circles);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<CircleModel>> getUserCirclesStream(String userId) {
    return _circles.where('memberIds', arrayContains: userId).snapshots().map((snapshot) {
      return snapshot.docs.map((d) => CircleModel.fromJson(d.data())).toList();
    });
  }

  @override
  Future<Either<Failure, void>> requestJoin(String circleId, String userId) async {
     try {
       await _circles.doc(circleId).update({
         'pendingMemberIds': FieldValue.arrayUnion([userId])
       });
       return right(null);
     } catch (e) {
       return left(Failure(e.toString()));
     }
  }

  @override
  Future<Either<Failure, void>> joinWithOneTimeCode(String circleId, String userId, String code) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _circles.doc(circleId);
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) throw Exception('Circle not found');
        
        final data = doc.data()!;
        final oneTimeCodes = List<String>.from(data['oneTimeCodes'] ?? []);
        
        if (!oneTimeCodes.contains(code)) throw Exception('Invalid or used invite code');
        
        oneTimeCodes.remove(code);
        
        transaction.update(docRef, {
          'oneTimeCodes': oneTimeCodes,
          'memberIds': FieldValue.arrayUnion([userId]),
        });
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> generateOneTimeCode(String circleId) async {
    try {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rnd = Random();
      final code = 'IN-${String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))))}';

      await _circles.doc(circleId).update({
        'oneTimeCodes': FieldValue.arrayUnion([code])
      });
      
      return right(code);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOneTimeCode(String circleId, String code) async {
    try {
      await _circles.doc(circleId).update({
        'oneTimeCodes': FieldValue.arrayRemove([code])
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> approveMember(String circleId, String memberId) async {
    try {
      final batch = _firestore.batch();
      final docRef = _circles.doc(circleId);
      
      batch.update(docRef, {
        'pendingMemberIds': FieldValue.arrayRemove([memberId]),
        'memberIds': FieldValue.arrayUnion([memberId])
      });
      
      await batch.commit();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectMember(String circleId, String memberId) async {
    try {
      await _circles.doc(circleId).update({
        'pendingMemberIds': FieldValue.arrayRemove([memberId])
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> promoteToAdmin(String circleId, String memberId) async {
    try {
      await _circles.doc(circleId).update({
        'adminIds': FieldValue.arrayUnion([memberId])
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> demoteFromAdmin(String circleId, String memberId) async {
    try {
      await _circles.doc(circleId).update({
        'adminIds': FieldValue.arrayRemove([memberId])
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember(String circleId, String memberId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _circles.doc(circleId);
        final doc = await transaction.get(docRef);
        
        if (!doc.exists) throw Exception('Circle not found');
        
        final data = doc.data()!;
        final memberIds = List<String>.from(data['memberIds'] ?? []);
        final adminIds = List<String>.from(data['adminIds'] ?? []);
        
        memberIds.remove(memberId);
        adminIds.remove(memberId);
        
        final isPendingDelete = memberIds.isEmpty;
        
        transaction.update(docRef, {
          'memberIds': memberIds,
          'adminIds': adminIds,
          'isPendingDelete': isPendingDelete,
        });
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateCircle(CircleModel circle) async {
    try {
      await _circles.doc(circle.id).update(circle.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<CircleModel?> getCircleStream(String circleId) {
    return _circles.doc(circleId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CircleModel.fromJson(doc.data()!);
    });
  }
}
