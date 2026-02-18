import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'core/config/environment.dart';
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
    googleServerClientId: '784947355898-ioil830tq5ubcoaapgdf9v7q1j7j1vjf.apps.googleusercontent.com',
  );

  // Initialize Firebase
  try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     // Initialize App Check (Hybrid: Debug for local, Play Integrity for prod)
     await FirebaseAppCheck.instance.activate(
       providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
       providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
     );

      // Initialize Google Sign In (Required for 7.0.0+)
      await GoogleSignIn.instance.initialize(
        serverClientId: AppEnvironment.googleServerClientId,
      );

     debugPrint("Firebase Initialized for DEV with App Check");
  } catch(e, stack) {
     debugPrint("Firebase init failed: $e");
     debugPrint("Stack trace: $stack");
  }

  runApp(const ProviderScope(child: MyApp()));
}
