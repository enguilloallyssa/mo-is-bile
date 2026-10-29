import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  const ApiService._();

  static Future<String> testConnection() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.apiBaseUrl}/ping'),
          headers: const {
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'API connection failed: ${response.statusCode}',
      );
    }

    final Object? decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid API response.');
    }

    return decoded['message']?.toString() ??
        'Connection successful';
  }
}