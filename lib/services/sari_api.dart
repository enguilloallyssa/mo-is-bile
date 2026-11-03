import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      ? message
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
        _ownsClient = client == null;

  final String baseUrl;
  final SariTokenProvider? tokenProvider;
  final Duration timeout;
  final http.Client _client;
  final bool _ownsClient;

  void dispose() {
    if (_ownsClient) _client.close();
  }

  Future<Map<String, String>> _headers({
    required bool authenticated,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

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

    return headers;
  }

  Uri _uri(
    String path, [
    Map<String, String>? query,
  ]) {
    final cleanPath = path.replaceFirst(RegExp(r'^/+'), '');

    if (cleanPath.isEmpty || cleanPath.contains('..')) {
      throw ArgumentError.value(
        path,
        'path',
        'Invalid API path',
      );
    }

    return Uri.parse('$baseUrl/$cleanPath').replace(
      queryParameters:
          query?.isNotEmpty == true ? query : null,
    );
  }

  SariJson _decode(http.Response response) {
    dynamic decoded;

    try {
      decoded = response.body.trim().isEmpty
          ? <String, dynamic>{}
          : jsonDecode(
              utf8.decode(response.bodyBytes),
            );
    } catch (_) {
      throw SariApiException(
        'Laravel returned a non-JSON response.',
        statusCode: response.statusCode,
      );
    }

    final data = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{
            'data': decoded,
          };

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final rawErrors = data['errors'];

      throw SariApiException(
        data['message']?.toString() ?? 'Request failed.',
        statusCode: response.statusCode,
        errors: rawErrors is Map<String, dynamic>
            ? rawErrors
            : null,
      );
    }

    return data;
  }

  Future<SariJson> request(
    String method,
    String path, {
    Map<String, String>? query,
    SariJson? jsonBody,
    bool authenticated = true,
  }) async {
    final uri = _uri(path, query);

    final headers = await _headers(
      authenticated: authenticated,
    );

    headers['Content-Type'] = 'application/json';

    final body =
        jsonBody == null ? null : jsonEncode(jsonBody);

    late http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client
              .get(
                uri,
                headers: headers,
              )
              .timeout(timeout);
          break;

        case 'POST':
          response = await _client
              .post(
                uri,
                headers: headers,
                body: body,
              )
              .timeout(timeout);
          break;

        case 'PATCH':
          response = await _client
              .patch(
                uri,
                headers: headers,
                body: body,
              )
              .timeout(timeout);
          break;

        case 'DELETE':
          response = await _client
              .delete(
                uri,
                headers: headers,
                body: body,
              )
              .timeout(timeout);
          break;

        default:
          throw ArgumentError.value(
            method,
            'method',
            'Unsupported HTTP method',
          );
      }
    } on TimeoutException {
      throw const SariApiException(
        'The request timed out. Please try again.',
      );
    } on http.ClientException {
      throw const SariApiException(
        'Unable to connect to SARI.',
      );
    }

    return _decode(response);
  }

  Future<SariJson> multipart(
    String method,
    String path, {
    Map<String, String>? fields,
    Map<String, File>? files,
    bool authenticated = true,
  }) async {
    final request = http.MultipartRequest(
      method.toUpperCase(),
      _uri(path),
    );

    request.headers.addAll(
      await _headers(
        authenticated: authenticated,
      ),
    );

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (files != null) {
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ),
        );
      }
    }

    try {
      final streamed = await _client
          .send(request)
          .timeout(timeout);

      final response =
          await http.Response.fromStream(streamed)
              .timeout(timeout);

      return _decode(response);
    } on TimeoutException {
      throw const SariApiException(
        'The upload timed out. Please try again.',
      );
    } on http.ClientException {
      throw const SariApiException(
        'Unable to connect to SARI.',
      );
    }
  }

  Future<SariJson> health() => request(
        'GET',
        'health',
        authenticated: false,
      );

  Future<SariJson> login({
    required String role,
    required String email,
    required String password,
    required String deviceName,
  }) =>
      request(
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

  Future<SariJson> me() =>
      request('GET', 'auth/me');

  Future<SariJson> logout() =>
      request('POST', 'auth/logout');

  Future<SariJson> logoutAll() =>
      request('POST', 'auth/logout-all');

  Future<SariJson> products({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String sort = 'newest',
  }) =>
      request(
        'GET',
        'products',
        authenticated: false,
        query: {
          'page': '$page',
          'per_page': '$perPage',
          'sort': sort,
          if (search != null &&
              search.trim().isNotEmpty)
            'q': search.trim(),
          if (category != null &&
              category.trim().isNotEmpty)
            'category': category.trim(),
        },
      );

  Future<SariJson> product(int id) =>
      request(
        'GET',
        'products/$id',
        authenticated: false,
      );
}