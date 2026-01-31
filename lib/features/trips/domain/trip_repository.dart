import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../domain/trip_model.dart';
import '../domain/trip_summary_model.dart';

abstract interface class TripRepository {
  Future<Either<Failure, TripModel>> createTrip(TripModel trip);
  Future<Either<Failure, List<TripModel>>> getTripsForCircle(String circleId);
  Future<Either<Failure, TripModel>> getTripById(String tripId);
  Future<Either<Failure, void>> updateTrip(TripModel trip);
  // Future<Either<Failure, TripSummaryModel>> getTripSummary(String tripId); // For later
  Stream<List<TripModel>> getTripsStream(String circleId);
}
