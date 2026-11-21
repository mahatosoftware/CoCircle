import 'core/config/app_bootstrap.dart';
import 'core/config/environment.dart';

/// Dedicated production entry point for CoCircle.
/// Build with:
/// `flutter build apk --flavor prod -t lib/main_prod.dart --dart-define=APP_ENV=prod`
/// or
/// `flutter build appbundle --flavor prod -t lib/main_prod.dart --dart-define=APP_ENV=prod`
void main() async {
  await AppBootstrap.run(Flavor.prod);
}
