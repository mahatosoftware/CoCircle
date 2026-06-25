import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import 'itinerary_item_model.dart';
import 'lodging_model.dart';
import 'idea_model.dart';
import 'packing_item_model.dart';

abstract interface class TripPlannerRepository {
  // Itinerary
  Future<Either<Failure, ItineraryItemModel>> createItineraryItem(ItineraryItemModel item);
  Future<Either<Failure, void>> updateItineraryItem(ItineraryItemModel item);
  Future<Either<Failure, void>> deleteItineraryItem(String itemId);
  Stream<List<ItineraryItemModel>> getItineraryStream(String tripId);

  // Lodging
  Future<Either<Failure, LodgingModel>> createLodging(LodgingModel lodging);
  Future<Either<Failure, void>> updateLodging(LodgingModel lodging);
  Future<Either<Failure, void>> deleteLodging(String lodgingId);
  Stream<List<LodgingModel>> getLodgingStream(String tripId);

  // Idea Board
  Future<Either<Failure, IdeaModel>> createIdea(IdeaModel idea);
  Future<Either<Failure, void>> toggleVoteIdea(String ideaId, String userId);
  Future<Either<Failure, void>> deleteIdea(String ideaId);
  Future<Either<Failure, void>> promoteIdeaToItinerary(String ideaId, ItineraryItemModel itineraryItem);
  Stream<List<IdeaModel>> getIdeasStream(String tripId);

  // Packing
  Future<Either<Failure, PackingItemModel>> createPackingItem(PackingItemModel item);
  Future<Either<Failure, void>> togglePackingItem(String itemId, bool isPacked);
  Future<Either<Failure, void>> assignPackingItem(String itemId, String? userId);
  Future<Either<Failure, void>> deletePackingItem(String itemId);
  Stream<List<PackingItemModel>> getPackingStream(String tripId);
}
