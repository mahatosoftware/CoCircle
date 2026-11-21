import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import 'trip_participant_model.dart';
import '../../financial/payments/domain/guest_payment_model.dart';

abstract interface class TripParticipantRepository {
  Stream<List<TripParticipantModel>> getTripParticipantsStream(String tripId);
  Future<Either<Failure, List<TripParticipantModel>>> getTripParticipants(String tripId);
  Future<Either<Failure, TripParticipantModel>> getParticipantById(String tripId, String participantId);
  Future<Either<Failure, TripParticipantModel>> addParticipant(TripParticipantModel participant);
  Future<Either<Failure, TripParticipantModel>> addGuestParticipant({
    required String tripId,
    required String name,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    String? notes,
    required String addedBy,
  });
  Future<Either<Failure, TripParticipantModel>> updateParticipant(TripParticipantModel participant);
  Future<Either<Failure, bool>> canRemoveParticipant(String tripId, String participantId);
  Future<Either<Failure, void>> removeParticipant({
    required String tripId,
    required String participantId,
    required String removedBy,
  });
  Future<Either<Failure, TripParticipantModel>> convertGuestToRegistered({
    required String tripId,
    required String participantId,
    required String registeredUserId,
    required String registeredDisplayName,
    required String convertedBy,
  });
  Future<Either<Failure, GuestPaymentModel>> recordPayment(GuestPaymentModel payment);
  Stream<List<GuestPaymentModel>> getTripPaymentsStream(String tripId);
}
