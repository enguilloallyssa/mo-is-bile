import 'dart:convert';

import 'package:file_picker/file_picker.dart';
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

  static final RegistrationApi instance =
      RegistrationApi._();

  final Map<String, String> _cookies =
      <String, String>{};

  String? _csrfToken;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    _cookies.clear();
    _csrfToken = null;

    final String token = await _loadCsrf('/login');

    final http.Request request = http.Request(
      'POST',
      _uri('/login'),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: '/login'),
      )
      ..bodyFields = <String, String>{
        '_token': token,
        'email': email,
        'password': password,
      };

    final http.Response response = await _send(request);

    if (_isRedirect(response.statusCode)) {
      final String location =
          response.headers['location'] ?? '';

      final String path =
          Uri.tryParse(location)?.path ?? location;

      if (path == '/buyer' ||
          path.startsWith('/buyer/')) {
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
          'Admin accounts must sign in through '
          'the SARI website.',
        );
      }

      final http.Response page = await _get('/login');

      throw RegistrationApiException(
        _extractPageMessage(page.body) ??
            'Incorrect email or password.',
      );
    }

    if (response.statusCode == 419) {
      throw const RegistrationApiException(
        'Your login session expired. Please try again.',
      );
    }

    _throwFor(response);
  }

  Future<List<Map<String, Object>>>
      loadRiderLogistics() async {
    final http.Response page =
        await _get('/register/rider');

    final List<Map<String, Object>> providers =
        <Map<String, Object>>[];

    final Iterable<RegExpMatch> cards = RegExp(
      r'<article[^>]*rider-provider-card[^>]*>([\s\S]*?)</article>',
      caseSensitive: false,
    ).allMatches(page.body);

    for (final RegExpMatch card in cards) {
      final String html = card.group(1)!;

      final RegExpMatch? href = RegExp(
        r'href=["\x27][^"\x27]*/register/rider/(\d+)["\x27]',
        caseSensitive: false,
      ).firstMatch(html);

      final RegExpMatch? heading = RegExp(
        r'<h3[^>]*>([\s\S]*?)</h3>',
        caseSensitive: false,
      ).firstMatch(html);

      final List<RegExpMatch> paragraphs = RegExp(
        r'<p[^>]*>([\s\S]*?)</p>',
        caseSensitive: false,
      ).allMatches(html).toList();

      if (href == null || heading == null) {
        continue;
      }

      providers.add(<String, Object>{
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

  Future<void> registerBuyer({
    required Map<String, String> fields,
    required PlatformFile profileImage,
  }) async {
    if (profileImage.path == null) {
      throw const RegistrationApiException(
        'The selected photo cannot be read.',
      );
    }

    final String path = '/register/buyer';
    final String token = await _loadCsrf(path);

    final http.MultipartRequest request =
        http.MultipartRequest(
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
          ..fields.addAll(<String, String>{
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

    final http.Response response = await _send(request);

    if (_isRedirect(response.statusCode)) {
      final String location =
          response.headers['location'] ?? '';

      final String redirectPath =
          Uri.tryParse(location)?.path ?? location;

      if (redirectPath ==
              '/registration/pending' ||
          redirectPath.startsWith(
            '/registration/pending/',
          )) {
        return;
      }

      final http.Response page = await _get(path);

      final String? message =
          _extractPageMessage(page.body);

      if (message != null &&
          !message
              .toLowerCase()
              .contains('registration saved') &&
          !message
              .toLowerCase()
              .contains('verification code sent')) {
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

  Future<String> sendOtp({
    required String email,
    required String role,
  }) async {
    final Map<String, dynamic> result =
        await _registrationAction(
      <String, String>{
        '_registration_action': 'otp_send',
        'email': email,
        'role': role,
      },
    );

    return result['message']?.toString() ??
        'Verification code sent.';
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String role,
    required String otp,
  }) {
    return _registrationAction(
      <String, String>{
        '_registration_action': 'otp_verify',
        'email': email,
        'role': role,
        'otp': otp,
      },
    );
  }

  Future<String> sendRiderOtp({
    required int logisticsId,
    required String email,
  }) async {
    final String pagePath =
        '/register/rider/$logisticsId';

    final String token = await _loadCsrf(pagePath);

    final http.Request request = http.Request(
      'POST',
      _uri('$pagePath/email/send'),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: pagePath),
      )
      ..bodyFields = <String, String>{
        '_token': token,
        'email': email,
      };

    final http.Response response =
        await _send(request);

    if (!_isRedirect(response.statusCode) &&
        (response.statusCode < 200 ||
            response.statusCode >= 300)) {
      _throwFor(response);
    }

    final http.Response page =
        await _get(pagePath);

    final String? message =
        _extractPageMessage(page.body);

    if (message != null &&
        !message.toLowerCase().contains('code sent') &&
        !message
            .toLowerCase()
            .contains('verification code')) {
      throw RegistrationApiException(message);
    }

    return message ?? 'Verification code sent.';
  }

  Future<void> verifyRiderOtp({
    required int logisticsId,
    required String email,
    required String otp,
  }) async {
    final String pagePath =
        '/register/rider/$logisticsId';

    final String token =
        _csrfToken ?? await _loadCsrf(pagePath);

    final http.Request request = http.Request(
      'POST',
      _uri('$pagePath/email/verify'),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: pagePath),
      )
      ..bodyFields = <String, String>{
        '_token': token,
        'email': email,
        'otp': otp,
      };

    final http.Response response =
        await _send(request);

    if (!_isRedirect(response.statusCode) &&
        (response.statusCode < 200 ||
            response.statusCode >= 300)) {
      _throwFor(response);
    }

    final http.Response page =
        await _get(pagePath);

    final String? message =
        _extractPageMessage(page.body);

    if (message != null) {
      final String lowerMessage =
          message.toLowerCase();

      if (lowerMessage.contains('incorrect') ||
          lowerMessage.contains('request a new') ||
          lowerMessage.contains('expired') ||
          lowerMessage.contains('invalid')) {
        throw RegistrationApiException(message);
      }
    }
  }

  Future<void> registerRider({
    required int logisticsId,
    required Map<String, String> fields,
    required PlatformFile profileImage,
    required PlatformFile idDocument,
    required PlatformFile orcrDocument,
  }) async {
    for (final PlatformFile file
        in <PlatformFile>[
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

    final String path =
        '/register/rider/$logisticsId';

    final String token =
        _csrfToken ?? await _loadCsrf(path);

    final http.MultipartRequest request =
        http.MultipartRequest(
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
          ..fields.addAll(<String, String>{
            ...fields,
            '_token': token,
          })
          ..files.addAll(
            <http.MultipartFile>[
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
            ],
          );

    final http.Response response =
        await _send(request);

    if (_isRedirect(response.statusCode)) {
      final String location =
          response.headers['location'] ?? '';

      final String redirectPath =
          Uri.tryParse(location)?.path ?? location;

      if (redirectPath ==
              '/registration/pending' ||
          redirectPath.startsWith(
            '/registration/pending/',
          )) {
        return;
      }

      final http.Response page = await _get(path);

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

  Future<void> logout(String role) async {
    final String path;

    if (role == 'rider') {
      path = '/courier/logout';
    } else if (role == 'logistics') {
      path = '/logistics/logout';
    } else {
      path = '/buyer/logout';
    }

    final String token =
        _csrfToken ?? await _loadCsrf('/login');

    final http.Request request = http.Request(
      'POST',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: path),
      )
      ..bodyFields = <String, String>{
        '_token': token,
      };

    await _send(request);

    _cookies.clear();
    _csrfToken = null;
  }

  Future<Map<String, dynamic>>
      _registrationAction(
    Map<String, String> fields,
  ) async {
    const String path = '/register/buyer';

    final String token =
        _csrfToken ?? await _loadCsrf(path);

    final http.Request request = http.Request(
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
      ..bodyFields = <String, String>{
        ...fields,
        '_token': token,
      };

    final http.Response response =
        await _send(request);

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return _json(response.body);
    }

    if (_isRedirect(response.statusCode)) {
      final http.Response page = await _get(path);

      final String? message =
          _extractPageMessage(page.body);

      if (message != null) {
        throw RegistrationApiException(message);
      }

      return <String, dynamic>{
        'message': 'Verification action completed.',
      };
    }

    _throwFor(response);
  }

  Future<String> _loadCsrf(String path) async {
    final String separator =
        path.contains('?') ? '&' : '?';

    final String freshPath =
        '$path${separator}_mobile_csrf='
        '${DateTime.now().millisecondsSinceEpoch}';

    final http.Response page = await _get(
      freshPath,
      referer: path,
    );

    final RegExpMatch? match = RegExp(
      r'name=["\x27]_token["\x27][^>]*value=["\x27]([^"\x27]+)',
      caseSensitive: false,
    ).firstMatch(page.body);

    if (match == null) {
      throw const RegistrationApiException(
        'Laravel CSRF token was not found. '
        'Check whether the login page is accessible.',
      );
    }

    _csrfToken = match.group(1)!;

    return _csrfToken!;
  }

  Future<http.Response> _get(
    String path, {
    String? referer,
  }) async {
    final http.Request request = http.Request(
      'GET',
      _uri(path),
    )
      ..followRedirects = false
      ..headers.addAll(
        _headers(referer: referer),
      );

    http.Response response = await _send(request);

    int redirectCount = 0;

    while (_isRedirect(response.statusCode) &&
        redirectCount < 5) {
      final String? location =
          response.headers['location'];

      if (location == null ||
          location.isEmpty) {
        break;
      }

      final Uri redirectUri =
          _resolveLocation(location);

      if (!_isAllowedHost(redirectUri)) {
        throw const RegistrationApiException(
          'The SARI server redirected to '
          'an unexpected website.',
        );
      }

      final http.Request redirectRequest =
          http.Request(
        'GET',
        redirectUri,
      )
            ..followRedirects = false
            ..headers.addAll(
              _headers(referer: path),
            );

      response = await _send(redirectRequest);
      redirectCount++;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 400) {
      return response;
    }

    _throwFor(response);
  }

  Future<http.Response> _send(
    http.BaseRequest request,
  ) async {
    final http.StreamedResponse streamedResponse =
        await request.send();

    _rememberCookies(streamedResponse.headers);

    return http.Response.fromStream(
      streamedResponse,
    );
  }

  Uri _uri(String path) {
    final Uri parsed = Uri.parse(path);

    if (parsed.hasScheme) {
      return parsed;
    }

    return Uri.parse(ApiConfig.baseUrl)
        .resolve(path);
  }

  Map<String, String> _headers({
    String? referer,
    bool acceptJson = false,
  }) {
    final String? xsrfCookie =
        _cookies['XSRF-TOKEN'];

    return <String, String>{
      'Accept': acceptJson
          ? 'application/json'
          : 'text/html,application/xhtml+xml',
      'Cache-Control': 'no-cache, no-store',
      'Pragma': 'no-cache',
      'User-Agent': 'SARI-Mobile/1.0',
      'Origin': ApiConfig.baseUrl,
      if (_cookies.isNotEmpty)
        'Cookie': _cookies.entries
            .map(
              (MapEntry<String, String> cookie) =>
                  '${cookie.key}=${cookie.value}',
            )
            .join('; '),
      if (xsrfCookie != null &&
          xsrfCookie.isNotEmpty)
        'X-XSRF-TOKEN':
            _decodeCookie(xsrfCookie),
      if (referer != null)
        'Referer': _absoluteUrl(referer),
    };
  }

  void _rememberCookies(
    Map<String, String> headers,
  ) {
    String? rawCookies;

    for (final MapEntry<String, String> header
        in headers.entries) {
      if (header.key.toLowerCase() ==
          'set-cookie') {
        rawCookies = header.value;
        break;
      }
    }

    if (rawCookies == null ||
        rawCookies.trim().isEmpty) {
      return;
    }

    for (final String cookieName
        in const <String>[
      'XSRF-TOKEN',
      'laravel_session',
    ]) {
      final RegExp pattern = RegExp(
        '(?:^|,\\s*)'
        '${RegExp.escape(cookieName)}'
        '=([^;,\\s]+)',
        caseSensitive: false,
      );

      final RegExpMatch? match =
          pattern.firstMatch(rawCookies);

      if (match != null) {
        _cookies[cookieName] =
            match.group(1)!;
      }
    }
  }

  bool _isRedirect(int statusCode) {
    return statusCode == 301 ||
        statusCode == 302 ||
        statusCode == 303 ||
        statusCode == 307 ||
        statusCode == 308;
  }

  Uri _resolveLocation(String location) {
    final Uri parsed = Uri.parse(location);

    if (parsed.hasScheme) {
      return parsed;
    }

    return Uri.parse(ApiConfig.baseUrl)
        .resolve(location);
  }

  bool _isAllowedHost(Uri uri) {
    final Uri base = Uri.parse(ApiConfig.baseUrl);

    return uri.scheme == base.scheme &&
        uri.host == base.host &&
        uri.port == base.port;
  }

  String _absoluteUrl(String path) {
    final Uri parsed = Uri.parse(path);

    if (parsed.hasScheme) {
      return parsed.toString();
    }

    return Uri.parse(ApiConfig.baseUrl)
        .resolve(path)
        .toString();
  }

  String _decodeCookie(String value) {
    try {
      return Uri.decodeComponent(value);
    } catch (_) {
      return value;
    }
  }

  String? _extractPageMessage(String html) {
    final List<RegExp> patterns = <RegExp>[
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

    for (final RegExp pattern in patterns) {
      final RegExpMatch? match =
          pattern.firstMatch(html);

      if (match == null) {
        continue;
      }

      final String text =
          _plainText(match.group(1)!);

      if (text.isNotEmpty) {
        return text;
      }
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
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map<String, dynamic>(
        (dynamic key, dynamic value) =>
            MapEntry<String, dynamic>(
          key.toString(),
          value,
        ),
      );
    }

    return <String, dynamic>{};
  }

  Never _throwFor(http.Response response) {
    if (response.statusCode == 419) {
      throw const RegistrationApiException(
        'Your SARI session expired. '
        'Please try again.',
      );
    }

    if (response.statusCode == 401) {
      throw const RegistrationApiException(
        'Incorrect email or password.',
      );
    }

    if (response.statusCode == 403) {
      throw const RegistrationApiException(
        'This account is not allowed to '
        'perform that action.',
      );
    }

    if (response.statusCode >= 500) {
      throw RegistrationApiException(
        'SARI server error '
        '(${response.statusCode}). '
        'Please try again later.',
      );
    }

    try {
      final Map<String, dynamic> body =
          _json(response.body);

      final dynamic errors = body['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final dynamic firstError =
            errors.values.first;

        if (firstError is List &&
            firstError.isNotEmpty) {
          throw RegistrationApiException(
            firstError.first.toString(),
          );
        }

        if (firstError != null) {
          throw RegistrationApiException(
            firstError.toString(),
          );
        }
      }

      throw RegistrationApiException(
        body['message']?.toString() ??
            'Unable to connect to SARI '
                '(status ${response.statusCode}).',
      );
    } on RegistrationApiException {
      rethrow;
    } catch (_) {
      final String? pageMessage =
          _extractPageMessage(response.body);

      throw RegistrationApiException(
        pageMessage ??
            'Server error '
                '(${response.statusCode}). '
                'Check the Laravel URL.',
      );
    }
  }
}