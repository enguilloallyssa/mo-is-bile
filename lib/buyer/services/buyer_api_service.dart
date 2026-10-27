import 'dart:convert';

import 'package:http/http.dart' as http;

class BuyerApiException implements Exception {
  final String message;
  final int? statusCode;

  const BuyerApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class BuyerApiService {
  final String baseUrl;
  final Future<String?> Function()? tokenProvider;
  final http.Client _client;

  BuyerApiService({
    required this.baseUrl,
    this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) {
    return _request('GET', path, query: query);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _request('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _request('DELETE', path, body: body);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final relative = path.startsWith('/') ? path.substring(1) : path;
    var uri = Uri.parse(base).resolve(relative);

    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }

    final token = await tokenProvider?.call();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    late final http.Response response;
    final encodedBody = body == null ? null : jsonEncode(body);

    try {
      switch (method) {
        case 'POST':
          response = await _client.post(uri, headers: headers, body: encodedBody);
          break;
        case 'PATCH':
          response = await _client.patch(uri, headers: headers, body: encodedBody);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers, body: encodedBody);
          break;
        default:
          response = await _client.get(uri, headers: headers);
      }
    } on Exception {
      throw const BuyerApiException(
        'Unable to connect. Check your internet connection and try again.',
      );
    }

    dynamic decoded;
    if (response.body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw BuyerApiException(
          'The server returned an invalid response.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final serverMessage = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw BuyerApiException(
        serverMessage ?? 'Request failed. Please try again.',
        statusCode: response.statusCode,
      );
    }

    if (decoded == null) return <String, dynamic>{};
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  void close() => _client.close();
}
