import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/errors/failure.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(
      serverClientId: AppEnvironment.googleServerClientId,
    ),
    firestore: FirebaseFirestore.instance,
  );
}

@Riverpod(keepAlive: true)
Stream<UserModel?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestore = firestore;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        
        // Fetch user data from firestore to ensure we have the latest custom fields
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
            return UserModel.fromJson(doc.data()!);
        }
        
        // If not in firestore yet (rare race condition or first login pending), return basic model
        return UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName ?? '',
            photoUrl: firebaseUser.photoURL,
            createdAt: DateTime.now(), // Placeholder
        );
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
     final firebaseUser = _auth.currentUser;
     if (firebaseUser == null) return null;
     
     final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
     if (doc.exists) {
       return UserModel.fromJson(doc.data()!);
     }
     return null;
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailPassword({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return left(Failure('Email not verified. Please check your inbox.'));
      }

      // We assume user already exists in Firestore from SignUp
      final user = await getCurrentUser(); 
      if (user == null) return left(Failure('User data not found'));
      return right(user);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? 'Sign in failed'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailPassword({required String email, required String password, required String name}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user!;
      
      await firebaseUser.sendEmailVerification();
      
      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toJson());
      
      // Enforce verification before allowing login
      await _auth.signOut();

      return right(newUser);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? 'Sign up failed'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(Failure('Google Sign-In aborted'));
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;
      
      // Check if user exists, if not create
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      UserModel userModel;
      
      if (!userDoc.exists) {
        userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(userModel.toJson());
      } else {
        userModel = UserModel.fromJson(userDoc.data()!);
      }
      
      return right(userModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
       await _googleSignIn.signOut();
       await _auth.signOut();
       return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    // Firestore 'in' query supports up to 10 items. For more, we need to split or loop.
    // For MVP, if > 10, we'll chunk it.
    
    final List<UserModel> users = [];
    final chunks = [];
    for (var i = 0; i < userIds.length; i += 10) {
      chunks.add(userIds.sublist(i, (i + 10 > userIds.length) ? userIds.length : i + 10));
    }

    for (final chunk in chunks) {
      final qSnapshot = await _firestore.collection('users').where(FieldPath.documentId, whereIn: chunk).get();
      users.addAll(qSnapshot.docs.map((doc) => UserModel.fromJson(doc.data())));
    }

    return users;
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({required String name, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return left(Failure('User not found'));

      // Update Firebase Auth profile
      await user.updateDisplayName(name);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': name,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? 'Failed to send reset email'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail({required String email, required String password}) async {
    try {
      // We must sign in to send the verification email
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      if (credential.user!.emailVerified) {
         await _auth.signOut();
         return left(Failure('Email is already verified. Please sign in.'));
      }

      await credential.user!.sendEmailVerification();
      await _auth.signOut();
      
      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? 'Failed to resend verification email'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
