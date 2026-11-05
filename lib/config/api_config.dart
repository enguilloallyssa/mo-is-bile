class ApiConfig {
  const ApiConfig._();

  // Main Laravel server.
  // Ginagamit ito para sa non-API resources tulad ng images
  // at ilang address/public resources.
  static const String baseUrl = String.fromEnvironment(
    'SARI_SERVER_URL',
    defaultValue: 'https://preview.sariph.store',
  );

  // Laravel REST API v1.
  // Lahat ng Buyer/Rider mobile API requests dapat dito dumaan.
  static const String apiBaseUrl = String.fromEnvironment(
    'SARI_API_URL',
    defaultValue: 'https://preview.sariph.store/api/v1',
  );
}