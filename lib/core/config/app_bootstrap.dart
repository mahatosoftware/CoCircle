import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../ai/data/firebase_ai_config_repository.dart';
import 'environment.dart';
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

    // 6. Launch Application
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

    // Load dynamic RTDB database URL from Firestore config/settings
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('settings').get();
      final url = doc.data()?['databaseURL'] as String?;
      if (url != null && url.isNotEmpty) {
        AppEnvironment.databaseUrl = url;
      }
    } catch (e) {
      debugPrint("Could not load dynamic RTDB URL: $e");
    }

    // Seed AI Config in DEV if missing
    if (flavor == Flavor.dev) {
      try {
        await FirebaseAiConfigRepository().ensureDevAiConfigSeeded();
      } catch (e) {
        debugPrint("Could not seed AI config in DEV Firestore: $e");
      }
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
