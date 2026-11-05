import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class RegistrationApiException
    implements Exception {
  final String message;

  const RegistrationApiException(
    this.message,
  );

  @override
  String toString() => message;
}

/// Stateless mobile registration client.
///
/// Lahat ng active Buyer at Rider registration
/// ay Laravel `/api/v1` na.
///
/// Walang:
/// - browser cookies
/// - CSRF token
/// - HTML scraping
/// - web session dependency
class RegistrationApi {
  RegistrationApi._();

  static final RegistrationApi instance =
      RegistrationApi._();

  static const Duration _timeout =
      Duration(
    seconds: 30,
  );

  // ============================================================
  // URI
  // ============================================================

  Uri _apiUri(
    String path,
  ) {
    final String base =
        ApiConfig.apiBaseUrl.replaceFirst(
      RegExp(r'/+$'),
      '',
    );

    final String clean =
        path.replaceFirst(
      RegExp(r'^/+'),
      '',
    );

    return Uri.parse(
      '$base/$clean',
    );
  }

  // ============================================================
  // HEADERS
  // ============================================================

  Map<String, String> _headers() {
    return const <String, String>{
      'Accept': 'application/json',
      'Cache-Control': 'no-cache, no-store',
      'Pragma': 'no-cache',
      'User-Agent': 'SARI-Mobile/1.0',
    };
  }

  // ============================================================
  // SEND REQUEST
  // ============================================================

  Future<http.Response> _send(
    http.BaseRequest request,
  ) async {
    try {
      final http.StreamedResponse streamed =
          await request
              .send()
              .timeout(
                _timeout,
              );

      return http.Response.fromStream(
        streamed,
      );
    } on TimeoutException {
      throw const RegistrationApiException(
        'The SARI server took too long to respond. Please try again.',
      );
    } on RegistrationApiException {
      rethrow;
    } catch (_) {
      throw const RegistrationApiException(
        'Cannot connect to the SARI server. Check your internet connection.',
      );
    }
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> _json(
    String body,
  ) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final dynamic decoded =
          jsonDecode(body);

      if (decoded
          is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map<String, dynamic>(
          (
            dynamic key,
            dynamic value,
          ) {
            return MapEntry<String, dynamic>(
              key.toString(),
              value,
            );
          },
        );
      }
    } catch (_) {
      // Central error handling below.
    }

    return <String, dynamic>{};
  }

  // ============================================================
  // ERROR MAPPER
  // ============================================================

  Never _throwFor(
    http.Response response,
  ) {
    final Map<String, dynamic> body =
        _json(
      response.body,
    );

    final dynamic errors =
        body['errors'];

    if (errors is Map &&
        errors.isNotEmpty) {
      final dynamic first =
          errors.values.first;

      if (first is List &&
          first.isNotEmpty) {
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

    if (response.statusCode == 429) {
      throw RegistrationApiException(
        body['message']?.toString() ??
            'Too many requests. Please wait before trying again.',
      );
    }

    if (response.statusCode >= 500) {
      throw RegistrationApiException(
        body['message']?.toString() ??
            'SARI server error (${response.statusCode}). Please try again later.',
      );
    }

    throw RegistrationApiException(
      body['message']?.toString() ??
          'SARI request failed (HTTP ${response.statusCode}).',
    );
  }

  // ============================================================
  // FORM POST
  // ============================================================

  Future<http.Response> _postForm(
    String path,
    Map<String, String> fields,
  ) async {
    final http.Request request =
        http.Request(
      'POST',
      _apiUri(path),
    )
          ..headers.addAll(
            _headers(),
          )
          ..bodyFields = fields;

    return _send(
      request,
    );
  }

  // ============================================================
  // BUYER REGISTRATION
  // ============================================================

  Future<void> registerBuyer({
    required Map<String, String> fields,
    required PlatformFile profileImage,
  }) async {
    if (profileImage.path == null) {
      throw const RegistrationApiException(
        'The selected photo cannot be read.',
      );
    }

    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      _apiUri(
        'registration/buyer',
      ),
    )
          ..headers.addAll(
            _headers(),
          )
          ..fields.addAll(
            fields,
          )
          ..files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              profileImage.path!,
              filename:
                  profileImage.name,
            ),
          );

    final http.Response response =
        await _send(
      request,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }
  }

  // ============================================================
  // BUYER OTP
  // ============================================================

  Future<String> sendOtp({
    required String email,
    required String role,
  }) async {
    if (role.toLowerCase() !=
        'buyer') {
      throw const RegistrationApiException(
        'This verification action is only available for Buyer registration.',
      );
    }

    final http.Response response =
        await _postForm(
      'registration/buyer/otp/resend',
      <String, String>{
        'email': email,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }

    final Map<String, dynamic> result =
        _json(
      response.body,
    );

    return result['message']
            ?.toString() ??
        'Verification code sent.';
  }

  Future<Map<String, dynamic>>
      verifyOtp({
    required String email,
    required String role,
    required String otp,
  }) async {
    if (role.toLowerCase() !=
        'buyer') {
      throw const RegistrationApiException(
        'This verification action is only available for Buyer registration.',
      );
    }

    final http.Response response =
        await _postForm(
      'registration/buyer/otp/verify',
      <String, String>{
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }

    return _json(
      response.body,
    );
  }

  // ============================================================
  // RIDER PROVIDERS
  // ============================================================

  Future<List<Map<String, Object>>>
      loadRiderLogistics() async {
    final http.Request request =
        http.Request(
      'GET',
      _apiUri(
        'registration/rider/providers',
      ),
    )..headers.addAll(
            _headers(),
          );

    final http.Response response =
        await _send(
      request,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }

    final dynamic data =
        _json(
      response.body,
    )['data'];

    if (data is! List) {
      return <Map<String, Object>>[];
    }

    return data
        .whereType<Map>()
        .map(
          (
            dynamic raw,
          ) {
            final Map<dynamic, dynamic>
                item =
                raw
                    as Map<dynamic,
                        dynamic>;

            return <String, Object>{
              'id': int.tryParse(
                    '${item['id']}',
                  ) ??
                  0,

              'name': item['name']
                      ?.toString() ??
                  'SARI Logistics',

              'location':
                  item['location']
                          ?.toString() ??
                      '',

              'coverage':
                  item['coverage']
                          ?.toString() ??
                      '',

              'approvedRiders':
                  int.tryParse(
                        '${item['approvedRiders'] ?? 0}',
                      ) ??
                      0,
            };
          },
        )
        .toList();
  }

  // ============================================================
  // RIDER OTP
  // ============================================================

  Future<String> sendRiderOtp({
    required int logisticsId,
    required String email,
  }) async {
    final http.Response response =
        await _postForm(
      'registration/rider/$logisticsId/otp/send',
      <String, String>{
        'email': email,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }

    final Map<String, dynamic> result =
        _json(
      response.body,
    );

    return result['message']
            ?.toString() ??
        'Verification code sent.';
  }

  Future<void> verifyRiderOtp({
    required int logisticsId,
    required String email,
    required String otp,
  }) async {
    final http.Response response =
        await _postForm(
      'registration/rider/$logisticsId/otp/verify',
      <String, String>{
        'email': email,
        'otp': otp,
      },
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }
  }

  // ============================================================
  // RIDER APPLICATION
  // ============================================================

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

    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      _apiUri(
        'registration/rider/$logisticsId',
      ),
    )
          ..headers.addAll(
            _headers(),
          )
          ..fields.addAll(
            fields,
          )
          ..files.addAll(
            <http.MultipartFile>[
              await http.MultipartFile
                  .fromPath(
                'profile_image',
                profileImage.path!,
                filename:
                    profileImage.name,
              ),

              await http.MultipartFile
                  .fromPath(
                'id_document',
                idDocument.path!,
                filename:
                    idDocument.name,
              ),

              await http.MultipartFile
                  .fromPath(
                'orcr_document',
                orcrDocument.path!,
                filename:
                    orcrDocument.name,
              ),
            ],
          );

    final http.Response response =
        await _send(
      request,
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      _throwFor(
        response,
      );
    }
  }
}