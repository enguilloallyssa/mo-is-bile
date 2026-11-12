import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/sari_live_data.dart';
import 'models/rider_delivery_model.dart';
import 'models/rider_earning_model.dart';
import 'models/rider_history_model.dart';
import 'models/rider_profile_model.dart';
import 'rider_deliveries.dart';
import 'rider_earnings.dart';
import 'rider_history.dart';
import 'rider_home.dart';
import 'rider_last_mile.dart';
import 'rider_messages.dart';
import 'rider_notifications.dart';
import 'rider_pickups.dart';
import 'rider_profile.dart';
import 'rider_proof_of_delivery.dart';
import 'rider_remittances.dart';
import 'rider_requests.dart';
import 'rider_scanner.dart';
import 'widgets/rider_bottom_nav.dart';
import 'widgets/rider_drawer.dart';
import 'widgets/rider_ui.dart';

class RiderShell extends StatefulWidget {
  const RiderShell({
    super.key,
  });

  @override
  State<RiderShell> createState() =>
      _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  final GlobalKey<ScaffoldState> _shellKey =
      GlobalKey<ScaffoldState>();

  void _openDrawer() =>
      _shellKey.currentState?.openEndDrawer();

  @override
  void dispose() {
    RiderHeaderController.messages = null;
    RiderHeaderController.notifications = null;
    RiderMenuController.open = null;
    super.dispose();
  }

  int _currentIndex = 0;

  final Set<int> _visitedTabs = {0};

  final Set<int> _uploadedProofOrderIds =
      <int>{};

  bool _darkMode = false;
  bool _loading = false;
  bool _refreshing = false;
  bool _financeLoading = false;
  bool _lastMileLoading = false;

  String? _error;

  RiderDelivery? _currentDelivery;

  final List<RiderDelivery> _assignments = [];

  final List<RiderLastMileBatch>
      _lastMileBatches = [];

  final List<RiderDailyEarning>
      _dailyEarnings = [];

  final List<RiderEarningTransaction>
      _transactions = [];

  Map<String, dynamic> _dashboardSummary = {};
  Map<String, dynamic> _dashboardCurrent = {};

  RiderProfile _profile = RiderProfile(
    firstName: 'SARI',
    lastName: 'Rider',
    email: '',
    contactNo: '',
    streetAddress: '',
    vehicleType: '',
    vehicleModel: '',
    plateNumber: '',
    licenseNumber: '',
    availabilityStatus: 'offline',
    completedDeliveries: 0,
    rating: 5,
  );

  @override
  void initState() {
    super.initState();

    RiderThemeController.setDark(
      _darkMode,
    );

    RiderHeaderController.messages = _openMessages;
    RiderHeaderController.notifications = _openNotifications;
    RiderMenuController.open = _openDrawer;

    _loadAll();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return {};
  }

  List<dynamic> _list(
    dynamic value,
  ) {
    if (value is List) {
      return value;
    }

    return const [];
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  int _int(
    dynamic value,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          '$value',
        ) ??
        0;
  }

  double _double(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          '$value',
        ) ??
        0;
  }

  Future<Map<String, dynamic>> _safeJson(
    Future<Map<String, dynamic>> Function()
        loader,
  ) async {
    try {
      return await loader();
    } catch (_) {
      return {};
    }
  }

  RiderDelivery _delivery(
    dynamic raw,
  ) {
    final data = _map(raw);

    final actions = _list(
      data['allowed_actions'],
    )
        .map(
          (value) => '$value',
        )
        .where(
          (value) =>
              value.trim().isNotEmpty,
        )
        .toList();

    final stops = _list(
      data['route_stops'],
    )
        .map(_map)
        .toList()
      ..sort(
        (
          a,
          b,
        ) =>
            _int(
              a['sequence'],
            ).compareTo(
              _int(
                b['sequence'],
              ),
            ),
      );

    Map<String, dynamic>? pickupStop;
    Map<String, dynamic>? buyerStop;
    Map<String, dynamic>? hubStop;

    for (final stop in stops) {
      final key = _text(
        stop['key'],
      ).toLowerCase();

      if (pickupStop == null &&
          (key.contains('pickup') ||
              key.contains('seller') ||
              key.contains('origin'))) {
        pickupStop = stop;
      }

      if (key.contains('buyer') ||
          key.contains('delivery') ||
          key.contains(
            'destination',
          )) {
        buyerStop = stop;
      }

      if (hubStop == null &&
          (key.contains('hub') ||
              key.contains('sorting') ||
              key.contains('facility'))) {
        hubStop = stop;
      }
    }

    if (pickupStop == null &&
        stops.isNotEmpty) {
      pickupStop = stops.first;
    }

    if (buyerStop == null &&
        stops.length > 1) {
      buyerStop = stops.last;
    }

    double coordinate(
      Map<String, dynamic>? stop,
      String key,
    ) {
      if (stop == null) {
        return 0;
      }

      return _double(
        stop[key],
      );
    }

    return RiderDelivery(
      id: _int(
        data['id'],
      ),
      orderNumber: _text(
        data['order_number'],
      ),
      packageCode: _text(
        data['package_code'],
        _text(
          data['order_number'],
        ),
      ),
      pickupName: _text(
        data['pickup_name'],
        _text(
          data['seller_name'],
          'Seller',
        ),
      ),
      pickupAddress: _text(
        data['pickup_address'],
        _text(
          pickupStop?['address'],
        ),
      ),
      pickupLatitude:
          coordinate(
        pickupStop,
        'lat',
      ),
      pickupLongitude:
          coordinate(
        pickupStop,
        'lng',
      ),
      sortingCenterName: _text(
        hubStop?['name'],
        'SARI Hub',
      ),
      sortingCenterAddress: _text(
        hubStop?['address'],
      ),
      sortingCenterLatitude:
          coordinate(
        hubStop,
        'lat',
      ),
      sortingCenterLongitude:
          coordinate(
        hubStop,
        'lng',
      ),
      buyerName: _text(
        data['buyer_name'],
        'Buyer',
      ),
      buyerAddress: _text(
        data['buyer_address'],
        _text(
          buyerStop?['address'],
        ),
      ),
      buyerLatitude:
          coordinate(
        buyerStop,
        'lat',
      ),
      buyerLongitude:
          coordinate(
        buyerStop,
        'lng',
      ),
      riderLatitude: 0,
      riderLongitude: 0,
      sellerName: _text(
        data['seller_name'],
        'SARI Seller',
      ),
      deliveryFee: _double(
        data['delivery_fee'],
      ),
      status: _text(
        data['status'],
      ),
      isLogisticsPickup:
          data['is_logistics_pickup'] ==
              true,
      allowedActions:
          actions,
    );
  }

  RiderProfile _profileFrom(
    dynamic raw,
  ) {
    final data =
        _map(raw);

    final rating =
        _double(
      data['rating'],
    );

    return RiderProfile(
      firstName: _text(
        data['first_name'],
        'SARI',
      ),
      lastName: _text(
        data['last_name'],
        'Rider',
      ),
      email: _text(
        data['email'],
      ),
      contactNo: _text(
        data['contact_no'],
      ),
      streetAddress: _text(
        data['street_address'],
      ),
      vehicleType: _text(
        data['vehicle_type'],
      ),
      vehicleModel: _text(
        data['vehicle_model'],
      ),
      plateNumber: _text(
        data['plate_number'],
      ),
      licenseNumber: _text(
        data['license_number'],
      ),
      availabilityStatus: _text(
        data['availability_status'],
        'offline',
      ),
      completedDeliveries: _int(
        data['completed_deliveries'],
      ),
      rating:
          rating <= 0 ? 5 : rating,
    );
  }

  RiderLastMileBatch _lastMileFallback(
    Map<String, dynamic> data,
  ) {
    final id =
        _int(
      data['id'],
    );

    return RiderLastMileBatch(
      id: id,
      assignmentCode: _text(
        data['assignment_code'],
        'LM-$id',
      ),
      status: _text(
        data['status'],
      ),
      facilityName: _text(
        data['facility_name'],
        'SARI Hub',
      ),
      facilityAddress: _text(
        data['facility_address'],
      ),
      deliveryArea: _text(
        data['delivery_area'],
        _text(
          data['facility_municipality'],
        ),
      ),
      parcels: const [],
    );
  }

  Future<List<RiderLastMileBatch>>
      _loadLastMileBatches(
    List<dynamic> rows,
  ) async {
    final batches =
        <RiderLastMileBatch>[];

    for (final raw in rows) {
      final base =
          _map(raw);

      final id =
          _int(
        base['id'],
      );

      if (id <= 0) {
        continue;
      }

      try {
        final response =
            await SariLiveData
                .instance
                .riderLastMileDetails(
          id,
        );

        final data =
            _map(
          response['data'],
        );

        final assignment =
            _map(
          data['assignment'],
        );

        final orders =
            _list(
          data['orders'],
        );

        final parcels =
            orders
                .map(
                  (
                    orderRaw,
                  ) {
                    final order =
                        _map(
                      orderRaw,
                    );

                    return RiderLastMileParcel(
                      id: _int(
                        order['id'],
                      ),
                      orderNumber:
                          _text(
                        order[
                            'order_number'],
                      ),
                      parcelCode:
                          _text(
                        order[
                            'parcel_code'],
                        _text(
                          order[
                              'order_number'],
                        ),
                      ),
                      buyerName:
                          _text(
                        order[
                            'buyer_name'],
                        'Buyer',
                      ),
                      buyerAddress:
                          _text(
                        order[
                            'buyer_address'],
                      ),
                      buyerPhone:
                          _text(
                        order[
                            'buyer_phone'],
                      ),
                      status:
                          _text(
                        order[
                            'parcel_status'],
                        _text(
                          order[
                              'order_status'],
                        ),
                      ),
                    );
                  },
                )
                .where(
                  (
                    parcel,
                  ) =>
                      parcel.id > 0,
                )
                .toList();

        batches.add(
          RiderLastMileBatch(
            id: id,
            assignmentCode: _text(
              assignment[
                  'assignment_code'],
              _text(
                base[
                    'assignment_code'],
                'LM-$id',
              ),
            ),
            status: _text(
              assignment['status'],
              _text(
                base['status'],
              ),
            ),
            facilityName: _text(
              assignment[
                  'facility_name'],
              _text(
                base[
                    'facility_name'],
                'SARI Hub',
              ),
            ),
            facilityAddress:
                _text(
              assignment[
                  'facility_address'],
              _text(
                base[
                    'facility_address'],
              ),
            ),
            deliveryArea: _text(
              assignment[
                  'delivery_area'],
              _text(
                assignment[
                    'facility_municipality'],
                _text(
                  base[
                      'delivery_area'],
                  _text(
                    base[
                        'facility_municipality'],
                  ),
                ),
              ),
            ),
            parcels:
                parcels,
          ),
        );
      } catch (_) {
        batches.add(
          _lastMileFallback(
            base,
          ),
        );
      }
    }

    return batches;
  }

  RiderDelivery? _resolveCurrentDelivery(
    List<RiderDelivery> assignments,
    Map<String, dynamic> dashboard,
  ) {
    final current =
        _map(
      dashboard[
          'current_assignment'],
    );

    final currentId =
        _int(
      current['id'],
    );

    if (currentId > 0) {
      for (final assignment
          in assignments) {
        if (assignment.id ==
            currentId) {
          return assignment;
        }
      }
    }

    if (assignments.isEmpty) {
      return null;
    }

    return assignments.first;
  }

  Future<void> _loadAll() async {
    if (_refreshing ||
        !mounted) {
      return;
    }

    setState(() {
      _refreshing = true;
      _error = null;
    });

    Map<String, dynamic> response =
        {};

    String? failure;

    try {
      response =
          await SariLiveData
              .instance
              .riderDashboard(
        timeout:
            const Duration(
          seconds: 8,
        ),
      );
    } catch (error) {
      failure =
          error.toString();
    }

    if (!mounted) {
      return;
    }

    final dashboard =
        _map(
      response['data'],
    );

    setState(() {
      if (dashboard.isNotEmpty) {
        _dashboardSummary =
            _map(
          dashboard['summary'],
        );
        _dashboardCurrent = _map(dashboard['current_assignment']);

        _currentDelivery =
            _resolveCurrentDelivery(
          _assignments,
          dashboard,
        );
      }

      _loading = false;
      _refreshing = false;

      _error =
          dashboard.isEmpty
              ? (failure ??
                  'Rider dashboard is unavailable.')
              : null;
    });

    unawaited(
      _loadPrimary(),
    );

    if (_visitedTabs.contains(3)) {
      unawaited(
        _loadFinance(),
      );
    }
  }

  Future<void> _loadPrimary() async {
    final results =
        await Future.wait<
            Map<String, dynamic>>(
      [
        _safeJson(
          () => SariLiveData
              .instance
              .riderProfile(
            timeout:
                const Duration(
              seconds: 9,
            ),
          ),
        ),
        _safeJson(
          () => SariLiveData
              .instance
              .riderAssignments(
            timeout:
                const Duration(
              seconds: 9,
            ),
          ),
        ),
      ],
    );

    if (!mounted) {
      return;
    }

    final profile =
        _map(
      results[0]['data'],
    );

    final rows =
        _list(
      results[1]['data'],
    );

    final assignments =
        rows
            .map(_delivery)
            .where(
              (item) =>
                  item.id > 0,
            )
            .toList();

    setState(() {
      if (profile.isNotEmpty) {
        _profile =
            _profileFrom(
          profile,
        );
      }

      if (results[1].isNotEmpty) {
        _assignments
          ..clear()
          ..addAll(
            assignments,
          );
      }

      _currentDelivery =
          _resolveCurrentDelivery(
        _assignments,
        {'current_assignment': _dashboardCurrent},
      );
    });

    // Load the current order's real route stops for the dashboard map,
    // even before the Rider opens Assignments or Deliveries.
    // Never simulate a rider GPS point or draw a false road route.
    if (assignments.isNotEmpty) {
      final selected = _currentDelivery;
      unawaited(_hydrateAssignments(
        _visitedTabs.contains(1) || _visitedTabs.contains(2)
            ? assignments
            : selected == null ? assignments.take(1).toList() : [selected],
      ));
    }
  }

  Future<void> _hydrateAssignments(
    List<RiderDelivery> initial,
  ) async {
    if (initial.isEmpty) {
      return;
    }

    final details =
        await Future.wait<
            RiderDelivery>(
      initial.take(20).map(
        (item) async {
          try {
            final response =
                await SariLiveData
                    .instance
                    .riderAssignment(
              item.id,
            );

            return _delivery(
              response['data'],
            );
          } catch (_) {
            return item;
          }
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      for (final detail
          in details) {
        final i =
            _assignments
                .indexWhere(
          (item) =>
              item.id ==
              detail.id,
        );

        if (i >= 0) {
          _assignments[i] =
              detail;
        }
      }

      final currentId =
          _currentDelivery?.id;

      final currentIndex =
          _assignments
              .indexWhere(
        (item) =>
            item.id ==
            currentId,
      );

      if (currentIndex >= 0) {
        _currentDelivery =
            _assignments[
                currentIndex];
      }
    });
  }

  Future<void> _loadFinance()
      async {
    if (_financeLoading ||
        !mounted) {
      return;
    }

    _financeLoading = true;

    try {
      final results =
          await Future.wait<
              Map<String, dynamic>>(
        [
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderEarnings(),
          ),
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderTransactions(
              perPage: 50,
            ),
          ),
        ],
      );

      if (!mounted) {
        return;
      }

      final earnings =
          _map(
        results[0]['data'],
      );

      final transactions =
          _list(
        results[1]['data'],
      );

      setState(() {
        if (results[0].isNotEmpty) {
          _dailyEarnings
            ..clear()
            ..addAll(
              _list(
                earnings['daily'],
              ).map(
                (raw) {
                  final data =
                      _map(raw);

                  return RiderDailyEarning(
                    day: _text(
                      data['day'],
                    ),
                    amount: _double(
                      data['amount'],
                    ),
                  );
                },
              ),
            );
        }

        if (results[1].isNotEmpty) {
          _transactions
            ..clear()
            ..addAll(
              transactions.map(
                (raw) {
                  final data =
                      _map(raw);

                  return RiderEarningTransaction(
                    order: _text(
                      data[
                          'order_number'],
                      'Order',
                    ),
                    date: _text(
                      data[
                          'earned_at'],
                    ),
                    type: _text(
                      data[
                          'earning_type'],
                      'earning',
                    ),
                    amount: _double(
                      data['amount'],
                    ),
                    status: _text(
                      data['status'],
                      'recorded',
                    ),
                  );
                },
              ),
            );
        }
      });
    } finally {
      _financeLoading =
          false;
    }
  }

  Future<void> _loadLastMile()
      async {
    if (_lastMileLoading ||
        !mounted) {
      return;
    }

    _lastMileLoading = true;

    try {
      final response =
          await SariLiveData
              .instance
              .riderLastMile();

      final rows =
          _list(
        response['data'],
      );

      final batches =
          await _loadLastMileBatches(
        rows,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _lastMileBatches
          ..clear()
          ..addAll(
            batches,
          );
      });
    } catch (error) {
      if (mounted) {
        _toast(
          'Last-mile data unavailable: $error',
        );
      }
    } finally {
      _lastMileLoading =
          false;
    }
  }

  void _drawerNavigate(
    int tab,
  ) {
    _shellKey.currentState
        ?.closeEndDrawer();

    _changeTab(
      tab,
    );
  }

  void _drawerOpen(
    VoidCallback action,
  ) {
    _shellKey.currentState
        ?.closeEndDrawer();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (mounted) {
          action();
        }
      },
    );
  }

  Future<void> _logoutFromDrawer()
      async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) =>
              AlertDialog(
        title:
            const Text(
          'Log out?',
        ),
        content:
            const Text(
          'End the SARI Rider session on this phone?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
              false,
            ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
              true,
            ),
            child:
                const Text(
              'Log out',
            ),
          ),
        ],
      ),
    );

    if (confirm != true ||
        !mounted) {
      return;
    }

    try {
      await SariLiveData
          .instance
          .logout();

      const storage =
          FlutterSecureStorage();

      await storage.delete(
        key: 'sari_access_token',
      );

      await storage.delete(
        key: 'sari_account_role',
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
        );
      }
    } catch (error) {
      _toast(
        'Logout failed; session retained: $error',
      );
    }
  }

  void _changeTab(
    int index,
  ) {
    if (index < 0 ||
        index > 4) {
      return;
    }

    setState(() {
      _currentIndex =
          index;

      _visitedTabs.add(
        index,
      );
    });

    if (index == 3) {
      unawaited(
        _loadFinance(),
      );
    }

    if (index == 1 ||
        index == 2) {
      unawaited(
        _hydrateAssignments(
          List.of(
            _assignments,
          ),
        ),
      );
    }
  }

  void _setDarkMode(
    bool value,
  ) {
    RiderThemeController.setDark(
      value,
    );

    setState(() {
      _darkMode =
          value;
    });
  }

  void _toast(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(
            message,
          ),
          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
  }

  String _actionFor(
    RiderDelivery delivery,
  ) {
    if (delivery.allowedActions
        .isNotEmpty) {
      return delivery
          .allowedActions.first;
    }

    switch (delivery.status) {
      case 'courier_accepted':
        return 'proceed_pickup';

      case 'heading_pickup':
        return 'arrived_pickup';

      case 'arrived_pickup':
        return 'confirm_pickup';

      case 'in_transit':
        return delivery
                .isLogisticsPickup
            ? ''
            : 'arrived_buyer';

      case 'arrived_buyer':
        return delivery
                .isLogisticsPickup
            ? ''
            : 'complete';

      default:
        return '';
    }
  }

  Future<Map<String, dynamic>?>
      _scanAndVerify({
    int? expectedOrderId,
    String? expectedOrderNumber,
  }) async {
    final code =
        await Navigator.of(
      context,
    ).push<String>(
      MaterialPageRoute<String>(
        builder: (
          context,
        ) =>
            RiderScanner(
          title:
              expectedOrderNumber ==
                          null ||
                      expectedOrderNumber
                          .trim()
                          .isEmpty
                  ? 'Parcel Scanner'
                  : 'Verify $expectedOrderNumber',
        ),
      ),
    );

    if (!mounted ||
        code == null ||
        code.trim().isEmpty) {
      return null;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderScanVerify(
        code.trim(),
      );

      final data =
          _map(
        response['data'],
      );

      final verifiedOrderId =
          _int(
        data['order_id'],
      );

      if (expectedOrderId != null &&
          expectedOrderId > 0 &&
          verifiedOrderId !=
              expectedOrderId) {
        _toast(
          'The scanned parcel belongs to a different order.',
        );

        return null;
      }

      _toast(
        _text(
          response['message'],
          'Parcel verified for this Rider.',
        ),
      );

      return data;
    } catch (error) {
      _toast(
        error.toString(),
      );

      return null;
    }
  }

  Future<bool> _captureProof({
    required int orderId,
    required String orderNumber,
    String? recipientName,
  }) async {
    if (_uploadedProofOrderIds
        .contains(orderId)) {
      return true;
    }

    final bool? uploaded =
        await Navigator.of(
      context,
    ).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            RiderProofOfDelivery(
          orderId: orderId,
          orderNumber:
              orderNumber,
          recipientName:
              recipientName,
        ),
      ),
    );

    if (!mounted) {
      return false;
    }

    if (uploaded == true) {
      _uploadedProofOrderIds.add(
        orderId,
      );

      _toast(
        'Proof of delivery uploaded successfully.',
      );

      return true;
    }

    return false;
  }

  Future<bool>
      _confirmCodCashIfRequired(
    Map<String, dynamic> scanData, {
    required int orderId,
    required String orderNumber,
  }) async {
    final requiresPayment =
        scanData[
                    'requires_payment'] ==
                true ||
            scanData[
                        'requires_payment']
                    ?.toString() ==
                '1';

    if (!requiresPayment) {
      return true;
    }

    final paymentToken =
        _text(
      scanData[
          'payment_token'],
    );

    final amountDue =
        _text(
      scanData['amount_due'],
      '0.00',
    );

    if (paymentToken.isEmpty) {
      _toast(
        'COD verification token is missing. Scan the parcel again.',
      );

      return false;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible:
          false,
      builder:
          (
            dialogContext,
          ) {
        return AlertDialog(
          title:
              const Text(
            'Confirm COD cash received',
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                orderNumber,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Amount to collect: ₱$amountDue',
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Only confirm after the Buyer has physically handed you the full cash amount. The order will not be marked paid until this confirmation is recorded on the server.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(false),
              child:
                  const Text(
                'Not yet',
              ),
            ),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(true),
              icon:
                  const Icon(
                Icons
                    .payments_outlined,
              ),
              label:
                  const Text(
                'Cash received',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return false;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderConfirmCodCash(
        orderId: orderId,
        paymentToken:
            paymentToken,
      );

      _toast(
        _text(
          response['message'],
          'COD cash receipt confirmed.',
        ),
      );

      return true;
    } catch (error) {
      _toast(
        error.toString(),
      );

      return false;
    }
  }

  Future<bool>
      _verifyAndCaptureProof(
    RiderDelivery delivery,
  ) async {
    final verified =
        await _scanAndVerify(
      expectedOrderId:
          delivery.id,
      expectedOrderNumber:
          delivery.orderNumber,
    );

    if (verified == null ||
        !mounted) {
      return false;
    }

    final proofSaved =
        await _captureProof(
      orderId:
          delivery.id,
      orderNumber:
          delivery.orderNumber,
      recipientName:
          delivery.buyerName,
    );

    if (!proofSaved ||
        !mounted) {
      return false;
    }

    return _confirmCodCashIfRequired(
      verified,
      orderId:
          delivery.id,
      orderNumber:
          delivery.orderNumber,
    );
  }

  Future<void> _advanceDelivery(
    RiderDelivery delivery,
  ) async {
    try {
      final latest =
          await SariLiveData
              .instance
              .riderAssignment(
        delivery.id,
      );

      final fresh =
          _delivery(
        latest['data'],
      );

      if (!mounted) {
        return;
      }

      delivery = fresh;
    } catch (error) {
      _toast(
        'Unable to verify current assignment status: $error',
      );

      return;
    }

    final action =
        _actionFor(
      delivery,
    );

    if (action.isEmpty) {
      _toast(
        'No server action is available for this assignment.',
      );

      return;
    }

    try {
      if (action ==
              'confirm_pickup' &&
          delivery
              .isLogisticsPickup) {
        final verified =
            await _scanAndVerify(
          expectedOrderId:
              delivery.id,
          expectedOrderNumber:
              delivery.orderNumber,
        );

        if (verified == null ||
            !mounted) {
          return;
        }

        await _loadAll();

        return;
      }

      if (action ==
          'complete') {
        final ready =
            await _verifyAndCaptureProof(
          delivery,
        );

        if (!ready ||
            !mounted) {
          return;
        }
      }

      final response =
          switch (action) {
        'proceed_pickup' =>
          await SariLiveData
              .instance
              .riderProceedPickup(
            delivery.id,
          ),

        'arrived_pickup' =>
          await SariLiveData
              .instance
              .riderArrivedPickup(
            delivery.id,
          ),

        'confirm_pickup' =>
          await SariLiveData
              .instance
              .riderConfirmPickup(
            delivery.id,
          ),

        'arrived_buyer' =>
          await SariLiveData
              .instance
              .riderArrivedBuyer(
            delivery.id,
          ),

        'complete' =>
          await SariLiveData
              .instance
              .riderComplete(
            delivery.id,
          ),

        _ => <String, dynamic>{},
      };

      _toast(
        _text(
          response['message'],
          'Assignment updated.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<void> _markSuccessful(
    RiderDelivery delivery,
  ) async {
    try {
      final latest =
          await SariLiveData
              .instance
              .riderAssignment(
        delivery.id,
      );

      delivery =
          _delivery(
        latest['data'],
      );

      if (delivery.status !=
              'arrived_buyer' ||
          !delivery.allowedActions
              .contains(
            'complete',
          )) {
        _toast(
          'Mark arrival at the Buyer before completing this delivery.',
        );

        return;
      }
    } catch (error) {
      _toast(
        'Unable to verify current assignment status: $error',
      );

      return;
    }

    if (delivery
        .isLogisticsPickup) {
      _toast(
        'Logistics-managed orders must use the assigned last-mile workflow.',
      );

      return;
    }

    final ready =
        await _verifyAndCaptureProof(
      delivery,
    );

    if (!ready ||
        !mounted) {
      return;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderComplete(
        delivery.id,
      );

      _toast(
        _text(
          response['message'],
          'Delivery completed.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<String?> _askReason(
    String title,
  ) async {
    final controller =
        TextEditingController();

    final result =
        await showDialog<String>(
      context: context,
      builder:
          (dialogContext) =>
              AlertDialog(
        title:
            Text(
          title,
        ),
        content:
            TextField(
          controller:
              controller,
          maxLines: 4,
          decoration:
              const InputDecoration(
            labelText:
                'Reason',
            border:
                OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              dialogContext,
            ),
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed: () {
              final value =
                  controller.text
                      .trim();

              if (value.isNotEmpty) {
                Navigator.pop(
                  dialogContext,
                  value,
                );
              }
            },
            child:
                const Text(
              'Submit',
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    return result;
  }

  Future<void> _reportFailed(
    RiderDelivery delivery,
  ) async {
    final reason =
        await _askReason(
      'Report failed delivery',
    );

    if (reason == null ||
        !mounted) {
      return;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderReportFailed(
        delivery.id,
        reason,
      );

      _toast(
        _text(
          response['message'],
          'Failed delivery report sent.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<void> _requestReschedule(
    RiderDelivery delivery,
  ) async {
    final reason =
        await _askReason(
      'Reason for reschedule',
    );

    if (reason == null ||
        !mounted) {
      return;
    }

    final now =
        DateTime.now();

    final date =
        await showDatePicker(
      context: context,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(
        const Duration(
          days: 1,
        ),
      ),
      lastDate: DateTime(
        now.year + 1,
        12,
        31,
      ),
      initialDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(
        const Duration(
          days: 1,
        ),
      ),
    );

    if (date == null ||
        !mounted) {
      return;
    }

    final scheduled =
        DateTime(
      date.year,
      date.month,
      date.day,
      9,
    ).toIso8601String();

    try {
      final response =
          await SariLiveData
              .instance
              .riderRescheduleRequest(
        delivery.id,
        reason,
        scheduled,
      );

      _toast(
        _text(
          response['message'],
          'Reschedule request sent.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<void> _requestReturn(
    RiderDelivery delivery,
  ) async {
    final reason =
        await _askReason(
      'Reason for return to sorting',
    );

    if (reason == null ||
        !mounted) {
      return;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderReturnRequest(
        delivery.id,
        reason,
      );

      _toast(
        _text(
          response['message'],
          'Return request sent.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  void _unsupported(
    String label,
  ) {
    _toast(
      '$label is not exposed by the current Laravel Rider API.',
    );
  }

  Future<void> _openNotifications()
      async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RiderNotifications(
          onOpenMessages:
              _openMessages,
        ),
      ),
    );
  }

  Future<void> _openMessages()
      async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            const RiderMessages(),
      ),
    );

    if (mounted) {
      await _loadAll();
    }
  }

  List<RiderHistoryRecord>
      _historyFallback() {
    final now =
        DateTime.now();

    return _transactions.map(
      (
        transaction,
      ) {
        final dateTime =
            DateTime.tryParse(
          transaction.date,
        )?.toLocal();

        return RiderHistoryRecord(
          order:
              transaction.order,
          customer: '',
          route:
              transaction.type,
          date:
              dateTime == null
                  ? transaction.date
                  : '${dateTime.month}/${dateTime.day}/${dateTime.year}',
          time:
              dateTime == null
                  ? ''
                  : TimeOfDay
                      .fromDateTime(
                        dateTime,
                      )
                      .format(
                        context,
                      ),
          fee:
              transaction.amount,
          status:
              transaction.status,
          isToday:
              dateTime != null &&
                  dateTime.year ==
                      now.year &&
                  dateTime.month ==
                      now.month &&
                  dateTime.day ==
                      now.day,
        );
      },
    ).toList();
  }

  Future<void> _openHistory()
      async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            RiderHistory(
          history:
              _historyFallback(),
        ),
      ),
    );

    if (mounted) {
      await _loadAll();
    }
  }

  Future<void> _openPickups()
      async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            RiderPickups(
          orders:
              _assignments,
          onAdvanceDelivery:
              _advanceDelivery,
          onOpenWorkflow: () {
            Navigator.of(
              context,
            ).pop();

            _changeTab(
              1,
            );
          },
          onOpenScanner: () {
            _scanAndVerify();
          },
        ),
      ),
    );

    if (mounted) {
      await _loadAll();
    }
  }

  Future<void> _startLastMileBatch(
    RiderLastMileBatch batch,
  ) async {
    try {
      final response =
          await SariLiveData
              .instance
              .riderStartLastMile(
        batch.id,
      );

      _toast(
        _text(
          response['message'],
          'Last-mile delivery route started.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  RiderLastMileBatch? _batchForParcel(
    RiderLastMileParcel parcel,
  ) {
    for (final batch
        in _lastMileBatches) {
      if (batch.parcels.any(
        (
          entry,
        ) =>
            entry.id ==
            parcel.id,
      )) {
        return batch;
      }
    }

    return null;
  }

  Future<void>
      _completeLastMileParcel(
    RiderLastMileBatch batch,
    RiderLastMileParcel parcel,
  ) async {
    final verified =
        await _scanAndVerify(
      expectedOrderId:
          parcel.id,
      expectedOrderNumber:
          parcel.orderNumber,
    );

    if (verified == null ||
        !mounted) {
      return;
    }

    final proofSaved =
        await _captureProof(
      orderId:
          parcel.id,
      orderNumber:
          parcel.orderNumber,
      recipientName:
          parcel.buyerName,
    );

    if (!proofSaved ||
        !mounted) {
      return;
    }

    final codReady =
        await _confirmCodCashIfRequired(
      verified,
      orderId:
          parcel.id,
      orderNumber:
          parcel.orderNumber,
    );

    if (!codReady ||
        !mounted) {
      return;
    }

    try {
      final response =
          await SariLiveData
              .instance
              .riderLastMileDelivered(
        batch.id,
        parcel.id,
      );

      _toast(
        _text(
          response['message'],
          'Last-mile delivery completed.',
        ),
      );

      await _loadAll();
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<void> _openLastMileParcel(
    RiderLastMileParcel parcel,
  ) async {
    final batch =
        _batchForParcel(
      parcel,
    );

    if (batch == null) {
      _toast(
        'Unable to locate this last-mile batch.',
      );

      return;
    }

    if (parcel.isDelivered) {
      _toast(
        'This parcel has already been delivered.',
      );

      return;
    }

    if (batch.status ==
        'assigned') {
      final start =
          await showModalBottomSheet<
              bool>(
        context: context,
        showDragHandle: true,
        backgroundColor:
            RiderColors.surface,
        builder: (
          sheetContext,
        ) {
          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                18,
                6,
                18,
                24,
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    batch
                        .assignmentCode,
                    style:
                        TextStyle(
                      color:
                          RiderColors.text,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    'This batch is assigned but has not started yet. Start the route before confirming arrival at any Buyer.',
                    style:
                        TextStyle(
                      color:
                          RiderColors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(
                        sheetContext,
                      ).pop(
                        true,
                      ),
                      icon:
                          const Icon(
                        Icons
                            .route_outlined,
                      ),
                      label:
                          const Text(
                        'Start Last-Mile Route',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (start == true &&
          mounted) {
        await _startLastMileBatch(
          batch,
        );
      }

      return;
    }

    if (batch.status ==
        'completed') {
      _toast(
        'This last-mile batch is already completed.',
      );

      return;
    }

    final parcelStatus =
        parcel.status
            .toLowerCase();

    final canComplete =
        parcelStatus ==
            'arrived_buyer';

    final action =
        await showModalBottomSheet<
            String>(
      context: context,
      showDragHandle: true,
      backgroundColor:
          RiderColors.surface,
      builder: (
        sheetContext,
      ) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              18,
              6,
              18,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  parcel.orderNumber,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  parcel.buyerName,
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  parcel.buyerAddress,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                if (!canComplete)
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(
                        sheetContext,
                      ).pop(
                        'arrived',
                      ),
                      icon:
                          const Icon(
                        Icons
                            .location_on_outlined,
                      ),
                      label:
                          const Text(
                        'Confirm Arrival at Buyer',
                      ),
                    ),
                  ),
                if (canComplete)
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(
                        sheetContext,
                      ).pop(
                        'delivered',
                      ),
                      icon:
                          const Icon(
                        Icons
                            .verified_outlined,
                      ),
                      label:
                          const Text(
                        'Verify, Capture Proof & Deliver',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null ||
        !mounted) {
      return;
    }

    try {
      if (action ==
          'arrived') {
        final response =
            await SariLiveData
                .instance
                .riderLastMileArrived(
          batch.id,
          parcel.id,
        );

        _toast(
          _text(
            response['message'],
            'Arrival at Buyer confirmed.',
          ),
        );

        await _loadAll();
      } else if (action ==
          'delivered') {
        await _completeLastMileParcel(
          batch,
          parcel,
        );
      }
    } catch (error) {
      _toast(
        error.toString(),
      );
    }
  }

  Future<void> _openLastMile()
      async {
    await _loadLastMile();

    if (!mounted) {
      return;
    }

    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            RiderLastMile(
          batches:
              _lastMileBatches,
          onBackToDashboard: () {
            Navigator.of(
              context,
            ).pop();

            _changeTab(
              0,
            );
          },
          onScanParcel: (
            parcel,
          ) {
            _scanAndVerify(
              expectedOrderId:
                  parcel.id,
              expectedOrderNumber:
                  parcel.orderNumber,
            );
          },
          onOpenParcel: (
            parcel,
          ) {
            _openLastMileParcel(
              parcel,
            );
          },
        ),
      ),
    );

    if (mounted) {
      await _loadAll();
    }
  }

  Future<void> _openRemittances()
      async {
    await Navigator.of(
      context,
    ).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            const RiderRemittances(),
      ),
    );

    if (mounted) {
      await _loadAll();
    }
  }

  Future<void> _openStandaloneScanner()
      async {
    await _scanAndVerify();
  }

  Widget _errorScreen() {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      body: Center(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.all(
            26,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.redSoft,
                  borderRadius:
                      BorderRadius.circular(
                    19,
                  ),
                ),
                child: Icon(
                  Icons
                      .cloud_off_outlined,
                  color:
                      RiderColors.red,
                  size: 32,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Unable to load Rider workspace',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                _error ??
                    'Please check your connection and try again.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 10,
                  height: 1.45,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              FilledButton.icon(
                onPressed:
                    _loadAll,
                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label:
                    const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openProfileSection(String section) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RiderProfilePage(
        profile: _profile,
        isDarkMode: _darkMode,
        onDarkModeChanged: _setDarkMode,
        section: section,
      ),
    ));
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    RiderThemeController.setDark(
      _darkMode,
    );

    final brightness =
        _darkMode
            ? Brightness.dark
            : Brightness.light;

    final theme =
        ThemeData(
      brightness:
          brightness,
      useMaterial3:
          true,
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
      colorScheme:
          ColorScheme.fromSeed(
        seedColor:
            RiderColors.blue,
        brightness:
            brightness,
      ),
      scaffoldBackgroundColor:
          RiderColors.bg,
    );

    return Theme(
      data:
          theme,
      child:
          Builder(
        builder: (
          context,
        ) {
          if (_error != null &&
              _assignments.isEmpty &&
              _lastMileBatches
                  .isEmpty &&
              _dashboardSummary
                  .isEmpty) {
            return _errorScreen();
          }

          final pages =
              <Widget>[
            RiderHome(
              currentDelivery:
                  _currentDelivery,
              assignments:
                  _assignments,
              profile:
                  _profile,
              isDarkMode:
                  _darkMode,
              onDarkModeChanged:
                  _setDarkMode,
              onTabChanged:
                  _changeTab,
              onAdvanceDelivery:
                  _advanceDelivery,
              onOpenMessages:
                  _openMessages,
              onOpenHistory:
                  _openHistory,
              onOpenPickups:
                  _openPickups,
              onRefresh:
                  _loadAll,
              dashboardSummary:
                  _dashboardSummary,
            ),
            RiderRequests(
              activeOrder:
                  _currentDelivery,
              orders:
                  _assignments,
              onAdvanceDelivery:
                  _advanceDelivery,
              onOpenWorkflow:
                  _openPickups,
              onOpenPickups:
                  _openPickups,
              onOpenDelivery:
                  () {
                _changeTab(
                  2,
                );
              },
            ),
            RiderDeliveries(
              orders:
                  _assignments,
              onAdvanceDelivery:
                  _advanceDelivery,
              onOpenWorkflow:
                  _openLastMile,
              onOpenHistory:
                  _openHistory,
              onMarkSuccessful:
                  _markSuccessful,
              onMarkFailed:
                  (delivery, _) =>
                      _reportFailed(
                delivery,
              ),
              onReschedule:
                  _requestReschedule,
              onReturnToSorting:
                  _requestReturn,
              onBuyerConfirmed:
                  (_) =>
                      _unsupported(
                'Buyer receipt confirmation',
              ),
            ),
            RiderEarnings(
              daily:
                  _dailyEarnings,
              transactions:
                  _transactions,
              onOpenHistory:
                  _openHistory,
            ),
            RiderProfilePage(
              profile:
                  _profile,
              isDarkMode:
                  _darkMode,
              onDarkModeChanged:
                  _setDarkMode,
              onTabChanged: _changeTab,
              onHistory: _openHistory,
              onPickups: _openPickups,
            ),
          ];

          return Scaffold(
            key:
                _shellKey,
            backgroundColor:
                RiderColors.bg,
            body:
                Stack(
              children: [
                IndexedStack(
                  index:
                      _currentIndex,
                  children:
                      List.generate(
                    pages.length,
                    (index) =>
                        _visitedTabs
                                .contains(
                              index,
                            )
                            ? pages[index]
                            : const SizedBox
                                .shrink(),
                  ),
                ),
                if (_refreshing &&
                    !_loading)
                  Positioned(
                    top:
                        MediaQuery.of(
                          context,
                        ).padding.top,
                    left: 0,
                    right: 0,
                    child:
                        const LinearProgressIndicator(
                      minHeight: 2,
                    ),
                  ),
              ],
            ),
            endDrawer: RiderDrawer(
              profile: _profile,
              activeIndex: _currentIndex,
              onDashboard: () => _drawerNavigate(0),
              onAssignments: () => _drawerNavigate(1),
              onPickups: () => _drawerOpen(_openPickups),
              onDeliveries: () => _drawerNavigate(2),
              onLastMile: () => _drawerOpen(_openLastMile),
              onScanner: () => _drawerOpen(_openStandaloneScanner),
              onEarnings: () => _drawerNavigate(3),
              onCod: () => _drawerOpen(_openRemittances),
              onHistory: () => _drawerOpen(_openHistory),
              onMessages: () => _drawerOpen(_openMessages),
              onNotifications: () => _drawerOpen(_openNotifications),
              onProfile: () => _drawerNavigate(4),
              onProfileSection: (section) => _drawerOpen(
                () => _openProfileSection(section),
              ),
              onLogout: () => _drawerOpen(_logoutFromDrawer),
              isDarkMode: _darkMode,
              onDarkModeChanged: _setDarkMode,
            ),
            endDrawerEnableOpenDragGesture: false,
            bottomNavigationBar:
                RiderBottomNav(
              currentIndex:
                  _currentIndex,
              onTap:
                  _changeTab,
            ),
          );
        },
      ),
    );
  }
}