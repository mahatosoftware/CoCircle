import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import 'circle_model.dart';

abstract interface class CircleRepository {
  Future<Either<Failure, CircleModel>> createCircle({
    required String name,
    required String description,
    required String currency,
    required String userId,
    String? imageUrl,
  });
  
  Future<Either<Failure, List<CircleModel>>> getUserCircles(String userId);
  Stream<List<CircleModel>> getUserCirclesStream(String userId);
  Future<Either<Failure, CircleModel>> getCircleById(String circleId);
  Future<Either<Failure, CircleModel>> getCircleByCode(String code);
  Future<Either<Failure, void>> requestJoin(String circleId, String userId);
  Future<Either<Failure, void>> approveMember(String circleId, String memberId);
  Future<Either<Failure, void>> rejectMember(String circleId, String memberId);
  Future<Either<Failure, void>> promoteToAdmin(String circleId, String memberId);
  Future<Either<Failure, void>> demoteFromAdmin(String circleId, String memberId);
  Future<Either<Failure, void>> removeMember(String circleId, String memberId);
  Future<Either<Failure, void>> updateCircle(CircleModel circle);
  Stream<CircleModel?> getCircleStream(String circleId);
}
