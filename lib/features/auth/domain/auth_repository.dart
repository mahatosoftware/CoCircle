import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import 'user_model.dart';

abstract interface class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, UserModel>> signInWithEmailPassword({required String email, required String password});
  Future<Either<Failure, UserModel>> signUpWithEmailPassword({required String email, required String password, required String name});
  Future<Either<Failure, void>> signOut();
  Future<UserModel?> getCurrentUser();
  Future<List<UserModel>> getUsersByIds(List<String> userIds);
  Future<Either<Failure, void>> updateUserProfile({required String name, String? country, String? vpa, String? photoUrl});
  Future<Either<Failure, void>> resetPassword({required String email});
  Future<Either<Failure, void>> resendVerificationEmail({required String email, required String password});
}
