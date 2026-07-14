enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableMockAuth,
    required this.googleClientId,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final bool enableMockAuth;
  final String googleClientId;

  static const current = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8000/v1',
    ),
    enableMockAuth: bool.fromEnvironment(
      'ENABLE_MOCK_AUTH',
      defaultValue: true,
    ),
    googleClientId: '420312656061-mto4j2k3h3g59d6bq5ick4u6kbb1vv2h.apps.googleusercontent.com',
  );
}

