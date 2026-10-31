
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import 'sari_api.dart';

class SariLiveData {
  SariLiveData._internal()
      : _api = SariApi(
          baseUrl: ApiConfig.apiBaseUrl,
          tokenProvider: () => _storage.read(
            key: 'sari_access_token',
          ),
        );

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static final SariLiveData instance =
      SariLiveData._internal();

  final SariApi _api;

  // Public Laravel API: GET /api/v1/health
  Future<SariJson> checkConnection() {
    return _api.health();
  }

  // Authenticated API: GET /api/v1/auth/me
  Future<SariJson> currentAccount() {
    return _api.me();
  }

  // Public Laravel API: GET /api/v1/products
  Future<SariJson> products({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String sort = 'newest',
  }) {
    return _api.products(
      page: page,
      perPage: perPage,
      search: search,
      category: category,
      sort: sort,
    );
  }

  // Public Laravel API: GET /api/v1/products/{id}
  Future<SariJson> productDetails(int id) {
    return _api.product(id);
  }

  // Buyer-only API: GET /api/v1/buyer/orders
  Future<SariJson> buyerOrders({
    int page = 1,
    int perPage = 15,
  }) {
    return _api.buyerOrders(
      page: page,
      perPage: perPage,
    );
  }

  // Buyer-only API: GET /api/v1/buyer/orders/{id}
  Future<SariJson> buyerOrderDetails(int id) {
    return _api.buyerOrder(id);
  }

  // Authenticated API: POST /api/v1/auth/logout
  Future<SariJson> logout() {
    return _api.logout();
  }

  // Authenticated API: POST /api/v1/auth/logout-all
  Future<SariJson> logoutAll() {
    return _api.logoutAll();
  }

  Future<bool> hasAccessToken() async {
    final token = await _storage.read(
      key: 'sari_access_token',
    );

    return token != null && token.trim().isNotEmpty;
  }

  Future<void> clearLocalAccessToken() async {
    await _storage.delete(
      key: 'sari_access_token',
    );
  }
}
