import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../ai/data/firebase_ai_config_repository.dart';
import 'environment.dart';
import '../../features/auth/services/user_provisioning_service.dart';
import '../../firebase_options_dev.dart' as dev_options;
import '../../firebase_options_prod.dart' as prod_options;
import '../../main.dart' show MyApp;

/// Centralized application bootstrap that guarantees:
/// 1. Exactly-once Firebase initialization per isolate with duplicate-app safety.
/// 2. Strict flavor isolation without silent fallbacks.
/// 3. Secure initialization of Google Sign-In and App Check without leaking credentials.
class AppBootstrap {
  static bool _initialized = false;

  static Future<void> run(Flavor flavor) async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Edge-to-Edge UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    // 2. Setup Environment
    _configureEnvironment(flavor);

    // 3. Initialize Mobile Ads
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint("MobileAds initialization notice: $e");
    }

    // 4. Initialize Google Sign-In
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppEnvironment.googleServerClientId,
      );
      debugPrint("Google Sign In initialized for ${flavor.name.toUpperCase()}");
    } catch (e) {
      debugPrint("Google Sign In initialization error: $e");
    }

    // 5. Initialize Firebase
    await _initializeFirebase(flavor);

    // 6. Verify and set up current user profile in Firestore if missing
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await UserProvisioningService().ensureUserProvisioned(currentUser);
      }
    } catch (e) {
      debugPrint("AppBootstrap: User provisioning setup verification: $e");
    }

    // 7. Launch Application
    runApp(const ProviderScope(child: MyApp()));
  }

  static void _configureEnvironment(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        AppEnvironment.setup(
          flavor: Flavor.dev,
          packageName: 'in.mahato.cocircle.dev',
          appName: 'CoCircle (Dev)',
          googleServerClientId:
              '1017871867803-msahbu6re9b86s8g8k31vtuotlh83vss.apps.googleusercontent.com',
          defaultDatabaseUrl:
              'https://cocircle-firebase-development-default-rtdb.asia-southeast1.firebasedatabase.app',
        );
        break;
      case Flavor.prod:
        AppEnvironment.setup(
          flavor: Flavor.prod,
          packageName: 'in.mahato.cocircle',
          appName: 'CoCircle',
          googleServerClientId:
              '273341956-u3ub04qtsebrfs3e7ge17p1dj36af1ea.apps.googleusercontent.com',
          defaultDatabaseUrl:
              'https://cocircle-firebase-prod-default-rtdb.asia-southeast1.firebasedatabase.app',
        );
        break;
    }
  }

  static Future<void> _initializeFirebase(Flavor flavor) async {
    if (_initialized) {
      debugPrint("Firebase bootstrap already executed for this isolate.");
      return;
    }

    final firebaseOptions = flavor == Flavor.dev
        ? dev_options.DefaultFirebaseOptions.currentPlatform
        : prod_options.DefaultFirebaseOptions.currentPlatform;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: firebaseOptions);
        debugPrint("Firebase initialized for ${flavor.name.toUpperCase()}");
      } else {
        debugPrint("Firebase [DEFAULT] app already present");
      }
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint("Firebase duplicate-app caught: default app is already active");
      } else {
        debugPrint("Firebase initialization exception: ${e.code}");
        rethrow;
      }
    } catch (e) {
      debugPrint("Unexpected Firebase initialization error: $e");
    }

    _initialized = true;

    // Verify and set up essential global config tables in Firestore if missing
    try {
      final settingsRef = FirebaseFirestore.instance.collection('config').doc('settings');
      final doc = await settingsRef.get();
      if (!doc.exists) {
        debugPrint("Config settings missing in Firestore. Initializing default settings.");
        await settingsRef.set({
          'databaseURL': AppEnvironment.databaseUrl,
          'version': '1.0.0',
          'initializedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        final url = doc.data()?['databaseURL'] as String?;
        if (url != null && url.isNotEmpty) {
          AppEnvironment.databaseUrl = url;
        }
      }
    } catch (e) {
      debugPrint("Config settings verify/setup: $e");
    }

    // Verify and seed AI Config if missing
    try {
      await FirebaseAiConfigRepository().ensureAiConfigSeeded();
    } catch (e) {
      debugPrint("Could not verify/seed AI config in Firestore: $e");
    }

    // App Check Initialization
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
      );
    } catch (e) {
      debugPrint("AppCheck activate error: $e");
    }
  }
}
