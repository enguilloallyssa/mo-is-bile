
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

  // ==========================================
  // API CONNECTION
  // ==========================================

  // GET /api/v1/health
  Future<SariJson> checkConnection() {
    return _api.health();
  }

  // ==========================================
  // BUYER AUTHENTICATION
  // ==========================================

  // GET /api/v1/auth/me
  // Retrieves the logged-in account.
  Future<SariJson> currentAccount() {
    return _api.me();
  }

  // POST /api/v1/auth/logout
  Future<SariJson> logout() {
    return _api.logout();
  }

  // POST /api/v1/auth/logout-all
  Future<SariJson> logoutAll() {
    return _api.logoutAll();
  }

  // ==========================================
  // PRODUCTS - LARAVEL DATABASE
  // ==========================================

  // GET /api/v1/products
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

  // GET /api/v1/products/{id}
  Future<SariJson> productDetails(int id) {
    return _api.product(id);
  }

  // ==========================================
  // BUYER ORDERS - LARAVEL DATABASE
  // ==========================================

  // GET /api/v1/buyer/orders
  Future<SariJson> buyerOrders({
    int page = 1,
    int perPage = 15,
  }) {
    return _api.buyerOrders(
      page: page,
      perPage: perPage,
    );
  }

  // GET /api/v1/buyer/orders/{id}
  Future<SariJson> buyerOrderDetails(int id) {
    return _api.buyerOrder(id);
  }

  // ==========================================
  // SECURE AUTHENTICATION TOKEN
  // ==========================================

  Future<bool> hasAccessToken() async {
    final token = await _storage.read(
      key: 'sari_access_token',
    );

    return token != null &&
        token.trim().isNotEmpty;
  }

  Future<void> clearLocalAccessToken() async {
    await _storage.delete(
      key: 'sari_access_token',
    );
  }
}
