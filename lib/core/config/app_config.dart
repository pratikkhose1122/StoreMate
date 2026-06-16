enum ApiEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  static late final ApiEnvironment _environment;
  
  /// Initialize the application environment.
  /// Must be called before `runApp`.
  static void init(ApiEnvironment env) {
    _environment = env;
  }

  static ApiEnvironment get environment => _environment;

  /// Returns the appropriate Base URL for the current environment.
  static String get baseUrl {
    switch (_environment) {
      case ApiEnvironment.development:
        // Local emulator (10.0.2.2) or local physical device IP
        return 'http://10.0.2.2:3000/api/v1';
      case ApiEnvironment.staging:
        // Replace with actual staging URL if deployed
        return 'https://storemate-api-staging.onrender.com/api/v1';
      case ApiEnvironment.production:
        // Replace with the actual Render URL once deployed
        return 'https://storemate-api.onrender.com/api/v1';
    }
  }
}
