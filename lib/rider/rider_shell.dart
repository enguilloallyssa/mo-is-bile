import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
import 'rider_pickups.dart';
import 'rider_profile.dart';
import 'rider_remittances.dart';
import 'rider_requests.dart';
import 'rider_scanner.dart';
import 'widgets/rider_bottom_nav.dart';
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
  final ImagePicker _imagePicker =
      ImagePicker();

  int _currentIndex = 0;

  bool _darkMode = false;
  bool _loading = true;
  bool _refreshing = false;

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
    final data =
        _map(raw);

    final actions = _list(
      data['allowed_actions'],
    )
        .map(
          (value) =>
              '$value',
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
          key.contains('destination')) {
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
      pickupLatitude: coordinate(
        pickupStop,
        'lat',
      ),
      pickupLongitude: coordinate(
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
      sortingCenterLatitude: coordinate(
        hubStop,
        'lat',
      ),
      sortingCenterLongitude: coordinate(
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
      buyerLatitude: coordinate(
        buyerStop,
        'lat',
      ),
      buyerLongitude: coordinate(
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
      allowedActions: actions,
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
          rating <= 0
              ? 5
              : rating,
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
      parcels:
          const [],
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
            await SariLiveData.instance
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
                      parcel.id >
                      0,
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
            facilityAddress: _text(
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
      dashboard['current_assignment'],
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
    if (_refreshing) {
      return;
    }

    final firstLoad =
        _assignments.isEmpty &&
        _lastMileBatches.isEmpty &&
        _dashboardSummary.isEmpty;

    if (mounted) {
      setState(() {
        _refreshing = true;

        if (firstLoad) {
          _loading = true;
        }

        _error = null;
      });
    }

    try {
      final results =
          await Future.wait<
              Map<String, dynamic>>(
        [
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderDashboard(),
          ),
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderProfile(),
          ),
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderAssignments(),
          ),
          _safeJson(
            () =>
                SariLiveData
                    .instance
                    .riderLastMile(),
          ),
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

      if (results.every(
        (
          result,
        ) =>
            result.isEmpty,
      )) {
        throw const FormatException(
          'Unable to load the Rider workspace from SARI.',
        );
      }

      final dashboardData =
          _map(
        results[0]['data'],
      );

      final profileData =
          _map(
        results[1]['data'],
      );

      final assignmentRows =
          _list(
        results[2]['data'],
      );

      final lastMileRows =
          _list(
        results[3]['data'],
      );

      final earningsData =
          _map(
        results[4]['data'],
      );

      final transactionRows =
          _list(
        results[5]['data'],
      );

      final assignments =
          <RiderDelivery>[];

      for (final raw
          in assignmentRows) {
        final summary =
            _map(raw);

        final id =
            _int(
          summary['id'],
        );

        if (id <= 0) {
          continue;
        }

        try {
          final details =
              await SariLiveData
                  .instance
                  .riderAssignment(
            id,
          );

          assignments.add(
            _delivery(
              details['data'],
            ),
          );
        } catch (_) {
          assignments.add(
            _delivery(
              summary,
            ),
          );
        }
      }

      final lastMileBatches =
          await _loadLastMileBatches(
        lastMileRows,
      );

      final daily =
          _list(
        earningsData['daily'],
      ).map(
        (
          raw,
        ) {
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
      ).toList();

      final transactions =
          transactionRows.map(
        (
          raw,
        ) {
          final data =
              _map(raw);

          return RiderEarningTransaction(
            order: _text(
              data['order_number'],
              'Order',
            ),
            date: _text(
              data['earned_at'],
            ),
            type: _text(
              data['earning_type'],
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
      ).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        if (profileData.isNotEmpty) {
          _profile =
              _profileFrom(
            profileData,
          );
        }

        if (dashboardData.isNotEmpty) {
          _dashboardSummary =
              _map(
            dashboardData['summary'],
          );
        }

        if (results[2].isNotEmpty) {
          _assignments
            ..clear()
            ..addAll(
              assignments,
            );
        }

        if (results[3].isNotEmpty) {
          _lastMileBatches
            ..clear()
            ..addAll(
              lastMileBatches,
            );
        }

        if (results[4].isNotEmpty) {
          _dailyEarnings
            ..clear()
            ..addAll(
              daily,
            );
        }

        if (results[5].isNotEmpty) {
          _transactions
            ..clear()
            ..addAll(
              transactions,
            );
        }

        _currentDelivery =
            _resolveCurrentDelivery(
          _assignments,
          dashboardData,
        );

        _loading = false;
        _refreshing = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _refreshing = false;
        _error =
            error.toString();
      });
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
    });
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
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
        await Navigator.of(context)
            .push<String>(
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
          await SariLiveData.instance
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
    XFile? photo;

    try {
      photo =
          await _imagePicker
              .pickImage(
        source:
            ImageSource.camera,
        imageQuality: 82,
        maxWidth: 1800,
      );
    } catch (error) {
      _toast(
        'Unable to open the camera: $error',
      );

      return false;
    }

    if (!mounted ||
        photo == null) {
      return false;
    }

    final recipientController =
        TextEditingController(
      text:
          recipientName ?? '',
    );

    final notesController =
        TextEditingController();

    final submit =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title:
              const Text(
            'Proof of Delivery',
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        RiderColors
                            .greenSoft,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .photo_camera_outlined,
                        color:
                            RiderColors
                                .green,
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          'Photo captured for $orderNumber',
                          style:
                              TextStyle(
                            color:
                                RiderColors
                                    .text,
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                TextField(
                  controller:
                      recipientController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Recipient Name (optional)',
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextField(
                  controller:
                      notesController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 1000,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Delivery Notes (optional)',
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'The captured image will be uploaded to the authenticated SARI Rider delivery proof endpoint.',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 9,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                false,
              ),
              child:
                  const Text(
                'Cancel',
              ),
            ),

            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(
                dialogContext,
              ).pop(
                true,
              ),
              icon:
                  const Icon(
                Icons
                    .cloud_upload_outlined,
              ),
              label:
                  const Text(
                'Upload Proof',
              ),
            ),
          ],
        );
      },
    );

    if (submit != true ||
        !mounted) {
      recipientController
          .dispose();

      notesController
          .dispose();

      return false;
    }

    final recipient =
        recipientController.text
            .trim();

    final notes =
        notesController.text
            .trim();

    recipientController.dispose();
    notesController.dispose();

    try {
      final response =
          await SariLiveData.instance
              .riderProof(
        orderId:
            orderId,
        photo:
            File(
          photo.path,
        ),
        recipientName:
            recipient.isEmpty
                ? null
                : recipient,
        notes:
            notes.isEmpty
                ? null
                : notes,
      );

      _toast(
        _text(
          response['message'],
          'Proof of delivery saved.',
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

  Future<bool> _verifyAndCaptureProof(
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

    return _captureProof(
      orderId:
          delivery.id,
      orderNumber:
          delivery.orderNumber,
      recipientName:
          delivery.buyerName,
    );
  }

  Future<void> _advanceDelivery(
    RiderDelivery delivery,
  ) async {
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
      if (action == 'complete') {
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
          await SariLiveData.instance
              .riderProceedPickup(
            delivery.id,
          ),

        'arrived_pickup' =>
          await SariLiveData.instance
              .riderArrivedPickup(
            delivery.id,
          ),

        'confirm_pickup' =>
          await SariLiveData.instance
              .riderConfirmPickup(
            delivery.id,
          ),

        'arrived_buyer' =>
          await SariLiveData.instance
              .riderArrivedBuyer(
            delivery.id,
          ),

        'complete' =>
          await SariLiveData.instance
              .riderComplete(
            delivery.id,
          ),

        _ =>
          <String, dynamic>{},
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
          await SariLiveData.instance
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

  void _unsupported(
    String label,
  ) {
    _toast(
      '$label is not exposed by the current Laravel Rider API.',
    );
  }

  Future<void> _openMessages()
      async {
    await Navigator.of(context).push(
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
                  : TimeOfDay.fromDateTime(
                      dateTime,
                    ).format(
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
    await Navigator.of(context).push(
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
    await Navigator.of(context).push(
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
            Navigator.of(context)
                .pop();

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
          await SariLiveData.instance
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

  Future<void> _completeLastMileParcel(
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

    try {
      final response =
          await SariLiveData.instance
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
                  const EdgeInsets.fromLTRB(
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
                          RiderColors
                              .muted,
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
                const EdgeInsets.fromLTRB(
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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (
          context,
        ) =>
            RiderLastMile(
          batches:
              _lastMileBatches,
          onBackToDashboard: () {
            Navigator.of(context)
                .pop();

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
    await Navigator.of(context).push(
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

  void _openMoreFeatures() {
    showModalBottomSheet<void>(
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
                const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .inventory_2_outlined,
                  ),
                  title:
                      const Text(
                    'Seller Pickups',
                  ),
                  subtitle:
                      const Text(
                    'Seller collection workflow',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openPickups();
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .route_outlined,
                  ),
                  title:
                      const Text(
                    'Last-Mile Deliveries',
                  ),
                  subtitle:
                      const Text(
                    'Destination hub to Buyer',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openLastMile();
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .qr_code_scanner_rounded,
                  ),
                  title:
                      const Text(
                    'Parcel Scanner',
                  ),
                  subtitle:
                      const Text(
                    'Verify an assigned parcel',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openStandaloneScanner();
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .account_balance_outlined,
                  ),
                  title:
                      const Text(
                    'COD Remittance',
                  ),
                  subtitle:
                      const Text(
                    'Prepare collected COD cash',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openRemittances();
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .history_rounded,
                  ),
                  title:
                      const Text(
                    'Delivery History',
                  ),
                  subtitle:
                      const Text(
                    'Completed Rider trips',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openHistory();
                  },
                ),

                ListTile(
                  leading:
                      const Icon(
                    Icons
                        .chat_bubble_outline,
                  ),
                  title:
                      const Text(
                    'Messages',
                  ),
                  subtitle:
                      const Text(
                    'SARI Logistics communication',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _openMessages();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color:
                  RiderColors.gold,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              'Loading Rider workspace...',
              style:
                  TextStyle(
                color:
                    RiderColors.muted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
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
      data: theme,
      child: Builder(
        builder: (
          context,
        ) {
          if (_loading) {
            return _loadingScreen();
          }

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
                  _openMoreFeatures,
              onOpenHistory:
                  _openHistory,
              onMarkSuccessful:
                  _markSuccessful,
              onMarkFailed:
                  (
                _,
                __,
              ) =>
                      _unsupported(
                'Failed delivery submission',
              ),
              onReschedule:
                  (_) =>
                      _unsupported(
                'Rescheduling',
              ),
              onReturnToSorting:
                  (_) =>
                      _unsupported(
                'Return to sorting',
              ),
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
            ),
          ];

          return Scaffold(
            backgroundColor:
                RiderColors.bg,
            body: Stack(
              children: [
                IndexedStack(
                  index:
                      _currentIndex,
                  children:
                      pages,
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
                      minHeight:
                          2,
                    ),
                  ),
              ],
            ),
            bottomNavigationBar:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    2,
                    16,
                    4,
                  ),
                  child: Align(
                    alignment:
                        Alignment
                            .centerRight,
                    child:
                        TextButton.icon(
                      onPressed:
                          _openMoreFeatures,
                      icon:
                          const Icon(
                        Icons
                            .apps_rounded,
                      ),
                      label:
                          const Text(
                        'More Rider Features',
                      ),
                    ),
                  ),
                ),

                RiderBottomNav(
                  currentIndex:
                      _currentIndex,
                  onTap:
                      _changeTab,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}