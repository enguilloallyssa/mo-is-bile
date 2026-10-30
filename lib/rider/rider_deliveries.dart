
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderDeliveries extends StatefulWidget {
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenHistory;
  final ValueChanged<RiderDelivery> onMarkSuccessful;
  final void Function(RiderDelivery, String) onMarkFailed;
  final ValueChanged<RiderDelivery> onReschedule;
  final ValueChanged<RiderDelivery> onReturnToSorting;
  final ValueChanged<RiderDelivery> onBuyerConfirmed;

  const RiderDeliveries({
    super.key,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    required this.onOpenHistory,
    required this.onMarkSuccessful,
    required this.onMarkFailed,
    required this.onReschedule,
    required this.onReturnToSorting,
    required this.onBuyerConfirmed,
  });

  @override
  State<RiderDeliveries> createState() => _RiderDeliveriesState();
}

class _RiderDeliveriesState extends State<RiderDeliveries> {
  final TextEditingController _search = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final Map<int, String> _scanned = {};
  final Map<int, XFile> _photos = {};

  String _filter = 'All';
  bool _cameraBusy = false;

  static const _deliveryStatuses = {
    'delivery_assigned',
    'delivery_accepted',
    'parcel_released',
    'out_for_delivery',
    'in_transit',
    'arrived_buyer',
    'delivery_failed',
    'returning_to_sorting',
    'delivered',
  };

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<RiderDelivery> get _allOrders {
    return widget.orders
        .where((order) => _deliveryStatuses.contains(order.status))
        .toList();
  }

  List<RiderDelivery> get _filteredOrders {
    final query = _search.text.trim().toLowerCase();

    return _allOrders.where((order) {
      final status = order.status;

      if (_filter == 'Assigned' &&
          !{'delivery_assigned', 'delivery_accepted'}
              .contains(status)) {
        return false;
      }

      if (_filter == 'On Route' &&
          !{'parcel_released', 'out_for_delivery', 'in_transit'}
              .contains(status)) {
        return false;
      }

      if (_filter == 'At Customer' && status != 'arrived_buyer') {
        return false;
      }

      if (_filter == 'Issues' &&
          !{'delivery_failed', 'returning_to_sorting'}
              .contains(status)) {
        return false;
      }

      if (query.isEmpty) return true;

      return [
        order.orderNumber,
        order.packageCode,
        order.buyerName,
        order.buyerAddress,
        order.sellerName,
        order.statusLabel,
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  void _notify(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RiderColors.surfaceElevated,
        ),
      );
  }

  Future<void> _scanParcel(RiderDelivery order) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => _RiderParcelScanner(
          expectedCode: order.packageCode,
        ),
      ),
    );

    if (!mounted || code == null) return;

    final scannedCode = code.trim().toUpperCase();
    final expected = order.packageCode.trim().toUpperCase();

    if (scannedCode != expected) {
      _notify('Incorrect parcel. The scanned code does not match.');
      return;
    }

    setState(() {
      _scanned[order.id] = scannedCode;
    });

    _notify('Parcel verified locally.');
  }

  Future<void> _capturePhoto(RiderDelivery order) async {
    if (_cameraBusy) return;

    setState(() => _cameraBusy = true);

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
      );

      if (!mounted || image == null) return;

      setState(() {
        _photos[order.id] = image;
      });

      _notify('Proof photo captured locally.');
    } catch (error) {
      _notify('Unable to capture photo: $error');
    } finally {
      if (mounted) {
        setState(() => _cameraBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = _allOrders;

    final assigned = all.where((o) {
      return o.status == 'delivery_assigned' ||
          o.status == 'delivery_accepted';
    }).length;

    final onRoute = all.where((o) {
      return o.status == 'out_for_delivery' ||
          o.status == 'in_transit' ||
          o.status == 'parcel_released';
    }).length;

    final arrived =
        all.where((o) => o.status == 'arrived_buyer').length;

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        foregroundColor: RiderColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Active Deliveries',
          subtitle: 'Customer Delivery Operations',
        ),
        actions: [
          IconButton(
            tooltip: 'Delivery History',
            onPressed: widget.onOpenHistory,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
        children: [
          _hero(),
          const SizedBox(height: 19),

          Row(
            children: [
              Expanded(
                child: _metric(
                  'Total',
                  '${all.length}',
                  Icons.inventory_2_outlined,
                  RiderColors.blue,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _metric(
                  'Assigned',
                  '$assigned',
                  Icons.assignment_outlined,
                  RiderColors.goldDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: _metric(
                  'On Route',
                  '$onRoute',
                  Icons.route_outlined,
                  RiderColors.purple,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _metric(
                  'At Customer',
                  '$arrived',
                  Icons.location_on_outlined,
                  RiderColors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          _sectionHeading(
            'Delivery Queue',
            'Manage assigned customer deliveries.',
          ),

          const SizedBox(height: 13),

          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: RiderColors.text),
            decoration: InputDecoration(
              hintText: 'Search order, parcel, customer...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: RiderColors.field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 12),
          _filters(),
          const SizedBox(height: 16),

          if (_filteredOrders.isEmpty)
            const RiderEmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'No deliveries found',
              message:
                  'Your assigned customer deliveries will appear here.',
            )
          else
            ..._filteredOrders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _deliveryCard(order),
              ),
            ),

          const SizedBox(height: 16),
          _integrationNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: RiderColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.white70,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'DELIVERY OPERATIONS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Active Deliveries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track customer deliveries, verify parcels, '
            'and prepare proof of delivery.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    String title,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    const filters = [
      'All',
      'Assigned',
      'On Route',
      'At Customer',
      'Issues',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = filter == _filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _filter = filter);
              },
              backgroundColor: RiderColors.surface,
              selectedColor: RiderColors.blueSoft,
              side: BorderSide(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? RiderColors.blue
                    : RiderColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _deliveryCard(RiderDelivery order) {
    final isAtCustomer = order.status == 'arrived_buyer';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.orderNumber,
                        style: TextStyle(
                          color: RiderColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Flexible(
                      child: RiderStatusPill(
                        label: order.statusLabel,
                        color: riderStatusColor(order.status),
                        background:
                            riderStatusSoftColor(order.status),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  'Parcel: ${order.packageCode}',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),

                _progress(order),

                const SizedBox(height: 19),

                Divider(color: RiderColors.border),

                const SizedBox(height: 12),

                _detail(
                  Icons.person_outline_rounded,
                  'CUSTOMER',
                  order.buyerName,
                ),

                const SizedBox(height: 15),

                _detail(
                  Icons.location_on_outlined,
                  'DELIVERY ADDRESS',
                  order.buyerAddress.isEmpty
                      ? 'Address unavailable'
                      : order.buyerAddress,
                ),

                const SizedBox(height: 15),

                _detail(
                  Icons.storefront_outlined,
                  'SELLER',
                  order.sellerName,
                ),

                const SizedBox(height: 14),

                Text(
                  order.actionMessage,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                if (order.failureReason != null) ...[
                  const SizedBox(height: 12),
                  _message(
                    'Issue: ${order.failureReason}',
                    RiderColors.redSoft,
                  ),
                ],
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: RiderColors.surfaceSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isAtCustomer)
                  _proofSection(order)
                else
                  _normalActions(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(RiderDelivery order) {
    const stages = [
      'Assigned',
      'Picked Up',
      'On Route',
      'Customer',
      'Delivered',
    ];

    int current;

    switch (order.status) {
      case 'delivery_assigned':
        current = 0;
        break;

      case 'delivery_accepted':
      case 'parcel_released':
        current = 1;
        break;

      case 'out_for_delivery':
      case 'in_transit':
        current = 2;
        break;

      case 'arrived_buyer':
      case 'delivery_failed':
      case 'returning_to_sorting':
        current = 3;
        break;

      default:
        current = 4;
    }

    return Row(
      children: List.generate(stages.length, (index) {
        final completed = index < current;
        final active = index == current;

        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? RiderColors.green
                      : active
                          ? RiderColors.blue
                          : RiderColors.surfaceSoft,
                  border: Border.all(
                    color: active
                        ? RiderColors.blue
                        : RiderColors.border,
                  ),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : Icons.circle,
                  size: completed ? 17 : 8,
                  color: completed || active
                      ? Colors.white
                      : RiderColors.muted,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                stages[index],
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: active
                      ? RiderColors.blue
                      : RiderColors.muted,
                  fontWeight: active
                      ? FontWeight.w900
                      : FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _detail(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RiderColors.blue, size: 21),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _proofSection(RiderDelivery order) {
    final verified = _scanned.containsKey(order.id);
    final photo = _photos[order.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Customer Handoff Verification',
          style: TextStyle(
            color: RiderColors.text,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'Scan the assigned parcel and capture a photo '
          'before completing the customer handoff.',
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () => _scanParcel(order),
          icon: Icon(
            verified
                ? Icons.check_circle_rounded
                : Icons.qr_code_scanner_rounded,
          ),
          label: Text(
            verified
                ? 'Parcel Verified • Scan Again'
                : '1. Scan Parcel QR / Barcode',
          ),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: verified && !_cameraBusy
              ? () => _capturePhoto(order)
              : null,
          icon: Icon(
            photo == null
                ? Icons.camera_alt_outlined
                : Icons.check_circle_rounded,
          ),
          label: Text(
            photo == null
                ? '2. Capture Proof of Delivery'
                : 'Photo Captured • Retake',
          ),
        ),

        if (photo != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: RiderColors.green,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  photo.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: RiderColors.green,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 15),

        _message(
          verified && photo != null
              ? 'Verification and photo are ready locally. '
                  'They have not been uploaded to Laravel.'
              : 'Parcel scan and delivery photo are required '
                  'before server-confirmed delivery completion.',
          RiderColors.blueSoft,
        ),

        const SizedBox(height: 13),

        FilledButton.icon(
          onPressed: null,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text(
            'Submit Proof & Confirm Delivery',
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Submission will be enabled when the '
          'Laravel Rider proof-of-delivery API is connected.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 10,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _normalActions(RiderDelivery order) {
    final status = order.status;

    if (status == 'delivered') {
      return _message(
        'Delivery handoff recorded in the loaded data. '
        'Awaiting buyer receipt confirmation.',
        RiderColors.greenSoft,
      );
    }

    if (status == 'delivery_failed' ||
        status == 'returning_to_sorting') {
      return _message(
        'This delivery needs Logistics follow-up. '
        'Reschedule and return actions require server integration.',
        RiderColors.redSoft,
      );
    }

    if (order.nextStatus == null) {
      return _message(
        'No further rider action is available.',
        RiderColors.blueSoft,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _previewAdvance(order),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(order.actionLabel.isEmpty
              ? 'Continue Workflow'
              : order.actionLabel),
          style: FilledButton.styleFrom(
            backgroundColor: RiderColors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preview action only. This does not update Laravel.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: RiderColors.muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Future<void> _previewAdvance(RiderDelivery order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Preview Workflow'),
        content: Text(
          'Continue "${order.actionLabel}" for '
          '${order.orderNumber}?\n\n'
          'This only updates the current Flutter demo state. '
          'It will not be saved to Laravel.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Continue Preview'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    widget.onAdvanceDelivery(order);
  }

  Widget _message(String message, Color background) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.blue,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: RiderColors.text,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _integrationNotice() {
    return _message(
      'Mobile preview: delivery records currently come from '
      'the Flutter app. The updated Laravel web separates '
      'Direct Deliveries and Last-Mile Batches. '
      'Live assignment data, proof upload, and final status '
      'updates require the corresponding mobile APIs.',
      RiderColors.goldSoft,
    );
  }
}

class _RiderParcelScanner extends StatefulWidget {
  const _RiderParcelScanner({
    required this.expectedCode,
  });

  final String expectedCode;

  @override
  State<_RiderParcelScanner> createState() =>
      _RiderParcelScannerState();
}

class _RiderParcelScannerState
    extends State<_RiderParcelScanner> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Parcel Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Scan Parcel QR / Barcode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Expected: ${widget.expectedCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: MobileScanner(
                onDetect: (capture) {
                  if (_handled) return;

                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;

                    if (value == null ||
                        value.trim().isEmpty) {
                      continue;
                    }

                    _handled = true;

                    Navigator.of(context).pop(value);
                    return;
                  }
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Point your camera at the parcel label. '
              'Only a matching code will be accepted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
