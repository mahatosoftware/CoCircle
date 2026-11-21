import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/config/environment.dart';
import 'core/ai/data/firebase_ai_config_repository.dart';
import 'router.dart';
import 'firebase_options_prod.dart' as prod_options;
import 'firebase_options_dev.dart' as dev_options;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cocircle/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await MobileAds.instance.initialize();
  
  // Enable Edge-to-Edge at the Flutter level
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  // Dynamically detect environment from the running platform package
  bool isDev = false;
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    isDev = packageInfo.packageName.contains('.dev');
    debugPrint("Detected application package: ${packageInfo.packageName} (isDev: $isDev)");
  } catch (e) {
    debugPrint("Could not determine package info: $e, defaulting to dev in debug mode");
    isDev = kDebugMode;
  }

  if (isDev) {
    AppEnvironment.setup(
      flavor: Flavor.dev,
      packageName: 'in.mahato.cocircle.dev',
      appName: 'CoCircle (Dev)',
      googleServerClientId:
          '1017871867803-msahbu6re9b86s8g8k31vtuotlh83vss.apps.googleusercontent.com',
      defaultDatabaseUrl:
          'https://cocircle-firebase-development-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
  } else {
    AppEnvironment.setup(
      flavor: Flavor.prod,
      packageName: 'in.mahato.cocircle',
      appName: 'CoCircle',
      googleServerClientId:
          '273341956-u3ub04qtsebrfs3e7ge17p1dj36af1ea.apps.googleusercontent.com',
      defaultDatabaseUrl:
          'https://cocircle-firebase-prod-default-rtdb.asia-southeast1.firebasedatabase.app',
    );
  }

  // Initialize Google Sign In (Required for 7.0.0+) immediately and independently
  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: AppEnvironment.googleServerClientId,
    );
    debugPrint("Google Sign In initialized for ${isDev ? 'DEV' : 'PROD'} with serverClientId: ${AppEnvironment.googleServerClientId}");
  } catch (e) {
    debugPrint("Google Sign In init failed: $e");
  }

  // Initialize Firebase
  try {
    final firebaseOptions = isDev
        ? dev_options.DefaultFirebaseOptions.currentPlatform
        : prod_options.DefaultFirebaseOptions.currentPlatform;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
      debugPrint("Firebase initialized with project: ${firebaseOptions.projectId}");
    } else {
      debugPrint("Firebase default app already initialized");
    }

    // Fetch dynamic database URL from config table
    try {
      final doc = await FirebaseFirestore.instance.collection('config').doc('settings').get();
      final url = doc.data()?['databaseURL'] as String?;
      if (url != null && url.isNotEmpty) {
        AppEnvironment.databaseUrl = url;
        debugPrint("Loaded RTDB URL dynamically: $url");
      }
    } catch (e) {
      debugPrint("Could not load RTDB URL from Firestore: $e");
    }

    // Initialize AI Config for DEV Firestore if missing
    if (isDev) {
      try {
        await FirebaseAiConfigRepository().ensureDevAiConfigSeeded();
        debugPrint("Seeded/Verified Firestore config/ai_config for DEV");
      } catch (e) {
        debugPrint("Could not seed AI config in DEV Firestore: $e");
      }
    }

    // Initialize App Check (Hybrid: Debug for local, Play Integrity for prod)
    try {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
      );
    } catch (e) {
      debugPrint("AppCheck activate error: $e");
    }
  } catch (e, stack) {
    debugPrint("Firebase init failed: $e");
    debugPrint("Stack trace: $stack");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: AppEnvironment.appName,
      theme: AppTheme.lightThemeMode,
      darkTheme: AppTheme.darkThemeMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (AppEnvironment.isDev) {
          return Banner(
            message: 'DEV',
            location: BannerLocation.topStart,
            color: Colors.red,
            child: child!,
          );
        }
        return child!;
      },
    );
  }
}
