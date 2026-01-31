import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'core/config/environment.dart';
import 'main.dart'; // Reuse MyApp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppEnvironment.setup(
    flavor: Flavor.dev,
    packageName: 'in.mahato.cocircle.dev',
    appName: 'CoCircle (Dev)',
    googleServerClientId: '784947355898-ioil830tq5ubcoaapgdf9v7q1j7j1vjf.apps.googleusercontent.com',
  );

  // Initialize Firebase
  // TODO: Run `flutterfire configure -o lib/firebase_options_dev.dart` and uncomment below:
  // import 'firebase_options_dev.dart';
  try {
     await Firebase.initializeApp(
       // options: DefaultFirebaseOptions.currentPlatform,
     );

     // Initialize App Check (Hybrid: Debug for local, Play Integrity for prod)
     await FirebaseAppCheck.instance.activate(
       androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
       appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
     );

     debugPrint("Firebase Initialized for DEV with App Check");
  } catch(e) {
     debugPrint("Firebase init failed: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}
