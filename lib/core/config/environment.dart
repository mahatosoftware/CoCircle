enum Flavor {
  dev,
  prod,
}

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
}
