import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import 'sari_api.dart';

class SariLiveData {
  SariLiveData._internal()
      : _api = SariApi(
          baseUrl: ApiConfig.apiBaseUrl,
          tokenProvider: () =>
              _storage.read(key: 'sari_access_token'),
        );

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static final SariLiveData instance =
      SariLiveData._internal();

  final SariApi _api;

  Future<SariJson> checkConnection() =>
      _api.health();

  Future<SariJson> currentAccount() =>
      _api.me();

  Future<SariJson> logout() =>
      _api.logout();

  Future<SariJson> logoutAll() =>
      _api.logoutAll();

  Future<bool> hasAccessToken() async =>
      (await _storage.read(
        key: 'sari_access_token',
      ))
          ?.trim()
          .isNotEmpty ==
      true;

  Future<void> clearLocalAccessToken() =>
      _storage.delete(
        key: 'sari_access_token',
      );

  Future<SariJson> products({
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
    String sort = 'newest',
  }) =>
      _api.products(
        page: page,
        perPage: perPage,
        search: search,
        category: category,
        sort: sort,
      );

  Future<SariJson> productDetails(int id) =>
      _api.product(id);

  // Buyer registration
  Future<SariJson> buyerRegister(
    Map<String, String> fields,
    File profileImage,
  ) =>
      _api.multipart(
        'POST',
        'registration/buyer',
        authenticated: false,
        fields: fields,
        files: {
          'profile_image': profileImage,
        },
      );

  Future<SariJson> buyerResendOtp(
    String email,
  ) =>
      _api.request(
        'POST',
        'registration/buyer/otp/resend',
        authenticated: false,
        jsonBody: {
          'email': email,
        },
      );

  Future<SariJson> buyerVerifyOtp(
    String email,
    String otp,
  ) =>
      _api.request(
        'POST',
        'registration/buyer/otp/verify',
        authenticated: false,
        jsonBody: {
          'email': email,
          'otp': otp,
        },
      );

  // Buyer orders/actions/tracking
  Future<SariJson> buyerOrders({
    int page = 1,
    int perPage = 15,
  }) =>
      _api.request(
        'GET',
        'buyer/orders',
        query: {
          'page': '$page',
          'per_page': '$perPage',
        },
      );

  Future<SariJson> buyerOrderDetails(
    int id,
  ) =>
      _api.request(
        'GET',
        'buyer/orders/$id',
      );

  Future<SariJson> buyerCancelOrder(
    int id,
    String reason,
  ) =>
      _api.request(
        'POST',
        'buyer/orders/$id/cancel',
        jsonBody: {
          'reason': reason,
        },
      );

  Future<SariJson> buyerReviewOrder(
    int id, {
    required int productId,
    required int rating,
    String? comment,
  }) =>
      _api.request(
        'POST',
        'buyer/orders/$id/reviews',
        jsonBody: {
          'product_id': productId,
          'rating': rating,
          if (comment?.trim().isNotEmpty == true)
            'comment': comment!.trim(),
        },
      );

  Future<SariJson> buyerTracking(
    int id,
  ) =>
      _api.request(
        'GET',
        'buyer/orders/$id/tracking',
      );

  // Buyer cart/checkout
  Future<SariJson> buyerCart() =>
      _api.request(
        'GET',
        'buyer/cart',
      );

  Future<SariJson> buyerCartSummary() =>
      _api.request(
        'GET',
        'buyer/cart/summary',
      );

  Future<SariJson> buyerAddCart({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) =>
      _api.request(
        'POST',
        'buyer/cart/items',
        jsonBody: {
          'product_id': productId,
          if (variantId != null)
            'variant_id': variantId,
          'quantity': quantity,
        },
      );

  Future<SariJson> buyerUpdateCart(
    int itemId,
    int quantity,
  ) =>
      _api.request(
        'PATCH',
        'buyer/cart/items/$itemId',
        jsonBody: {
          'quantity': quantity,
        },
      );

  Future<SariJson> buyerRemoveCart(
    int itemId,
  ) =>
      _api.request(
        'DELETE',
        'buyer/cart/items/$itemId',
      );

  Future<SariJson> buyerCheckoutPreview(
    List<int> itemIds,
  ) =>
      _api.request(
        'POST',
        'buyer/checkout/preview',
        jsonBody: {
          'item_ids': itemIds,
        },
      );

  Future<SariJson> buyerCheckout({
    required String name,
    required String email,
    required String phone,
    required String address,
    required List<int> itemIds,
    String? voucherCode,
  }) =>
      _api.request(
        'POST',
        'buyer/checkout',
        jsonBody: {
          'buyer_name': name,
          'buyer_email': email,
          'buyer_phone': phone,
          'buyer_address': address,
          'payment_method': 'COD',
          'checkout_item_ids': itemIds,
          if (voucherCode?.trim().isNotEmpty ==
              true)
            'voucher_code':
                voucherCode!.trim(),
        },
      );

  // Buyer profile/addresses
  Future<SariJson> buyerProfile() =>
      _api.request(
        'GET',
        'buyer/profile',
      );
      Future<SariJson> buyerUpdateProfileForm({
  required Map<String, String> fields,
  File? profileImage,
}) =>
    _api.multipart(
      'POST',
      'buyer/profile',
      fields: fields,
      files: profileImage == null
          ? null
          : {
              'profile_image': profileImage,
            },
    );

  Future<SariJson> buyerUpdateProfile(
    Map<String, dynamic> body,
  ) =>
      _api.request(
        'PATCH',
        'buyer/profile',
        jsonBody: body,
      );

  Future<SariJson> buyerUpdatePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) =>
      _api.request(
        'PATCH',
        'buyer/profile/password',
        jsonBody: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation':
              confirmation,
        },
      );

  Future<SariJson> buyerAddresses() =>
      _api.request(
        'GET',
        'buyer/addresses',
      );

  Future<SariJson> buyerStoreAddress(
    Map<String, dynamic> body,
  ) =>
      _api.request(
        'POST',
        'buyer/addresses',
        jsonBody: body,
      );

  Future<SariJson> buyerUpdateAddress(
    int id,
    Map<String, dynamic> body,
  ) =>
      _api.request(
        'PATCH',
        'buyer/addresses/$id',
        jsonBody: body,
      );

  Future<SariJson> buyerSetDefaultAddress(
    int id,
  ) =>
      _api.request(
        'POST',
        'buyer/addresses/$id/default',
      );

  Future<SariJson> buyerDeleteAddress(
    int id,
  ) =>
      _api.request(
        'DELETE',
        'buyer/addresses/$id',
      );

  // Buyer notifications/shipping/messages
Future<SariJson> buyerNotifications({
  int page = 1,
  int perPage = 20,
  bool archived = false,
}) =>
    _api.request(
      'GET',
      'buyer/notifications',
      query: {
        'page': '$page',
        'per_page': '$perPage',
        'archived':
            archived ? '1' : '0',
      },
    );

  Future<SariJson> buyerNotificationSummary() =>
      _api.request(
        'GET',
        'buyer/notifications/summary',
      );

  Future<SariJson> buyerReadNotification(
    int id,
  ) =>
      _api.request(
        'POST',
        'buyer/notifications/$id/read',
      );

  Future<SariJson> buyerReadAllNotifications() =>
      _api.request(
        'POST',
        'buyer/notifications/read-all',
      );

  Future<SariJson> buyerShipping({
    int page = 1,
  }) =>
      _api.request(
        'GET',
        'buyer/shipping',
        query: {
          'page': '$page',
        },
      );

  Future<SariJson> buyerMessages() =>
      _api.request(
        'GET',
        'buyer/messages',
      );

  Future<SariJson> buyerMessageThread(
    int sellerId,
  ) =>
      _api.request(
        'GET',
        'buyer/messages/$sellerId',
      );

  Future<SariJson> buyerSendMessage(
    int sellerId, {
    String? body,
    int? orderId,
    File? attachment,
  }) {
    if (attachment != null) {
      return _api.multipart(
        'POST',
        'buyer/messages/$sellerId',
        fields: {
          'body': body ?? '',
          if (orderId != null)
            'order_id': '$orderId',
        },
        files: {
          'attachment': attachment,
        },
      );
    }

    return _api.request(
      'POST',
      'buyer/messages/$sellerId',
      jsonBody: {
        'body': body ?? '',
        if (orderId != null)
          'order_id': orderId,
      },
    );
  }

  // Rider dashboard/assignments
  Future<SariJson> riderDashboard() =>
      _api.request(
        'GET',
        'rider/dashboard',
      );

  Future<SariJson> riderAssignments() =>
      _api.request(
        'GET',
        'rider/assignments',
      );

  Future<SariJson> riderPickups() =>
      _api.request(
        'GET',
        'rider/pickups',
      );

  Future<SariJson> riderDeliveries() =>
      _api.request(
        'GET',
        'rider/deliveries',
      );

  Future<SariJson> riderAssignment(
    int orderId,
  ) =>
      _api.request(
        'GET',
        'rider/assignments/$orderId',
      );

  Future<SariJson> riderProceedPickup(
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/orders/$orderId/proceed-pickup',
      );

  Future<SariJson> riderArrivedPickup(
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/orders/$orderId/arrived-pickup',
      );

  Future<SariJson> riderConfirmPickup(
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/orders/$orderId/confirm-pickup',
      );

  Future<SariJson> riderArrivedBuyer(
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/orders/$orderId/arrived-buyer',
      );

  Future<SariJson> riderComplete(
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/orders/$orderId/complete',
      );

  // Rider last mile/scanner/proof
  Future<SariJson> riderLastMile() =>
      _api.request(
        'GET',
        'rider/last-mile',
      );

  Future<SariJson> riderLastMileDetails(
    int assignmentId,
  ) =>
      _api.request(
        'GET',
        'rider/last-mile/$assignmentId',
      );

  Future<SariJson> riderStartLastMile(
    int assignmentId,
  ) =>
      _api.request(
        'POST',
        'rider/last-mile/$assignmentId/start',
      );

  Future<SariJson> riderLastMileArrived(
    int assignmentId,
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/last-mile/$assignmentId/orders/$orderId/arrived',
      );

  Future<SariJson> riderLastMileDelivered(
    int assignmentId,
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/last-mile/$assignmentId/orders/$orderId/delivered',
      );

  Future<SariJson> riderScanVerify(
    String payload,
  ) =>
      _api.request(
        'POST',
        'rider/scanner/verify',
        jsonBody: {
          'payload': payload,
        },
      );

  Future<SariJson> riderProof({
    required int orderId,
    required File photo,
    String? recipientName,
    String? notes,
    double? latitude,
    double? longitude,
  }) =>
      _api.multipart(
        'POST',
        'rider/orders/$orderId/proof',
        fields: {
          if (recipientName?.trim().isNotEmpty ==
              true)
            'recipient_name':
                recipientName!.trim(),
          if (notes?.trim().isNotEmpty ==
              true)
            'notes': notes!.trim(),
          if (latitude != null)
            'latitude': '$latitude',
          if (longitude != null)
            'longitude': '$longitude',
        },
        files: {
          'photo': photo,
        },
      );

  // Rider finance
  Future<SariJson> riderEarnings() =>
      _api.request(
        'GET',
        'rider/earnings',
      );

  Future<SariJson> riderTransactions({
    int page = 1,
    int perPage = 20,
  }) =>
      _api.request(
        'GET',
        'rider/earnings/transactions',
        query: {
          'page': '$page',
          'per_page': '$perPage',
        },
      );

  Future<SariJson> riderPayouts() =>
      _api.request(
        'GET',
        'rider/payouts',
      );

  Future<SariJson> riderRequestPayout({
    required double amount,
    required String method,
    required String accountName,
    required String accountReference,
  }) =>
      _api.request(
        'POST',
        'rider/payouts',
        jsonBody: {
          'amount': amount,
          'payout_method': method,
          'account_name': accountName,
          'account_reference':
              accountReference,
        },
      );

  Future<SariJson> riderEligibleRemittances() =>
      _api.request(
        'GET',
        'rider/remittances/eligible',
      );

  Future<SariJson> riderRemittances() =>
      _api.request(
        'GET',
        'rider/remittances',
      );

  Future<SariJson> riderRemittance(
    int id,
  ) =>
      _api.request(
        'GET',
        'rider/remittances/$id',
      );

  Future<SariJson> riderSubmitRemittance(
    List<int> orderIds, {
    int? facilityId,
    String? note,
  }) =>
      _api.request(
        'POST',
        'rider/remittances',
        jsonBody: {
          'order_ids': orderIds,
          if (facilityId != null)
            'logistics_facility_id': facilityId,
          if (note?.trim().isNotEmpty == true)
            'note': note!.trim(),
        },
      );

  Future<SariJson> riderHistory({
    String? query,
    String? from,
    String? to,
    int page = 1,
  }) =>
      _api.request(
        'GET',
        'rider/history',
        query: {
          'page': '$page',
          if (query?.trim().isNotEmpty == true)
            'q': query!.trim(),
          if (from?.trim().isNotEmpty == true)
            'date_from': from!,
          if (to?.trim().isNotEmpty == true)
            'date_to': to!,
        },
      );

  // Rider messages/profile
  Future<SariJson> riderMessages() =>
      _api.request(
        'GET',
        'rider/messages',
      );

  Future<SariJson> riderSendMessage(
    String body,
  ) =>
      _api.request(
        'POST',
        'rider/messages',
        jsonBody: {
          'body': body,
        },
      );

  Future<SariJson> riderProfile() =>
      _api.request(
        'GET',
        'rider/profile',
      );

  Future<SariJson> riderUpdateProfile(
    Map<String, dynamic> body,
  ) =>
      _api.request(
        'PATCH',
        'rider/profile',
        jsonBody: body,
      );

  Future<SariJson> riderAvailability(
    String status,
  ) =>
      _api.request(
        'PATCH',
        'rider/profile/availability',
        jsonBody: {
          'availability_status': status,
        },
      );

  Future<SariJson> riderUpdatePassword({
    required String currentPassword,
    required String password,
    required String confirmation,
  }) =>
      _api.request(
        'PATCH',
        'rider/profile/password',
        jsonBody: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation':
              confirmation,
        },
      );
}