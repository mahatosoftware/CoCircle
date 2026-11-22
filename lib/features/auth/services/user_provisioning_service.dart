import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../notifications/domain/notification_preferences_model.dart';
import '../domain/provisioning_state.dart';
import '../domain/user_model.dart';

/// Centralized, idempotent user provisioning service for CoCircle.
///
/// Implements:
/// - Stage A: Authentication verification.
/// - Stage B: Idempotent profile creation, partial document repair, and status machine.
/// - Stage C: Independent device registration (failure does not invalidate account).
/// - Concurrency protection: In-flight deduplication per UID.
/// - Privacy-safe diagnostic logging across DEV and PROD environments.
class UserProvisioningService {
  final FirebaseFirestore _firestore;
  final PushNotificationService _pushNotificationService;

  static const int currentProvisioningVersion = 1;

  // In-flight mutex to safely deduplicate concurrent provisioning calls per UID
  static final Map<String, Future<ProvisioningResult>> _inFlight = {};

  static final StreamController<ProvisioningResult?> _statusController =
      StreamController<ProvisioningResult?>.broadcast();
  static Stream<ProvisioningResult?> get statusStream => _statusController.stream;
  static ProvisioningResult? lastResult;

  static void resetState() {
    lastResult = null;
    _inFlight.clear();
    if (!_statusController.isClosed) {
      _statusController.add(null);
    }
  }

  void _broadcast(ProvisioningResult? result) {
    lastResult = result;
    if (!_statusController.isClosed) {
      _statusController.add(result);
    }
  }

  UserProvisioningService({
    FirebaseFirestore? firestore,
    PushNotificationService? pushNotificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _pushNotificationService = pushNotificationService ?? PushNotificationService();

  /// Privacy-safe UID masking for diagnostics (never logs tokens, passwords, or FCM keys).
  static String maskUid(String uid) {
    if (uid.length <= 8) return '***';
    return '${uid.substring(0, 4)}***${uid.substring(uid.length - 4)}';
  }

  void _log({
    required String stage,
    required String uid,
    required String message,
    String? errorCode,
    int retryCount = 0,
    bool isError = false,
  }) {
    final env = AppEnvironment.isProd ? 'PROD' : 'DEV';
    final masked = maskUid(uid);
    final logLine =
        '[PROVISIONING][Stage: $stage][Env: $env][UID: $masked][v$currentProvisioningVersion]'
        '${errorCode != null ? '[Err: $errorCode]' : ''}[Retry: $retryCount] $message';
    if (isError) {
      debugPrint('🛑 $logLine');
    } else {
      debugPrint('ℹ️ $logLine');
    }
  }

  /// Categorizes an exception into network, permission, or application failure.
  ProvisioningErrorType _classifyError(dynamic error) {
    if (error is FirebaseException) {
      final code = error.code.toLowerCase();
      if (code == 'permission-denied') return ProvisioningErrorType.permission;
      if (code == 'unavailable' ||
          code == 'deadline-exceeded' ||
          code == 'network-request-failed' ||
          code.contains('timeout')) {
        return ProvisioningErrorType.network;
      }
    }
    final str = error.toString().toLowerCase();
    if (str.contains('permission') || str.contains('denied')) {
      return ProvisioningErrorType.permission;
    }
    if (str.contains('network') ||
        str.contains('offline') ||
        str.contains('unavailable') ||
        str.contains('socket') ||
        str.contains('connection')) {
      return ProvisioningErrorType.network;
    }
    return ProvisioningErrorType.application;
  }

  /// Primary entrypoint: Guarantees user is fully provisioned in Firestore.
  /// Deduplicates concurrent in-flight requests per UID safely.
  Future<ProvisioningResult> ensureUserProvisioned(
    fb_auth.User user, {
    int retryCount = 0,
  }) {
    final uid = user.uid;
    if (lastResult != null &&
        lastResult!.isCompleted &&
        lastResult!.user?.uid == uid &&
        retryCount == 0) {
      return Future.value(lastResult!);
    }

    if (_inFlight.containsKey(uid)) {
      _log(
        stage: 'IN_FLIGHT_ATTACH',
        uid: uid,
        message: 'Reusing active in-flight provisioning future for UID.',
      );
      return _inFlight[uid]!;
    }

    final future = _executeProvisioning(user, retryCount: retryCount);
    _inFlight[uid] = future;

    return future.whenComplete(() {
      _inFlight.remove(uid);
    });
  }

  Future<ProvisioningResult> _executeProvisioning(
    fb_auth.User firebaseUser, {
    int retryCount = 0,
  }) async {
    final uid = firebaseUser.uid;
    _log(
      stage: 'STAGE_A_AUTH_VERIFY',
      uid: uid,
      message: 'Authentication validated. Starting Stage B provisioning.',
      retryCount: retryCount,
    );

    try {
      // 1. Stage B: Read users/{uid}
      final docRef = _firestore.collection('users').doc(uid);
      final snapshot = await docRef.get();
      final data = snapshot.data();

      UserModel finalUserModel;

      if (!snapshot.exists || data == null) {
        // Case A: Document genuinely missing
        _log(
          stage: 'STAGE_B_CREATE',
          uid: uid,
          message: 'Document missing in database. Creating initial profile.',
          retryCount: retryCount,
        );
        finalUserModel = await createUserProfile(firebaseUser);
      } else {
        // Document exists. Check completeness of mandatory fields
        final hasUid = data['uid'] != null && (data['uid'] as String).trim().isNotEmpty;
        final hasEmail = data['email'] != null && (data['email'] as String).trim().isNotEmpty;
        final hasDisplayName =
            data['displayName'] != null && (data['displayName'] as String).trim().isNotEmpty;
        final hasCreatedAt = data['createdAt'] != null;

        final isFullyPopulated = hasUid && hasEmail && hasDisplayName && hasCreatedAt;

        if (!isFullyPopulated) {
          // Case B: Document partially populated (e.g. only device tokens written previously)
          _log(
            stage: 'STAGE_B_REPAIR',
            uid: uid,
            message: 'Partial profile found (missing mandatory fields). Repairing missing fields while preserving existing data.',
            retryCount: retryCount,
          );
          finalUserModel = await repairUserProfile(uid, firebaseUser, data);
        } else {
          // Profile is healthy. Preserve existing customized fields
          _log(
            stage: 'STAGE_B_EXISTING_VERIFIED',
            uid: uid,
            message: 'Existing profile verified intact. Preserving customized data.',
            retryCount: retryCount,
          );
          finalUserModel = UserModel.fromJson(data);
        }
      }

      // 2. Ensure default dependent records (e.g. notification preferences)
      await ensureDefaultUserRecords(uid);

      // 3. Mark Stage B Provisioning as COMPLETED
      await docRef.set({
        'provisioningStatus': ProvisioningStatus.completed.name,
        'provisioningVersion': currentProvisioningVersion,
        'provisioningUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _log(
        stage: 'STAGE_B_COMPLETED',
        uid: uid,
        message: 'Stage B user provisioning completed and verified successfully.',
        retryCount: retryCount,
      );

      // 4. Stage C: Device registration (Independent stage)
      // Device registration failure MUST NOT invalidate an otherwise successful user account.
      _registerDeviceIndependently(uid);

      final successResult = ProvisioningResult(
        status: ProvisioningStatus.completed,
        user: finalUserModel,
        version: currentProvisioningVersion,
        stage: 'completed',
        retryCount: retryCount,
        updatedAt: DateTime.now(),
      );
      _broadcast(successResult);
      return successResult;
    } catch (e, stack) {
      final errorType = _classifyError(e);
      final errorCode = e is FirebaseException ? e.code : 'UNKNOWN';

      _log(
        stage: 'STAGE_B_FAILED',
        uid: uid,
        message: 'Provisioning failed: $e',
        errorCode: errorCode,
        retryCount: retryCount,
        isError: true,
      );
      debugPrint('Provisioning stack trace: $stack');

      // Update failed status in doc if possible, without erasing existing data
      try {
        await _firestore.collection('users').doc(uid).set({
          'provisioningStatus': ProvisioningStatus.failed.name,
          'provisioningError': e.toString(),
          'provisioningErrorType': errorType.name,
          'provisioningUpdatedAt': FieldValue.serverTimestamp(),
          'provisioningRetryCount': retryCount,
        }, SetOptions(merge: true));
      } catch (_) {}

      final failureResult = ProvisioningResult(
        status: ProvisioningStatus.failed,
        error: e.toString(),
        errorType: errorType,
        version: currentProvisioningVersion,
        stage: 'stage_b_write',
        retryCount: retryCount,
        updatedAt: DateTime.now(),
      );
      _broadcast(failureResult);
      return failureResult;
    }
  }

  /// Creates a brand-new user document in users/{uid} with mandatory baseline fields.
  Future<UserModel> createUserProfile(fb_auth.User firebaseUser) async {
    final uid = firebaseUser.uid;
    final fallbackName = (firebaseUser.email != null && firebaseUser.email!.isNotEmpty)
        ? firebaseUser.email!.split('@').first
        : 'User';
    final displayName = (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty)
        ? firebaseUser.displayName!.trim()
        : fallbackName;

    final newUser = UserModel(
      uid: uid,
      email: firebaseUser.email ?? '',
      displayName: displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
    );

    final payload = {
      'uid': newUser.uid,
      'email': newUser.email,
      'displayName': newUser.displayName,
      'photoUrl': newUser.photoUrl,
      'country': null,
      'vpa': null,
      'createdAt': newUser.createdAt.toIso8601String(),
      'provisioningStatus': ProvisioningStatus.in_progress.name,
      'provisioningVersion': currentProvisioningVersion,
      'provisioningUpdatedAt': FieldValue.serverTimestamp(),
      'notificationPreferences': const NotificationPreferencesModel().toJson(),
    };

    await _firestore.collection('users').doc(uid).set(payload, SetOptions(merge: true));

    return newUser;
  }

  /// Repairs missing mandatory fields while strictly preserving existing customized data.
  Future<UserModel> repairUserProfile(
    String uid,
    fb_auth.User firebaseUser,
    Map<String, dynamic> existingData,
  ) async {
    final fallbackName = (firebaseUser.email != null && firebaseUser.email!.isNotEmpty)
        ? firebaseUser.email!.split('@').first
        : 'User';
    final fallbackDisplayName = (firebaseUser.displayName != null && firebaseUser.displayName!.trim().isNotEmpty)
        ? firebaseUser.displayName!.trim()
        : fallbackName;

    // Preserve existing custom fields if present; only provide fallback if missing/empty
    final existingUid = existingData['uid'] as String?;
    final existingEmail = existingData['email'] as String?;
    final existingDisplayName = existingData['displayName'] as String?;
    final existingPhotoUrl = existingData['photoUrl'] as String?;

    final resolvedUid = (existingUid != null && existingUid.isNotEmpty) ? existingUid : uid;
    final resolvedEmail = (existingEmail != null && existingEmail.isNotEmpty)
        ? existingEmail
        : (firebaseUser.email ?? '');
    final resolvedDisplayName = (existingDisplayName != null && existingDisplayName.isNotEmpty)
        ? existingDisplayName
        : fallbackDisplayName;
    final resolvedPhotoUrl = (existingPhotoUrl != null && existingPhotoUrl.isNotEmpty)
        ? existingPhotoUrl
        : firebaseUser.photoURL;

    // Resilient parse of existing createdAt
    DateTime resolvedCreatedAt;
    final rawCreatedAt = existingData['createdAt'];
    if (rawCreatedAt is String) {
      resolvedCreatedAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else if (rawCreatedAt is Timestamp) {
      resolvedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      resolvedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      resolvedCreatedAt = DateTime.now();
    }

    final repairedUser = UserModel(
      uid: resolvedUid,
      email: resolvedEmail,
      displayName: resolvedDisplayName,
      country: existingData['country'] as String?,
      vpa: existingData['vpa'] as String?,
      photoUrl: resolvedPhotoUrl,
      createdAt: resolvedCreatedAt,
    );

    // Merge write only missing mandatory items to guarantee non-destruction
    final Map<String, dynamic> repairPayload = {
      'uid': resolvedUid,
      'email': resolvedEmail,
      'displayName': resolvedDisplayName,
      'createdAt': resolvedCreatedAt.toIso8601String(),
      if (resolvedPhotoUrl != null && existingPhotoUrl == null) 'photoUrl': resolvedPhotoUrl,
      'provisioningStatus': ProvisioningStatus.in_progress.name,
      'provisioningVersion': currentProvisioningVersion,
      'provisioningUpdatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(uid).set(repairPayload, SetOptions(merge: true));

    return repairedUser;
  }

  /// Initializes default user records (like notificationPreferences) if missing,
  /// but NEVER resets or overwrites existing user preferences.
  Future<void> ensureDefaultUserRecords(String uid) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data() ?? {};

    if (data['notificationPreferences'] == null) {
      _log(
        stage: 'ENSURE_DEFAULTS',
        uid: uid,
        message: 'Initializing missing default notification preferences.',
      );
      await docRef.set({
        'notificationPreferences': const NotificationPreferencesModel().toJson(),
      }, SetOptions(merge: true));
    }
  }

  /// Checks the current status of the user profile document in Firestore.
  Future<ProvisioningStatus> checkUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        return ProvisioningStatus.pending;
      }
      final data = doc.data()!;
      final hasUid = data['uid'] != null && (data['uid'] as String).isNotEmpty;
      final hasEmail = data['email'] != null;
      final hasDisplayName = data['displayName'] != null;
      final hasCreatedAt = data['createdAt'] != null;

      if (!hasUid || !hasEmail || !hasDisplayName || !hasCreatedAt) {
        return ProvisioningStatus.needs_repair;
      }

      final statusStr = data['provisioningStatus'] as String?;
      if (statusStr == ProvisioningStatus.completed.name) {
        return ProvisioningStatus.completed;
      }

      return ProvisioningStatus.completed;
    } catch (e) {
      _log(
        stage: 'CHECK_PROFILE',
        uid: uid,
        message: 'Error checking profile: $e',
        errorCode: e is FirebaseException ? e.code : 'UNKNOWN',
        isError: true,
      );
      return ProvisioningStatus.failed;
    }
  }

  /// Fetches the provisioning status from Firestore.
  Future<ProvisioningStatus> getProvisioningStatus(String uid) async {
    return checkUserProfile(uid);
  }

  /// Retries provisioning with an incremented retry counter.
  Future<ProvisioningResult> retryProvisioning(fb_auth.User user, {int currentRetries = 0}) {
    _log(
      stage: 'RETRY_TRIGGERED',
      uid: user.uid,
      message: 'User requested provisioning retry.',
      retryCount: currentRetries + 1,
    );
    return ensureUserProvisioned(user, retryCount: currentRetries + 1);
  }

  /// Stage C: Device registration executed asynchronously and independently.
  /// Failure will NEVER fail user provisioning or invalidate the account.
  void _registerDeviceIndependently(String uid) {
    unawaited(() async {
      try {
        _log(
          stage: 'STAGE_C_DEVICE_START',
          uid: uid,
          message: 'Initiating Stage C independent device registration.',
        );
        await _pushNotificationService.syncDeviceToken(uid);
        _log(
          stage: 'STAGE_C_DEVICE_COMPLETE',
          uid: uid,
          message: 'Stage C device registration completed successfully.',
        );
      } catch (e) {
        _log(
          stage: 'STAGE_C_DEVICE_WARN',
          uid: uid,
          message: 'Device registration encountered non-fatal error: $e. Account remains valid.',
          errorCode: e is FirebaseException ? e.code : 'UNKNOWN',
        );
      }
    }());
  }
}
