
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class RegistrationApiException implements Exception {
  final String message;

  const RegistrationApiException(this.message);

  @override
  String toString() => message;
}

class RegistrationApi {
  RegistrationApi._();

  static final RegistrationApi instance = RegistrationApi._();

  final Map<String, String> _cookies = {};
  String? _csrfToken;

  Uri _uri(String path) {
    final uri = Uri.parse(path);

    if (uri.hasScheme) return uri;

    return Uri.parse(ApiConfig.baseUrl).resolve(path);
  }

  String _absoluteUrl(String path) => _uri(path).toString();

  bool _isRedirect(int code) =>
      code == 301 ||
      code == 302 ||
      code == 303 ||
      code == 307 ||
      code == 308;

  bool _isAllowedHost(Uri uri) {
    final base = Uri.parse(ApiConfig.baseUrl);

    return uri.scheme == base.scheme &&
        uri.host == base.host &&
        uri.port == base.port;
  }

  String _decodeCookie(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }

  Map<String, String> _headers({
    String? referer,
    bool acceptJson = false,
  }) {
    final xsrfCookie = _cookies['XSRF-TOKEN'];

    return {
      'Accept': acceptJson
          ? 'application/json'
          : 'text/html,application/xhtml+xml',
      'Cache-Control': 'no-cache, no-store',
      'Pragma': 'no-cache',
      'User-Agent': 'SARI-Mobile/1.0',
      'Origin': ApiConfig.baseUrl,
      if (_cookies.isNotEmpty)
        'Cookie': _cookies.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('; '),
      if (xsrfCookie != null && xsrfCookie.isNotEmpty)
        'X-XSRF-TOKEN': _decodeCookie(xsrfCookie),
      if (referer != null)
        'Referer': _absoluteUrl(referer),
    };
  }

  void _rememberCookies(Map<String, String> headers) {
    String? raw;

    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == 'set-cookie') {
        raw = entry.value;
        break;
      }
    }

    if (raw == null || raw.isEmpty) return;

    // Multiple Set-Cookie headers can be combined by
    // the HTTP client. Match only actual cookie names.
    for (final name in ['laravel_session', 'XSRF-TOKEN']) {
      final match = RegExp(
        '(?:^|,\\s*)${RegExp.escape(name)}=([^;,\\s]*)',
        caseSensitive: false,
      ).firstMatch(raw);

      if (match == null) continue;

      final value = match.group(1) ?? '';

      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  Future<http.Response> _send(
    http.BaseRequest request,
  ) async {
    // Only diagnostic booleans and status codes.
    // Never print cookies, tokens, passwords, OTP,
    // submitted fields, or response bodies.

    final cookieHeader = request.headers['Cookie'] ?? '';

    final hasSession =
        cookieHeader.contains('laravel_session=');

    final hasXsrf =
        cookieHeader.contains('XSRF-TOKEN=');

    final hasFormToken = request is http.Request
        ? request.bodyFields.containsKey('_token')
        : request is http.MultipartRequest
            ? request.fields.containsKey('_token')
            : false;

    if (kDebugMode) {
      debugPrint('Registration method: ${request.method}');
      debugPrint(
        'Registration URL path: ${request.url.path}',
      );
      debugPrint(
        'Registration session cookie included: $hasSession',
      );
      debugPrint(
        'Registration XSRF cookie included: $hasXsrf',
      );
      debugPrint(
        'Registration CSRF form token included: $hasFormToken',
      );
    }

    final streamed = await request.send();

    final setCookie =
        streamed.headers['set-cookie'] ?? '';

    if (kDebugMode) {
      debugPrint(
        'Registration HTTP status: ${streamed.statusCode}',
      );
      debugPrint(
        'Registration server issued session cookie: '
        '${setCookie.contains('laravel_session=')}',
      );
      debugPrint(
        'Registration server issued XSRF cookie: '
        '${setCookie.contains('XSRF-TOKEN=')}',
      );

      if (_isRedirect(streamed.statusCode)) {
        final location = streamed.headers['location'];

        debugPrint(
          'Registration redirect path: '
          '${location == null ? 'none' : Uri.tryParse(location)?.path ?? 'unknown'}',
        );
      }
    }

    _rememberCookies(streamed.headers);

    return http.Response.fromStream(streamed);
  }

  Future<http.Response> _get(
    String path, {
    String? referer,
  }) async {
    final request = http.Request('GET', _uri(path))
      ..followRedirects = false
      ..headers.addAll(_headers(referer: referer));

    var response = await _send(request);
    var redirects = 0;

    while (_isRedirect(response.statusCode) &&
        redirects < 5) {
      final location = response.headers['location'];

      if (location == null || location.isEmpty) break;

      final redirectUri = _uri(location);

      if (!_isAllowedHost(redirectUri)) {
        throw const RegistrationApiException(
          'SARI redirected to an unexpected website.',
        );
      }

      final next = http.Request('GET', redirectUri)
        ..followRedirects = false
        ..headers.addAll(_headers(referer: path));

      response = await _send(next);
      redirects++;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 400) {
      return response;
    }

    _throwFor(response);
  }

  Future<String> _loadCsrf(String path) async {
    final separator = path.contains('?') ? '&' : '?';

    final freshPath =
        '$path${separator}_mobile_csrf='
        '${DateTime.now().millisecondsSinceEpoch}';

    final page = await _get(
      freshPath,
      referer: path,
    );

    final match = RegExp(
      r'name=["\x27]_token["\x27][^>]*value=["\x27]([^"\x27]+)',
      caseSensitive: false,
    ).firstMatch(page.body);

    if (match == null) {
      throw const RegistrationApiException(
        'Laravel CSRF token was not found '
        'on the registration page.',
      );
    }

    _csrfToken = match.group(1)!;

    return _csrfToken!;
  }

  String? _extractPageMessage(String html) {
    final patterns = [
      RegExp(
        r'<[^>]*class=["\x27][^"\x27]*(?:alert-danger|invalid-feedback|text-danger)[^"\x27]*["\x27][^>]*>([\s\S]*?)</[^>]+>',
        caseSensitive: false,
      ),
      RegExp(
        r'<li[^>]*>([\s\S]*?)</li>',
        caseSensitive: false,
      ),
      RegExp(
        r'<[^>]*class=["\x27][^"\x27]*alert-success[^"\x27]*["\x27][^>]*>([\s\S]*?)</[^>]+>',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(html);

      if (match == null) continue;

      final message = _plainText(match.group(1)!);

      if (message.isNotEmpty) return message;
    }

    return null;
  }

  String _plainText(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Map<String, dynamic> _json(String body) {
    if (body.trim().isEmpty) return {};

    final decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return {};
  }

  Never _throwFor(http.Response response) {
    if (response.statusCode == 419) {
      // Do not automatically retry registration POST.
      _csrfToken = null;
      _cookies.clear();

      throw const RegistrationApiException(
        'Registration session or CSRF validation '
        'failed (HTTP 419). Please return to '
        'registration and try again.',
      );
    }

    if (response.statusCode == 401) {
      throw const RegistrationApiException(
        'Incorrect email or password.',
      );
    }

    if (response.statusCode == 403) {
      throw const RegistrationApiException(
        'This account is not allowed to perform '
        'that action.',
      );
    }

    if (response.statusCode >= 500) {
      throw RegistrationApiException(
        'SARI server error (${response.statusCode}). '
        'Please try again later.',
      );
    }

    try {
      final body = _json(response.body);
      final errors = body['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;

        if (first is List && first.isNotEmpty) {
          throw RegistrationApiException(
            first.first.toString(),
          );
        }

        if (first != null) {
          throw RegistrationApiException(
            first.toString(),
          );
        }
      }

      throw RegistrationApiException(
        body['message']?.toString() ??
            'SARI request failed '
                '(HTTP ${response.statusCode}).',
      );
    } on RegistrationApiException {
      rethrow;
    } catch (_) {
      throw RegistrationApiException(
        _extractPageMessage(response.body) ??
            'SARI request failed '
                '(HTTP ${response.statusCode}).',
      );
    }
  }

  // =================================================
  // LOGIN
  // =================================================

  Future<String> login({
    required String email,
    required String password,
  }) async {
    _cookies.clear();
    _csrfToken = null;

    final token = await _loadCsrf('/login');

    final request = http.Request(
      'POST',
      _uri('/login'),
    )
      ..followRedirects = false
      ..headers.addAll(_headers(referer: '/login'))
      ..bodyFields = {
        '_token': token,
        'email': email,
        'password': password,
      };

    final response = await _send(request);

    if (_isRedirect(response.statusCode)) {
      final location = response.headers['location'] ?? '';
      final path = Uri.tryParse(location)?.path ?? location;

      if (path == '/buyer' || path.startsWith('/buyer/')) {
        return 'buyer';
      }

      if (path == '/courier' ||
          path.startsWith('/courier/')) {
        return 'rider';
      }

      if (path == '/logistics' ||
          path.startsWith('/logistics/')) {
        return 'logistics';
      }

      if (path == '/seller' ||
          path.startsWith('/seller/')) {
        throw const RegistrationApiException(
          'Seller mobile pages are not included yet. '
          'Please use the SARI website.',
        );
      }

      if (path == '/admin' ||
          path.startsWith('/admin/')) {
        throw const RegistrationApiException(
          'Admin accounts must sign in '
          'through the SARI website.',
        );
      }

      final page = await _get('/login');

      throw RegistrationApiException(
        _extractPageMessage(page.body) ??
            'Incorrect email or password.',
      );
    }

    _throwFor(response);
  }

  // =================================================
  // BUYER REGISTRATION
  // =================================================

  Future<void> registerBuyer({
    required Map<String, String> fields,
    required PlatformFile profileImage,
  }) async {
    if (profileImage.path == null) {
      throw const RegistrationApiException(
        'The selected photo cannot be read.',
      );
    }

    const path = '/register/buyer';
    final token = await _loadCsrf(path);

    final request = http.MultipartRequest(
      'POST',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(
          referer: path,
          acceptJson: true,
        ),
      )
      ..fields.addAll({
        ...fields,
        '_token': token,
      })
      ..files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path!,
          filename: profileImage.name,
        ),
      );

    final response = await _send(request);

    if (_isRedirect(response.statusCode)) {
      final location = response.headers['location'] ?? '';
      final redirectPath =
          Uri.tryParse(location)?.path ?? location;

      if (redirectPath == '/registration/pending' ||
          redirectPath.startsWith(
            '/registration/pending/',
          )) {
        return;
      }

      final page = await _get(path);
      final message = _extractPageMessage(page.body);

      if (message != null &&
          !message.toLowerCase().contains(
            'registration saved',
          ) &&
          !message.toLowerCase().contains(
            'verification code sent',
          )) {
        throw RegistrationApiException(message);
      }

      return;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    _throwFor(response);
  }

  // =================================================
  // BUYER OTP
  // =================================================

  Future<Map<String, dynamic>> _registrationAction(
    Map<String, String> fields,
  ) async {
    const path = '/register/buyer';

    final token = _csrfToken ?? await _loadCsrf(path);

    final request = http.Request(
      'POST',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(
          referer: path,
          acceptJson: true,
        ),
      )
      ..bodyFields = {
        ...fields,
        '_token': token,
      };

    final response = await _send(request);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return _json(response.body);
    }

    if (_isRedirect(response.statusCode)) {
      final page = await _get(path);
      final message = _extractPageMessage(page.body);

      if (message != null) {
        throw RegistrationApiException(message);
      }

      return {
        'message': 'Verification action completed.',
      };
    }

    _throwFor(response);
  }

  Future<String> sendOtp({
    required String email,
    required String role,
  }) async {
    final result = await _registrationAction({
      '_registration_action': 'otp_send',
      'email': email,
      'role': role,
    });

    return result['message']?.toString() ??
        'Verification code sent.';
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String role,
    required String otp,
  }) {
    return _registrationAction({
      '_registration_action': 'otp_verify',
      'email': email,
      'role': role,
      'otp': otp,
    });
  }

  // =================================================
  // RIDER LOGISTICS PROVIDERS
  // =================================================

  Future<List<Map<String, Object>>>
      loadRiderLogistics() async {
    final page = await _get('/register/rider');

    final providers = <Map<String, Object>>[];

    final cards = RegExp(
      r'<article[^>]*rider-provider-card[^>]*>([\s\S]*?)</article>',
      caseSensitive: false,
    ).allMatches(page.body);

    for (final card in cards) {
      final html = card.group(1)!;

      final href = RegExp(
        r'href=["\x27][^"\x27]*/register/rider/(\d+)["\x27]',
        caseSensitive: false,
      ).firstMatch(html);

      final heading = RegExp(
        r'<h3[^>]*>([\s\S]*?)</h3>',
        caseSensitive: false,
      ).firstMatch(html);

      final paragraphs = RegExp(
        r'<p[^>]*>([\s\S]*?)</p>',
        caseSensitive: false,
      ).allMatches(html).toList();

      if (href == null || heading == null) continue;

      providers.add({
        'id': int.parse(href.group(1)!),
        'name': _plainText(heading.group(1)!),
        'location': paragraphs.isNotEmpty
            ? _plainText(paragraphs.first.group(1)!)
            : 'SARI Logistics network',
        'coverage': paragraphs.length > 4
            ? _plainText(paragraphs[4].group(1)!)
            : 'Philippines',
        'approvedRiders': paragraphs.length > 2
            ? int.tryParse(
                  _plainText(
                    paragraphs[2].group(1)!,
                  ).replaceAll(',', ''),
                ) ??
                0
            : 0,
      });
    }

    return providers;
  }

  // =================================================
  // RIDER OTP
  // =================================================

  Future<String> sendRiderOtp({
    required int logisticsId,
    required String email,
  }) async {
    final pagePath = '/register/rider/$logisticsId';
    final token = await _loadCsrf(pagePath);

    final request = http.Request(
      'POST',
      _uri('$pagePath/email/send'),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: pagePath),
      )
      ..bodyFields = {
        '_token': token,
        'email': email,
      };

    final response = await _send(request);

    if (!_isRedirect(response.statusCode) &&
        (response.statusCode < 200 ||
            response.statusCode >= 300)) {
      _throwFor(response);
    }

    final page = await _get(pagePath);
    final message = _extractPageMessage(page.body);

    if (message != null &&
        !message.toLowerCase().contains('code sent') &&
        !message.toLowerCase().contains(
          'verification code',
        )) {
      throw RegistrationApiException(message);
    }

    return message ?? 'Verification code sent.';
  }

  Future<void> verifyRiderOtp({
    required int logisticsId,
    required String email,
    required String otp,
  }) async {
    final pagePath = '/register/rider/$logisticsId';
    final token =
        _csrfToken ?? await _loadCsrf(pagePath);

    final request = http.Request(
      'POST',
      _uri('$pagePath/email/verify'),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: pagePath),
      )
      ..bodyFields = {
        '_token': token,
        'email': email,
        'otp': otp,
      };

    final response = await _send(request);

    if (!_isRedirect(response.statusCode) &&
        (response.statusCode < 200 ||
            response.statusCode >= 300)) {
      _throwFor(response);
    }

    final page = await _get(pagePath);
    final message = _extractPageMessage(page.body);

    if (message != null) {
      final lower = message.toLowerCase();

      if (lower.contains('incorrect') ||
          lower.contains('request a new') ||
          lower.contains('expired') ||
          lower.contains('invalid')) {
        throw RegistrationApiException(message);
      }
    }
  }

  // =================================================
  // RIDER REGISTRATION
  // =================================================

  Future<void> registerRider({
    required int logisticsId,
    required Map<String, String> fields,
    required PlatformFile profileImage,
    required PlatformFile idDocument,
    required PlatformFile orcrDocument,
  }) async {
    for (final file in [
      profileImage,
      idDocument,
      orcrDocument,
    ]) {
      if (file.path == null) {
        throw const RegistrationApiException(
          'One selected file cannot be read.',
        );
      }
    }

    final path = '/register/rider/$logisticsId';
    final token =
        _csrfToken ?? await _loadCsrf(path);

    final request = http.MultipartRequest(
      'POST',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(
          referer: path,
          acceptJson: true,
        ),
      )
      ..fields.addAll({
        ...fields,
        '_token': token,
      })
      ..files.addAll([
        await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path!,
          filename: profileImage.name,
        ),
        await http.MultipartFile.fromPath(
          'id_document',
          idDocument.path!,
          filename: idDocument.name,
        ),
        await http.MultipartFile.fromPath(
          'orcr_document',
          orcrDocument.path!,
          filename: orcrDocument.name,
        ),
      ]);

    final response = await _send(request);

    if (_isRedirect(response.statusCode)) {
      final location = response.headers['location'] ?? '';
      final pathAfterRedirect =
          Uri.tryParse(location)?.path ?? location;

      if (pathAfterRedirect ==
              '/registration/pending' ||
          pathAfterRedirect.startsWith(
            '/registration/pending/',
          )) {
        return;
      }

      final page = await _get(path);

      throw RegistrationApiException(
        _extractPageMessage(page.body) ??
            'Rider registration was not submitted.',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    _throwFor(response);
  }

  // =================================================
  // WEB SESSION LOGOUT
  // =================================================

  Future<void> logout(String role) async {
    final String path;

    if (role == 'rider') {
      path = '/courier/logout';
    } else if (role == 'logistics') {
      path = '/logistics/logout';
    } else {
      path = '/buyer/logout';
    }

    final token =
        _csrfToken ?? await _loadCsrf('/login');

    final request = http.Request(
      'POST',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(_headers(referer: path))
      ..bodyFields = {
        '_token': token,
      };

    final response = await _send(request);

    if (response.statusCode >= 400) {
      _throwFor(response);
    }

    _cookies.clear();
    _csrfToken = null;
  }
}
