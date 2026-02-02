import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/config/environment.dart';
import 'router.dart';
import 'firebase_options_prod.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Default to PROD if running main.dart directly
  AppEnvironment.setup(
    flavor: Flavor.prod,
    packageName: 'in.mahato.cocircle',
    appName: 'CoCircle',
    googleServerClientId: '273341956-u3ub04qtsebrfs3e7ge17p1dj36af1ea.apps.googleusercontent.com',
  );

  // Initialize Firebase
  try {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );

     // Initialize App Check (Hybrid: Debug for local, Play Integrity for prod)
     await FirebaseAppCheck.instance.activate(
       androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
       appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
     );
  } catch(e, stack) {
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
