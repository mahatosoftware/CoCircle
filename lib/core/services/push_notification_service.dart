import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/domain/notification_preferences_model.dart';

/// Top-level background message handler required by FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM: Handling background message ID: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  GoRouter? _router;

  /// Initializes push notification listeners, requests permissions, and wires deep links.
  Future<void> initialize({required GoRouter router, String? currentUserId}) async {
    _router = router;
    _currentUserId = currentUserId;

    // 1. Set background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request Notification Permissions
    await requestPermissions();

    // 3. Configure foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Handle initial message if app launched from terminated state
    await checkInitialMessage();

    // 5. Setup message listeners
    _setupMessageListeners();

    // 6. Register token if user is already signed in
    if (currentUserId != null && currentUserId.isNotEmpty) {
      await syncDeviceToken(currentUserId);
    }
  }

  /// Request permissions on Android 13+ and iOS.
  Future<NotificationSettings> requestPermissions() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM: User granted permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('FCM: Failed to request permission: $e');
      rethrow;
    }
  }

  /// Synchronize the device token with Firestore users/{userId}.
  Future<void> syncDeviceToken(String userId) async {
    _currentUserId = userId;
    try {
      // 1. Ensure permission is requested if not determined yet (first login)
      try {
        final settings = await _fcm.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
          await requestPermissions();
        }
      } catch (e) {
        debugPrint('FCM: Error checking notification settings: $e');
      }

      // 2. Fetch device token with retry logic for iOS APNS registration
      final token = await _getTokenWithRetry();
      if (token != null && token.isNotEmpty) {
        debugPrint('FCM: Registering token for user $userId: $token');
        await _saveTokenToFirestore(userId, token);
      }

      // 3. Listen for token registration & refresh events
      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _fcm.onRegistered.listen((newToken) async {
        debugPrint('FCM: Device token registered/refreshed for user $userId: $newToken');
        await _saveTokenToFirestore(userId, newToken);
      });
      try {
        await _fcm.register();
      } catch (e) {
        debugPrint('FCM: register() error: $e');
      }
    } catch (e) {
      debugPrint('FCM: Could not fetch/sync device token: $e');
    }
  }

  /// Fetches FCM device token, waiting for APNS registration on iOS if necessary.
  Future<String?> _getTokenWithRetry() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        int attempts = 0;
        while (apnsToken == null && attempts < 3) {
          await Future.delayed(const Duration(milliseconds: 1000));
          apnsToken = await _fcm.getAPNSToken();
          attempts++;
        }
      }
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
      return null;
    }
  }

  /// Removes current token when user logs out.
  Future<void> removeDeviceToken(String userId) async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
      await _tokenRefreshSubscription?.cancel();
      _currentUserId = null;
    } catch (e) {
      debugPrint('FCM: Could not remove device token: $e');
    }
  }

  /// Saves or appends device token to users/{userId} array in Firestore.
  /// Strictly ensures the user profile document exists before updating,
  /// completely preventing orphaned partial documents.
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      final docSnap = await docRef.get();

      if (!docSnap.exists || docSnap.data()?['uid'] == null) {
        debugPrint('FCM: User document $userId not fully provisioned yet. Skipping device token write to prevent orphaned partial documents.');
        return;
      }

      final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
      await docRef.update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastTokenUpdated': FieldValue.serverTimestamp(),
        'platform': platform,
      });
      debugPrint('FCM: Successfully registered device token for user $userId');
    } catch (e) {
      debugPrint('FCM: Non-fatal error writing token to Firestore: $e');
    }
  }

  /// Update user notification preferences (muting trips/circles or toggling expenses).
  Future<void> updateNotificationPreferences(
    String userId,
    NotificationPreferencesModel preferences,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'notificationPreferences': preferences.toJson(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FCM: Failed updating notification preferences: $e');
      rethrow;
    }
  }

  /// Setup foreground and background notification click listeners.
  void _setupMessageListeners() {
    // Foreground message handler
    _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM: Foreground message received: ${message.notification?.title} - ${message.notification?.body}');
      // Foreground notifications can trigger in-app UI badges or local alerts
    });

    // Background notification tap handler
    _messageOpenedSubscription?.cancel();
    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM: Notification tapped from background: ${message.data}');
      _handleNotificationTap(message);
    });
  }

  /// Checks if the app was launched by tapping a push notification from terminated state.
  Future<void> checkInitialMessage() async {
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM: App opened from terminated state via notification: ${initialMessage.data}');
        // Delay slightly to let router and widget tree initialize
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleNotificationTap(initialMessage);
        });
      }
    } catch (e) {
      debugPrint('FCM: Error checking initial message: $e');
    }
  }

  /// Deep link navigation to the target screen based on notification payload.
  void _handleNotificationTap(RemoteMessage message) {
    if (_router == null) {
      debugPrint('FCM: Router is null, cannot perform deep link.');
      return;
    }

    final data = message.data;
    final targetPath = data['targetPath'] as String?;
    final tripId = data['tripId'] as String?;
    final expenseId = data['expenseId'] as String?;
    final type = data['type'] as String?;

    if (targetPath != null && targetPath.isNotEmpty) {
      debugPrint('FCM: Navigating to targetPath: $targetPath');
      _router!.push(targetPath);
      return;
    }

    // Fallback routing by notification type
    if (type == 'expense_deleted' && tripId != null) {
      _router!.push('/trip/$tripId?tab=5');
    } else if (tripId != null && expenseId != null) {
      _router!.push('/trip/$tripId/expense/$expenseId');
    } else if (tripId != null) {
      _router!.push('/trip/$tripId?tab=5');
    } else {
      _router!.push('/activity-center');
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundMessageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
  }
}
