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

  // ============================================================
  // SHARED / AUTH
  // ============================================================

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

  // ============================================================
  // PRODUCTS
  // ============================================================

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

  // ============================================================
  // BUYER REGISTRATION
  // ============================================================

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

  // ============================================================
  // BUYER ORDERS
  // ============================================================

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

  // ============================================================
  // BUYER CART / CHECKOUT
  // ============================================================

  /// Read-only Buyer wallet and COD history from Laravel.
  /// Wallet payment/withdrawal is intentionally not supported by the API.
  Future<SariJson> buyerWallet() =>
      _api.request('GET', 'buyer/wallet');

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
          if (voucherCode?.trim().isNotEmpty == true)
            'voucher_code': voucherCode!.trim(),
        },
      );

  // ============================================================
  // BUYER PROFILE
  // ============================================================

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

  // ============================================================
  // BUYER ADDRESSES
  // ============================================================

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

  // ============================================================
  // BUYER NOTIFICATIONS
  // ============================================================

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
          'archived': archived ? '1' : '0',
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

  // ============================================================
  // BUYER SHIPPING
  // ============================================================

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

  // ============================================================
  // BUYER MESSAGES
  // ============================================================

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

  // ============================================================
  // RIDER DASHBOARD / ASSIGNMENTS
  // ============================================================

  Future<SariJson> riderDashboard({
    Duration? timeout,
  }) =>
      _api.request(
        'GET',
        'rider/dashboard',
        requestTimeout: timeout,
      );

  Future<SariJson> riderAssignments({
    Duration? timeout,
  }) =>
      _api.request(
        'GET',
        'rider/assignments',
        requestTimeout: timeout,
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

  // ============================================================
  // RIDER PICKUP FLOW
  // ============================================================

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

  // ============================================================
  // RIDER DIRECT DELIVERY FLOW
  // ============================================================

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

  // ============================================================
  // RIDER LAST MILE
  // ============================================================

  Future<SariJson> riderLastMile() =>
      _api.request(
        'GET',
        'rider/last-mile',
        requestTimeout:
            const Duration(seconds: 12),
      );

  Future<SariJson> riderLastMileDetails(
    int assignmentId,
  ) =>
      _api.request(
        'GET',
        'rider/last-mile/$assignmentId',
        requestTimeout:
            const Duration(seconds: 12),
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
        'rider/last-mile/'
        '$assignmentId/orders/$orderId/arrived',
      );

  Future<SariJson> riderLastMileDelivered(
    int assignmentId,
    int orderId,
  ) =>
      _api.request(
        'POST',
        'rider/last-mile/'
        '$assignmentId/orders/$orderId/delivered',
      );

  // ============================================================
  // RIDER SCANNER / QR
  // ============================================================

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

  Future<SariJson> riderConfirmCodCash({
    required int orderId,
    required String paymentToken,
  }) =>
      _api.request(
        'POST',
        'rider/scanner/confirm-cod',
        jsonBody: {
          'order_id': orderId,
          'payment_token': paymentToken,
          'cash_received': true,
        },
      );

  // ============================================================
  // RIDER PROOF OF DELIVERY
  // ============================================================

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
          if (notes?.trim().isNotEmpty == true)
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

  // ============================================================
  // RIDER EARNINGS
  // ============================================================

  Future<SariJson> riderEarnings() =>
      _api.request(
        'GET',
        'rider/earnings',
        requestTimeout:
            const Duration(seconds: 12),
      );

  Future<SariJson> riderTransactions({
    int page = 1,
    int perPage = 20,
  }) =>
      _api.request(
        'GET',
        'rider/earnings/transactions',
        requestTimeout:
            const Duration(seconds: 12),
        query: {
          'page': '$page',
          'per_page': '$perPage',
        },
      );

  // ============================================================
  // RIDER PAYOUTS
  // ============================================================

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

  // ============================================================
  // RIDER COD REMITTANCE
  // ============================================================

  Future<SariJson> riderRemittanceHubs() =>
      _api.request(
        'GET',
        'rider/remittances/hubs',
        requestTimeout:
            const Duration(seconds: 9),
      );

  Future<SariJson> riderEligibleRemittances() =>
      _api.request(
        'GET',
        'rider/remittances/eligible',
        requestTimeout:
            const Duration(seconds: 12),
      );

  Future<SariJson> riderRemittances() =>
      _api.request(
        'GET',
        'rider/remittances',
        requestTimeout:
            const Duration(seconds: 12),
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
            'logistics_facility_id':
                facilityId,
          if (note?.trim().isNotEmpty == true)
            'note': note!.trim(),
        },
      );

  // ============================================================
  // RIDER HISTORY
  // ============================================================

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

  // ============================================================
  // RIDER NOTIFICATIONS
  // ============================================================

  Future<SariJson> riderNotifications() =>
      _api.request(
        'GET',
        'rider/notifications',
        requestTimeout:
            const Duration(seconds: 12),
      );

  Future<SariJson> riderNotificationSummary() =>
      _api.request(
        'GET',
        'rider/notifications/summary',
        requestTimeout:
            const Duration(seconds: 12),
      );

  Future<SariJson> riderReadNotification(
    int id,
  ) =>
      _api.request(
        'POST',
        'rider/notifications/$id/read',
      );

  Future<SariJson> riderReadAllNotifications() =>
      _api.request(
        'POST',
        'rider/notifications/read-all',
      );

  // ============================================================
  // RIDER MESSAGES
  // ============================================================

  Future<SariJson> riderMessages() =>
      _api.request(
        'GET',
        'rider/messages',
        requestTimeout:
            const Duration(seconds: 12),
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

  // ============================================================
  // RIDER PROFILE
  // ============================================================

  Future<SariJson> riderProfile({
    Duration? timeout,
  }) =>
      _api.request(
        'GET',
        'rider/profile',
        requestTimeout: timeout,
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
          'current_password':
              currentPassword,
          'password': password,
          'password_confirmation':
              confirmation,
        },
      );

  // ============================================================
  // MOBILE LOGISTICS — authenticated, branch-scoped API
  // ============================================================

  Future<SariJson> logisticsDashboard() => _api.request('GET', 'logistics/dashboard');
  Future<SariJson> logisticsProfile() => _api.request('GET', 'logistics/profile');
  Future<SariJson> logisticsBranches() => _api.request('GET', 'logistics/branches');
  Future<SariJson> logisticsIncoming(int facilityId) => _api.request('GET', 'logistics/incoming', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsSorting(int facilityId) => _api.request('GET', 'logistics/sorting', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsPickupRequests(int facilityId) => _api.request('GET', 'logistics/pickups', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsVerifyPickups(int facilityId, List<int> orderIds) => _api.request('POST', 'logistics/pickups/verify', jsonBody: {'facility_id':facilityId,'order_ids':orderIds});
  Future<SariJson> logisticsAssignPickup(int facilityId, int riderId, List<int> orderIds) => _api.request('POST', 'logistics/pickups/assign', jsonBody: {'facility_id':facilityId,'rider_id':riderId,'order_ids':orderIds});
  Future<SariJson> logisticsLastMile(int facilityId) => _api.request('GET', 'logistics/last-mile', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsAssignLastMile(int facilityId, int riderId, List<int> orderIds) => _api.request('POST', 'logistics/last-mile/assign', jsonBody: {'facility_id':facilityId,'rider_id':riderId,'order_ids':orderIds});
  Future<SariJson> logisticsMonitoring(String search) => _api.request('GET', 'logistics/monitoring', query: {'q':search});
  Future<SariJson> logisticsScanVerify(String code, int facilityId) => _api.request('POST', 'logistics/scanner/verify', jsonBody: {'payload':code,'facility_id':facilityId});
  Future<SariJson> logisticsReceive(int parcelId, int facilityId, {String? notes}) => _api.request('POST', 'logistics/incoming/$parcelId/receive', jsonBody: {'facility_id':facilityId, if (notes?.trim().isNotEmpty == true) 'notes':notes!.trim()});
  Future<SariJson> logisticsSort(int parcelId, int facilityId, {String? sortingZone, String? notes}) => _api.request('POST', 'logistics/sorting/$parcelId/confirm', jsonBody: {'facility_id':facilityId, if (sortingZone?.trim().isNotEmpty == true) 'sorting_zone':sortingZone!.trim(), if (notes?.trim().isNotEmpty == true) 'notes':notes!.trim()});
  Future<SariJson> logisticsTransfers({int? facilityId}) => _api.request('GET', 'logistics/transfers', query: facilityId == null ? null : {'facility_id':'$facilityId'});
  Future<SariJson> logisticsTransfer(int id) => _api.request('GET', 'logistics/transfers/$id');
  Future<SariJson> logisticsTransferAction(int id, int facilityId, String action) {
    if (action != 'dispatch' && action != 'receive') throw ArgumentError.value(action, 'action');
    return _api.request('POST', 'logistics/transfers/$id/$action', jsonBody: {'facility_id':facilityId});
  }
  Future<SariJson> logisticsNotifications() => _api.request('GET', 'logistics/notifications');
  Future<SariJson> logisticsReadNotification(int id) => _api.request('POST', 'logistics/notifications/$id/read');
  Future<SariJson> logisticsRiders() => _api.request('GET', 'logistics/riders');
  Future<SariJson> logisticsMessages(int riderId) => _api.request('GET', 'logistics/messages', query: {'rider_id':'$riderId'});
  Future<SariJson> logisticsSendMessage(int riderId, String body) => _api.request('POST', 'logistics/messages', jsonBody: {'rider_id':riderId,'body':body});
  Future<SariJson> logisticsRemittances(int facilityId) => _api.request('GET', 'logistics/remittances', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsRemittance(int id, int facilityId) => _api.request('GET', 'logistics/remittances/$id', query: {'facility_id':'$facilityId'});
  Future<SariJson> logisticsVerifyRemittance({required int id, required int facilityId, required double confirmedAmount, String? reference, String? note}) => _api.request('POST', 'logistics/remittances/$id/verify', jsonBody: {'facility_id':facilityId,'confirmed_amount':confirmedAmount, if(reference?.trim().isNotEmpty == true) 'logistics_reference':reference!.trim(), if(note?.trim().isNotEmpty == true) 'logistics_note':note!.trim()});
  Future<SariJson> buyerRewards() => _api.request('GET', 'buyer/rewards');

  Future<SariJson> logisticsRegister(Map<String, String> fields, Map<String, File> documents) => _api.multipart('POST', 'registration/logistics', authenticated:false, fields: fields, files: documents);
  Future<SariJson> logisticsResendOtp(String email) => _api.request('POST', 'registration/logistics/otp/resend', authenticated:false, jsonBody: {'email': email});
  Future<SariJson> logisticsVerifyOtp(String email, String otp) => _api.request('POST', 'registration/logistics/otp/verify', authenticated:false, jsonBody: {'email':email,'otp':otp});

  Future<SariJson> passwordResetSendCode(String email) => _api.request('POST', 'auth/forgot-password/send', authenticated:false, jsonBody: {'email':email});
  Future<SariJson> passwordResetVerify(String email, String code) => _api.request('POST', 'auth/forgot-password/verify', authenticated:false, jsonBody: {'email':email, 'code':code});
  Future<SariJson> passwordResetConfirm(String email, String token, String password) => _api.request('POST', 'auth/forgot-password/reset', authenticated:false, jsonBody: {'email':email, 'reset_token':token, 'password':password, 'password_confirmation':password});

  Future<SariJson> riderReportFailed(int orderId, String reason) => _api.request('POST','rider/orders/$orderId/failed', jsonBody:{'reason':reason});
  Future<SariJson> riderRescheduleRequest(int orderId, String reason, String rescheduledFor) => _api.request('POST','rider/orders/$orderId/reschedule-request', jsonBody:{'reason':reason,'rescheduled_for':rescheduledFor});
  Future<SariJson> riderReturnRequest(int orderId, String reason) => _api.request('POST','rider/orders/$orderId/return-request', jsonBody:{'reason':reason});
}