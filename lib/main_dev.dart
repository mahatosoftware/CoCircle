import 'core/config/app_bootstrap.dart';
import 'core/config/environment.dart';

/// Dedicated development entry point for CoCircle (Dev).
/// Build/run with:
/// `flutter run --flavor dev -t lib/main_dev.dart`
void main() async {
  await AppBootstrap.run(Flavor.dev);
}
