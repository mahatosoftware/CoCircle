import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/errors/failure.dart';
import '../domain/poll_model.dart';
import '../domain/poll_repository.dart';

part 'poll_repository_impl.g.dart';

class PollRepositoryImpl implements PollRepository {
  final FirebaseFirestore _firestore;

  PollRepositoryImpl(this._firestore);

  @override
  Future<Either<Failure, PollModel>> createPoll(PollModel poll) async {
    try {
      await _firestore
          .collection('polls')
          .doc(poll.id)
          .set(poll.toJson());
      return right(poll);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> vote(String pollId, String userId, int optionIndex) async {
    try {
      final pollDoc = _firestore.collection('polls').doc(pollId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(pollDoc);
        if (!snapshot.exists) throw Exception("Poll not found");
        
        final poll = PollModel.fromJson(snapshot.data()!);
        if (!poll.isActive) throw Exception("Poll is closed");

        final rawVotes = snapshot.data()?['votes'] as Map<String, dynamic>? ?? {};
        final updatedVotes = <String, List<int>>{};
        
        rawVotes.forEach((key, value) {
          if (value is List) {
            updatedVotes[key] = List<int>.from(value);
          } else if (value is int) {
            updatedVotes[key] = [value];
          }
        });

        final userVotes = List<int>.from(updatedVotes[userId] ?? []);

        if (poll.allowMultipleSelections) {
          if (userVotes.contains(optionIndex)) {
            userVotes.remove(optionIndex);
          } else {
            userVotes.add(optionIndex);
          }
        } else {
          if (userVotes.contains(optionIndex)) {
            userVotes.clear();
          } else {
            userVotes.clear();
            userVotes.add(optionIndex);
          }
        }

        if (userVotes.isEmpty) {
          updatedVotes.remove(userId);
        } else {
          updatedVotes[userId] = userVotes;
        }

        // Recalculate option counts
        final updatedOptions = poll.options.map((opt) => opt.copyWith(voteCount: 0)).toList();
        for (final indices in updatedVotes.values) {
          for (final index in indices) {
            if (index >= 0 && index < updatedOptions.length) {
              updatedOptions[index] = updatedOptions[index].copyWith(
                voteCount: updatedOptions[index].voteCount + 1,
              );
            }
          }
        }

        transaction.update(pollDoc, {
          'votes': updatedVotes,
          'options': updatedOptions.map((e) => e.toJson()).toList(),
        });
      });
      
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> closePoll(String pollId) async {
    try {
      await _firestore.collection('polls').doc(pollId).update({
        'isActive': false,
        'closedAt': FieldValue.serverTimestamp(),
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addOption(String pollId, String optionText) async {
    try {
      final option = PollOption(text: optionText);
      await _firestore.collection('polls').doc(pollId).update({
        'options': FieldValue.arrayUnion([option.toJson()]),
      });
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePoll(PollModel poll) async {
    try {
      await _firestore.collection('polls').doc(poll.id).update(poll.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePoll(String pollId) async {
    try {
      await _firestore.collection('polls').doc(pollId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<PollModel>> getPollsStream(String tripId) {
    return _firestore
        .collection('polls')
        .where('tripId', isEqualTo: tripId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PollModel.fromJson(doc.data()))
            .toList());
  }
}

@riverpod
PollRepository pollRepository(Ref ref) {
  return PollRepositoryImpl(FirebaseFirestore.instance);
}
