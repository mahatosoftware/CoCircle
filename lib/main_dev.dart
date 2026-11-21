import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/config/environment.dart';
import 'core/ai/data/firebase_ai_config_repository.dart';
import 'main.dart'; // Reuse MyApp
import 'firebase_options_dev.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Edge-to-Edge at the Flutter level
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  AppEnvironment.setup(
    flavor: Flavor.dev,
    packageName: 'in.mahato.cocircle.dev',
    appName: 'CoCircle (Dev)',
    googleServerClientId:
        '1017871867803-msahbu6re9b86s8g8k31vtuotlh83vss.apps.googleusercontent.com',
    defaultDatabaseUrl:
        'https://cocircle-firebase-development-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  // Initialize Google Sign In (Required for 7.0.0+) immediately and independently
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: AppEnvironment.googleServerClientId,
    );
    debugPrint("Google Sign In initialized for DEV with serverClientId: ${AppEnvironment.googleServerClientId}");
  } catch (e) {
    debugPrint("Google Sign In init failed: $e");
  }

  // Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      debugPrint("Firebase default app already initialized");
    }

    // Fetch dynamic database URL from config table
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('settings')
          .get();
      final url = doc.data()?['databaseURL'] as String?;
      if (url != null && url.isNotEmpty) {
        AppEnvironment.databaseUrl = url;
        debugPrint("Loaded RTDB URL dynamically: $url");
      }
    } catch (e) {
      debugPrint("Could not load RTDB URL from Firestore: $e");
    }

    // Initialize AI Config for DEV Firestore if missing
    try {
      await FirebaseAiConfigRepository().ensureDevAiConfigSeeded();
      debugPrint("Seeded/Verified Firestore config/ai_config for DEV");
    } catch (e) {
      debugPrint("Could not seed AI config in DEV Firestore: $e");
    }

    // Initialize App Check (Hybrid: Debug for local, Play Integrity for prod)
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
    } catch (e) {
      debugPrint("AppCheck activate error: $e");
    }

    debugPrint("Firebase Initialized for DEV with App Check");
  } catch (e, stack) {
    debugPrint("Firebase init failed: $e");
    debugPrint("Stack trace: $stack");
  }

  runApp(const ProviderScope(child: MyApp()));
}
