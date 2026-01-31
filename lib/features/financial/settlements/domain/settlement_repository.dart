import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../domain/settlement_model.dart';

abstract class SettlementRepository {
  Future<Either<Failure, SettlementModel>> createSettlement(SettlementModel settlement);
  Future<Either<Failure, void>> updateSettlement(SettlementModel settlement);
  Future<Either<Failure, List<SettlementModel>>> getSettlementsForTrip(String tripId); // Ordered by version
  Stream<List<SettlementModel>> getSettlementsStream(String tripId);
}
