import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../domain/poll_model.dart';

abstract interface class PollRepository {
  Future<Either<Failure, PollModel>> createPoll(PollModel poll);
  Future<Either<Failure, void>> vote(String pollId, String userId, int optionIndex);
  Future<Either<Failure, void>> closePoll(String pollId);
  Future<Either<Failure, void>> addOption(String pollId, String optionText);
  Future<Either<Failure, void>> updatePoll(PollModel poll);
  Future<Either<Failure, void>> deletePoll(String pollId);
  Stream<List<PollModel>> getPollsStream(String tripId);
}
