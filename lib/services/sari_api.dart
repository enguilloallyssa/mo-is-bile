// SARI Flutter API client — single-file handoff for the implemented Laravel API v1.
//
// Destination in the Flutter project: lib/services/sari_api.dart
// Install the HTTP dependency: flutter pub add http
//
// IMPORTANT:
//   1. This file is a CLIENT. It does not create server routes or connect directly
//      to MySQL. Deploy the SARI_Flutter_Laravel_API_Starter Laravel package first.
//   2. The staging address below works ONLY once that Laravel API is deployed.
//   3. Store access tokens using OS secure storage (e.g. flutter_secure_storage).
//      Never embed a password, token or database credentials in your app code.
//   4. Available now: health, login, me, logout, logout-all, product list/detail,
//      buyer order list/detail. Cart, checkout, chat, rider delivery, logistics
//      operations, etc. are NOT implemented in API v1 starter. Do not call them
//      until the Laravel backend adds and documents those endpoints.
//
// Example usage:
//   final api = SariApi(
//     baseUrl: 'https://preview.sariph.store/api/v1',
//     tokenProvider: () async => secureStorage.read(key: 'sari_access_token'),
//   );
//   final status = await api.health();
//   final login = await api.login(
//     role: 'buyer', email: email, password: password,
//     deviceName: 'Android Phone',
//   );
//   // Persist login['data']['access_token'] in the OS secure storage.
//   // The tokenProvider supplies it on subsequent authenticated requests.
//   final products = await api.products(page: 1);
//   final orders = await api.buyerOrders();
//   api.dispose();

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef SariJson = Map<String, dynamic>;
typedef SariTokenProvider = Future<String?> Function();

class SariApiException implements Exception {
  const SariApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final SariJson? errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidationError => statusCode == 422;

  @override
  String toString() => statusCode == null
      ? 'SariApiException: $message'
      : 'SariApiException ($statusCode): $message';
}

class SariApi {
  SariApi({
    required String baseUrl,
    this.tokenProvider,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  })  : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
        _client = client ?? http.Client(),
        _ownsClient = client == null {
    final parsed = Uri.tryParse(this.baseUrl);
    if (parsed == null || parsed.scheme != 'https' || parsed.host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Use a full HTTPS Laravel API base URL, e.g. https://example.com/api/v1',
      );
    }
  }

  /// Example after deployment: https://preview.sariph.store/api/v1
  final String baseUrl;

  /// Return the current device token from OS-backed secure storage.
  /// Public requests work without this callback.
  final SariTokenProvider? tokenProvider;

  final Duration timeout;
  final http.Client _client;
  final bool _ownsClient;

  /// Close the HTTP client only if this class created it.
  void dispose() {
    if (_ownsClient) _client.close();
  }

  /// Generic helper for API endpoints implemented later by your Laravel team.
  /// Passing a path does NOT make an unimplemented endpoint available.
  Future<SariJson> request(
    String method,
    String path, {
    Map<String, String>? query,
    SariJson? jsonBody,
    bool authenticated = true,
  }) async {
    final action = method.toUpperCase();
    if (!{'GET', 'POST', 'PUT', 'PATCH', 'DELETE'}.contains(action)) {
      throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }

    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');
    if (cleanPath.isEmpty ||
        cleanPath.startsWith('http:') ||
        cleanPath.startsWith('https:') ||
        cleanPath.contains('..') ||
        cleanPath.contains('?') ||
        cleanPath.contains('#')) {
      throw ArgumentError.value(path, 'path', 'Use a relative endpoint path');
    }

    final uri = Uri.parse('$baseUrl/$cleanPath').replace(
      queryParameters: query?.isNotEmpty == true ? query : null,
    );

    final headers = <String, String>{'Accept': 'application/json'};

    if (authenticated) {
      final token = (await tokenProvider?.call())?.trim() ?? '';
      if (token.isEmpty) {
        throw const SariApiException(
          'Login required: no mobile access token is available.',
          statusCode: 401,
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final req = http.Request(action, uri);
    req.headers.addAll(headers);
    if (jsonBody != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(jsonBody);
    }

    late final http.Response response;
    try {
      final stream = await _client.send(req).timeout(timeout);
      response = await http.Response.fromStream(stream).timeout(timeout);
    } on TimeoutException {
      throw const SariApiException('The request timed out. Please try again.');
    } on http.ClientException {
      throw const SariApiException(
        'Unable to connect to SARI. Check your internet connection and API URL.',
      );
    }

    final String decodedText;
    try {
      decodedText = utf8.decode(response.bodyBytes);
    } on FormatException {
      throw SariApiException(
        'Server response was not valid UTF-8.',
        statusCode: response.statusCode,
      );
    }

    SariJson data;
    try {
      final decoded = decodedText.trim().isEmpty ? <String, dynamic>{} : jsonDecode(decodedText);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('JSON response is not an object');
      }
      data = decoded;
    } on FormatException {
      throw SariApiException(
        'Laravel returned a non-JSON response (HTTP ${response.statusCode}). '
        'Check that the API is deployed and the route exists.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errors = data['errors'];
      throw SariApiException(
        data['message'] is String
            ? data['message'] as String
            : 'Request failed (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
        errors: errors is Map<String, dynamic> ? errors : null,
      );
    }
    return data;
  }

  // ─── Public endpoints ──────────────────────────────────────────────────

  /// GET /health — confirm the Laravel API is reachable.
  Future<SariJson> health() => request('GET', 'health', authenticated: false);

  /// POST /auth/login — role is buyer, seller, rider, or logistics.
  /// The server returns data.access_token; store it securely in Flutter.
Future<SariJson> login({
  required String role,
  required String email,
  required String password,
  required String deviceName,
}) {
  if (!{'buyer', 'seller', 'rider', 'logistics'}.contains(role)) {
    throw ArgumentError.value(
      role,
      'role',
      'Invalid SARI login role',
    );
  }

  return request(
    'POST',
    'auth/login',
    authenticated: false,
    jsonBody: {
      'account_type': role,
      'email': email.trim().toLowerCase(),
      'password': password,
      'device_name': deviceName,
    },
  );
}

  /// GET /products — public, paginated marketplace catalog.
  Future<SariJson> products({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String sort = 'newest',
  }) {
    if (page < 1 || perPage < 1 || perPage > 30) {
      throw ArgumentError('page must be >= 1; perPage must be 1–30');
    }
    return request('GET', 'products', authenticated: false, query: {
      'page': '$page',
      'per_page': '$perPage',
      'sort': sort,
      if (search != null && search.trim().isNotEmpty) 'q': search.trim(),
      if (category != null && category.trim().isNotEmpty)
        'category': category.trim(),
    });
  }

  /// GET /products/{id} — only buyer-visible products can be fetched.
  Future<SariJson> product(int id) {
    if (id < 1) throw ArgumentError.value(id, 'id', 'Invalid product ID');
    return request('GET', 'products/$id', authenticated: false);
  }

  // ─── Authenticated endpoints ───────────────────────────────────────────

  /// GET /auth/me — current role and account profile.
  Future<SariJson> me() => request('GET', 'auth/me');

  /// POST /auth/logout — revoke the token for this device.
  /// After successful logout, remove the token from secure storage too.
  Future<SariJson> logout() => request('POST', 'auth/logout');

  /// POST /auth/logout-all — revoke all SARI mobile tokens for this account.
  Future<SariJson> logoutAll() => request('POST', 'auth/logout-all');

  /// GET /buyer/orders — requires a buyer mobile token.
  Future<SariJson> buyerOrders({int page = 1, int perPage = 15}) {
    if (page < 1 || perPage < 1 || perPage > 30) {
      throw ArgumentError('page must be >= 1; perPage must be 1–30');
    }
    return request('GET', 'buyer/orders', query: {
      'page': '$page',
      'per_page': '$perPage',
    });
  }

  /// GET /buyer/orders/{id} — only orders belonging to the buyer.
  Future<SariJson> buyerOrder(int id) {
    if (id < 1) throw ArgumentError.value(id, 'id', 'Invalid order ID');
    return request('GET', 'buyer/orders/$id');
  }
}
