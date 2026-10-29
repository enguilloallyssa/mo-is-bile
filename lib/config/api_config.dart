class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'SARI_SERVER_URL',
    defaultValue: 'https://preview.sariph.store',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'SARI_API_URL',
    defaultValue: 'https://preview.sariph.store/api/v1',
  );
}