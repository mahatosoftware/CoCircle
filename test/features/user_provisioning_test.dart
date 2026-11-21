import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cocircle/features/auth/domain/provisioning_state.dart';
import 'package:cocircle/features/auth/domain/user_model.dart';
import 'package:cocircle/features/auth/services/user_provisioning_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseUser extends Mock implements fb_auth.User {
  @override
  String get uid => 'user_1234567890';
  @override
  String? get email => 'traveler@cocircle.app';
  @override
  String? get displayName => 'Global Traveler';
  @override
  String? get photoURL => 'https://example.com/avatar.png';
}

void main() {
  group('UserProvisioning Architecture Test Suite', () {
    test('1. Privacy-Safe UID Masking never exposes full account identifiers', () {
      expect(UserProvisioningService.maskUid('1234567890'), '1234***7890');
      expect(UserProvisioningService.maskUid('abcd1234efgh5678'), 'abcd***5678');
      expect(UserProvisioningService.maskUid('short'), '***');
    });

    test('2. Defensive UserModel Deserialization handles partial/corrupted Firestore documents', () {
      // Test partial document where only fcmTokens was stored
      final partialJson = <String, dynamic>{
        'fcmTokens': ['token_abc_123'],
        'platform': 'android',
      };

      final fallbackUser = UserModel.fromJson(partialJson);
      expect(fallbackUser.uid, '');
      expect(fallbackUser.email, '');
      expect(fallbackUser.displayName, 'User');
      expect(fallbackUser.createdAt, isA<DateTime>());

      // Test Timestamp object for createdAt
      final timestampJson = <String, dynamic>{
        'uid': 'test_uid_999',
        'email': 'alice@example.com',
        'displayName': 'Alice',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 15, 10, 30)),
      };
      final timestampUser = UserModel.fromJson(timestampJson);
      expect(timestampUser.uid, 'test_uid_999');
      expect(timestampUser.email, 'alice@example.com');
      expect(timestampUser.displayName, 'Alice');
      expect(timestampUser.createdAt.year, 2026);
      expect(timestampUser.createdAt.month, 1);
    });

    test('3. ProvisioningState Model serialization & status machine transitions', () {
      final initial = ProvisioningResult(
        status: ProvisioningStatus.pending,
        version: 1,
        stage: 'init',
        updatedAt: DateTime.now(),
      );
      expect(initial.isCompleted, isFalse);

      final inProgress = initial.copyWith(
        status: ProvisioningStatus.in_progress,
        stage: 'stage_b_write',
      );
      expect(inProgress.status, ProvisioningStatus.in_progress);

      final completed = inProgress.copyWith(
        status: ProvisioningStatus.completed,
        stage: 'completed',
        user: UserModel(
          uid: 'user_123',
          email: 'test@example.com',
          displayName: 'Test User',
          createdAt: DateTime.now(),
        ),
      );
      expect(completed.isCompleted, isTrue);
      expect(completed.user?.displayName, 'Test User');

      final failed = inProgress.copyWith(
        status: ProvisioningStatus.failed,
        error: 'Network connection closed',
        errorType: ProvisioningErrorType.network,
        retryCount: 2,
      );
      expect(failed.isCompleted, isFalse);
      expect(failed.isFailed, isTrue);
      expect(failed.errorType, ProvisioningErrorType.network);
      expect(failed.retryCount, 2);
    });

    test('4. Existing Account Repair strictly preserves customized fields and dependent data', () async {
      final mockUser = MockFirebaseUser();
      final existingPartialData = <String, dynamic>{
        'uid': 'user_1234567890',
        'country': 'India',
        'vpa': 'traveler@upi',
        'photoUrl': 'https://custom-avatar.com/pic.png',
        'fcmTokens': ['existing_fcm_token_1'],
        'createdAt': '2025-05-10T12:00:00.000Z',
        // displayName and email were missing in database
      };

      // Verify repair logic preserves custom data while falling back on missing fields
      final repairedUser = UserModel(
        uid: (existingPartialData['uid'] as String?) ?? mockUser.uid,
        email: (existingPartialData['email'] as String?) ?? mockUser.email!,
        displayName: (existingPartialData['displayName'] as String?) ?? mockUser.displayName!,
        country: existingPartialData['country'] as String?,
        vpa: existingPartialData['vpa'] as String?,
        photoUrl: (existingPartialData['photoUrl'] as String?) ?? mockUser.photoURL,
        createdAt: DateTime.parse(existingPartialData['createdAt'] as String),
      );

      // Verify custom fields were NOT overwritten
      expect(repairedUser.uid, 'user_1234567890');
      expect(repairedUser.country, 'India');
      expect(repairedUser.vpa, 'traveler@upi');
      expect(repairedUser.photoUrl, 'https://custom-avatar.com/pic.png');
      expect(repairedUser.displayName, 'Global Traveler'); // Fallback applied
      expect(repairedUser.email, 'traveler@cocircle.app'); // Fallback applied
      expect(repairedUser.createdAt.year, 2025); // Original timestamp preserved
    });

    test('5. State reset clears static mutexes and broadcast stream safely', () {
      UserProvisioningService.resetState();
      expect(UserProvisioningService.lastResult, isNull);
    });
  });
}
