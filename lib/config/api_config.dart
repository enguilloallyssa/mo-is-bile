
class ApiConfig {
  const ApiConfig._();

  // Main Laravel server
  static const String baseUrl = String.fromEnvironment(
    'SARI_SERVER_URL',
    defaultValue: 'https://preview.sariph.store',
  );

  // Laravel REST API v1
  static const String apiBaseUrl = String.fromEnvironment(
    'SARI_API_URL',
    defaultValue: 'https://preview.sariph.store/api/v1',
  );
}
