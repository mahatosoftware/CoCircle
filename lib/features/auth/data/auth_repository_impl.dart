import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/services/push_notification_service.dart';
import '../domain/auth_repository.dart';
import '../domain/provisioning_state.dart';
import '../domain/user_model.dart';
import '../services/user_provisioning_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn.instance,
    firestore: FirebaseFirestore.instance,
    provisioningService: UserProvisioningService(firestore: FirebaseFirestore.instance),
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
  final UserProvisioningService _provisioningService;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
    UserProvisioningService? provisioningService,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestore = firestore,
        _provisioningService = provisioningService ?? UserProvisioningService(firestore: firestore);

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        UserProvisioningService.resetState();
        return null;
      }

      // Stage B & C: Idempotently ensure the user profile is provisioned and repaired
      try {
        final result = await _provisioningService.ensureUserProvisioned(firebaseUser);
        if (result.status == ProvisioningStatus.completed && result.user != null) {
          return result.user;
        }
      } catch (e) {
        debugPrint('authStateChanges: Provisioning check error: $e');
      }

      // Fallback check in case Firestore read is possible
      try {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
      } catch (_) {}

      // Resilient fallback user model to maintain session without throwing
      final fallbackName = (firebaseUser.email != null && firebaseUser.email!.isNotEmpty)
          ? firebaseUser.email!.split('@').first
          : 'User';
      return UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty)
            ? firebaseUser.displayName!.trim()
            : fallbackName,
        photoUrl: firebaseUser.photoURL,
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailPassword({required String email, required String password}) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Reload user to get latest verification status
        await firebaseUser.reload();

        if (!_auth.currentUser!.emailVerified) {
          debugPrint("Sign In: Email not verified for ${firebaseUser.email}");
          await _auth.signOut();
          return left(Failure('Please verify your email address to log in. If you don\'t see the email, check your spam folder.'));
        }

        // Stage B & C: Centralized idempotent provisioning & device registration
        final provisioningResult = await _provisioningService.ensureUserProvisioned(firebaseUser);
        if (provisioningResult.status == ProvisioningStatus.completed && provisioningResult.user != null) {
          return right(provisioningResult.user!);
        } else {
          return left(Failure(provisioningResult.error ?? 'Account provisioning failed. Please retry.'));
        }
      }

      return left(Failure('User data not found'));
    } on FirebaseAuthException catch (e) {
      debugPrint("Error signing in with Email: $e");
      return left(Failure(e.message ?? 'Sign in failed'));
    } catch (e, stack) {
      debugPrint("Error signing in with Email: $e");
      debugPrint("Stack trace: $stack");
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailPassword({required String email, required String password, required String name}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user!;

      await firebaseUser.sendEmailVerification();
      await firebaseUser.updateDisplayName(name);

      // Stage B: Initial user profile creation
      final newUser = await _provisioningService.createUserProfile(firebaseUser);

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
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      debugPrint("Google Sign-In: Account obtained: ${googleUser.email}");

      // Authentication tokens (ID Token)
      final String? idToken = googleUser.authentication.idToken;

      // Authorization tokens (Access Token)
      final authz = await googleUser.authorizationClient.authorizeScopes([
        'openid',
        'email',
        'profile',
      ]);
      final String accessToken = authz.accessToken;

      debugPrint("Google Sign-In: idToken: ${idToken != null ? 'Present' : 'Missing'}");
      debugPrint("Google Sign-In: accessToken: Present");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      debugPrint("Google Sign-In: Firebase Auth successful for UID: ${firebaseUser.uid}");

      // Stage B & Stage C: Centralized idempotent provisioning & device registration
      final provisioningResult = await _provisioningService.ensureUserProvisioned(firebaseUser);

      if (provisioningResult.status == ProvisioningStatus.completed && provisioningResult.user != null) {
        return right(provisioningResult.user!);
      } else {
        return left(Failure(provisioningResult.error ?? 'Account provisioning failed. Please retry.'));
      }
    } catch (e, stack) {
      debugPrint("Google Sign-In Error: $e");
      debugPrint("Stack trace: $stack");

      // Reset any partially held credential state in Credential Manager
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      if (e is GoogleSignInException) {
        final desc = e.description ?? '';
        final isReauthFailure = desc.contains('16') ||
            desc.toLowerCase().contains('reauth') ||
            desc.toLowerCase().contains('account reauth failed');

        if (isReauthFailure) {
          return left(Failure(
            'Google Sign-In failed: Re-authentication rejected [16]. Check if: 1) Your email is added to Test Users in Google Cloud OAuth consent screen (if status is Testing), 2) SHA-256 fingerprint (B7:FF:F0:...) is added to Firebase Console, or 3) Google provider is enabled in Firebase Auth.',
          ));
        }

        if (e.code == GoogleSignInExceptionCode.canceled) {
          return left(Failure('Sign in canceled'));
        }
      }

      final errStr = e.toString();
      if (errStr.contains('28444') || errStr.contains('Developer console is not set up correctly')) {
        return left(Failure(
          'Google Sign-In setup error (28444): Please register the debug SHA-256 fingerprint in Firebase Console, enable the Google provider, or add your email to OAuth Test Users.',
        ));
      }
      return left(Failure(errStr));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      final currentUid = _auth.currentUser?.uid;
      if (currentUid != null) {
        try {
          await PushNotificationService().removeDeviceToken(currentUid);
        } catch (e) {
          debugPrint("Failed to remove device token on signOut: $e");
        }
      }
      UserProvisioningService.resetState();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return right(null);
    } catch (e) {
      debugPrint("Error signing out: $e");
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
  Future<Either<Failure, void>> updateUserProfile({required String name, String? country, String? vpa, String? photoUrl}) async {
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
        if (country != null) 'country': country,
        if (vpa != null) 'vpa': vpa,
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
      await _auth.sendPasswordResetEmail(
        email: email,
      );
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
      
      // Reload user to get latest verification status
      await credential.user!.reload();
      
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
