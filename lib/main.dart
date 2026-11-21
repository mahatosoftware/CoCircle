import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_bootstrap.dart';
import 'core/config/environment.dart';
import 'core/theme/app_theme.dart';
import 'router.dart';
import 'package:cocircle/l10n/app_localizations.dart';
import 'package:cocircle/core/services/push_notification_service.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';

void main() async {
  final flavor = AppEnvironment.resolveFlavor(appFlavor: appFlavor);
  await AppBootstrap.run(flavor);
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      final user = ref.read(authStateChangesProvider).value;
      PushNotificationService().initialize(
        router: router,
        currentUserId: user?.uid,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateChangesProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        PushNotificationService().syncDeviceToken(user.uid);
      } else if (previous?.value != null) {
        PushNotificationService().removeDeviceToken(previous!.value!.uid);
      }
    });

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
