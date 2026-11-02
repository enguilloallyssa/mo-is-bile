
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef SariJson = Map<String, dynamic>;
typedef SariTokenProvider = Future<String?> Function();

class SariApiException implements Exception {
  const SariApiException(
    this.message, {
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final SariJson? errors;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidationError => statusCode == 422;

  @override
  String toString() {
    if (statusCode == null) {
      return 'SariApiException: $message';
    }
    return 'SariApiException ($statusCode): $message';
  }
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

    if (parsed == null ||
        parsed.scheme != 'https' ||
        parsed.host.isEmpty) {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'Use a full HTTPS Laravel API base URL.',
      );
    }
  }

  final String baseUrl;
  final SariTokenProvider? tokenProvider;
  final Duration timeout;

  final http.Client _client;
  final bool _ownsClient;

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Future<SariJson> request(
    String method,
    String path, {
    Map<String, String>? query,
    SariJson? jsonBody,
    bool authenticated = true,
  }) async {
    final action = method.toUpperCase();

    if (!{
      'GET',
      'POST',
      'PUT',
      'PATCH',
      'DELETE',
    }.contains(action)) {
      throw ArgumentError.value(
        method,
        'method',
        'Unsupported HTTP method',
      );
    }

    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');

    if (cleanPath.isEmpty ||
        cleanPath.startsWith('http:') ||
        cleanPath.startsWith('https:') ||
        cleanPath.contains('..') ||
        cleanPath.contains('?') ||
        cleanPath.contains('#')) {
      throw ArgumentError.value(
        path,
        'path',
        'Use a relative endpoint path',
      );
    }

    final uri = Uri.parse('$baseUrl/$cleanPath').replace(
      queryParameters: query?.isNotEmpty == true ? query : null,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (authenticated) {
      final token =
          (await tokenProvider?.call())?.trim() ?? '';

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
      final stream =
          await _client.send(req).timeout(timeout);

      response = await http.Response.fromStream(stream)
          .timeout(timeout);
    } on TimeoutException {
      throw const SariApiException(
        'The request timed out. Please try again.',
      );
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
      final decoded = decodedText.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(decodedText);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'JSON response is not an object',
        );
      }

      data = decoded;
    } on FormatException {
      throw SariApiException(
        'Laravel returned a non-JSON response '
        '(HTTP ${response.statusCode}). '
        'Check that the API is deployed and the route exists.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final errors = data['errors'];

      throw SariApiException(
        data['message'] is String
            ? data['message'] as String
            : 'Request failed (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
        errors: errors is Map<String, dynamic>
            ? errors
            : null,
      );
    }

    return data;
  }

  // PUBLIC ENDPOINTS

  // GET /api/v1/health
  Future<SariJson> health() {
    return request(
      'GET',
      'health',
      authenticated: false,
    );
  }

  // POST /api/v1/auth/login
  Future<SariJson> login({
    required String role,
    required String email,
    required String password,
    required String deviceName,
  }) {
    if (!{
      'buyer',
      'seller',
      'rider',
      'logistics',
    }.contains(role)) {
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
        'role': role,
        'email': email.trim().toLowerCase(),
        'password': password,
        'device_name': deviceName,
      },
    );
  }

  // GET /api/v1/products
  Future<SariJson> products({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String sort = 'newest',
  }) {
    if (page < 1 || perPage < 1 || perPage > 30) {
      throw ArgumentError(
        'page must be >= 1; perPage must be 1–30',
      );
    }

    return request(
      'GET',
      'products',
      authenticated: false,
      query: {
        'page': '$page',
        'per_page': '$perPage',
        'sort': sort,
        if (search != null && search.trim().isNotEmpty)
          'q': search.trim(),
        if (category != null &&
            category.trim().isNotEmpty)
          'category': category.trim(),
      },
    );
  }

  // GET /api/v1/products/{id}
  Future<SariJson> product(int id) {
    if (id < 1) {
      throw ArgumentError.value(
        id,
        'id',
        'Invalid product ID',
      );
    }

    return request(
      'GET',
      'products/$id',
      authenticated: false,
    );
  }

  // AUTHENTICATED ENDPOINTS

  // GET /api/v1/auth/me
  Future<SariJson> me() {
    return request('GET', 'auth/me');
  }

  // POST /api/v1/auth/logout
  Future<SariJson> logout() {
    return request('POST', 'auth/logout');
  }

  // POST /api/v1/auth/logout-all
  Future<SariJson> logoutAll() {
    return request('POST', 'auth/logout-all');
  }

  // GET /api/v1/buyer/orders
  Future<SariJson> buyerOrders({
    int page = 1,
    int perPage = 15,
  }) {
    if (page < 1 || perPage < 1 || perPage > 30) {
      throw ArgumentError(
        'page must be >= 1; perPage must be 1–30',
      );
    }

    return request(
      'GET',
      'buyer/orders',
      query: {
        'page': '$page',
        'per_page': '$perPage',
      },
    );
  }

  // GET /api/v1/buyer/orders/{id}
  Future<SariJson> buyerOrder(int id) {
    if (id < 1) {
      throw ArgumentError.value(
        id,
        'id',
        'Invalid order ID',
      );
    }

    return request(
      'GET',
      'buyer/orders/$id',
    );
  }
}
