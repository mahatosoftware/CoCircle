enum Flavor {
  dev,
  prod,
}

const String environment = String.fromEnvironment('APP_ENV', defaultValue: '');
bool get isProduction => environment == 'prod';

class AppEnvironment {
  static late Flavor flavor;
  static late String packageName;
  static late String appName;
  static late String googleServerClientId;
  static String? databaseUrl;

  static void setup({
    required Flavor flavor,
    required String packageName,
    required String appName,
    required String googleServerClientId,
    String? defaultDatabaseUrl,
  }) {
    AppEnvironment.flavor = flavor;
    AppEnvironment.packageName = packageName;
    AppEnvironment.appName = appName;
    AppEnvironment.googleServerClientId = googleServerClientId;
    AppEnvironment.databaseUrl = defaultDatabaseUrl;
  }

  static bool get isDev => flavor == Flavor.dev;
  static bool get isProd => flavor == Flavor.prod;

  /// Resolves flavor using compile-time defines and Flutter CLI arguments
  /// without fragile runtime package inspection.
  static Flavor resolveFlavor({String? appFlavor}) {
    if (environment.toLowerCase() == 'prod' || appFlavor?.toLowerCase() == 'prod') {
      return Flavor.prod;
    }
    return Flavor.dev;
  }
}
