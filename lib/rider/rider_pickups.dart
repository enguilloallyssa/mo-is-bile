
import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderPickups extends StatefulWidget {
  final List<RiderDelivery> orders;
  final ValueChanged<RiderDelivery> onAdvanceDelivery;
  final VoidCallback onOpenWorkflow;

  const RiderPickups({
    super.key,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
  });

  @override
  State<RiderPickups> createState() => _RiderPickupsState();
}

class _RiderPickupsState extends State<RiderPickups> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  static const List<String> _collectionStatuses = [
    'pickup_assigned',
    'pickup_accepted',
    'courier_accepted',
    'heading_seller',
    'heading_pickup',
    'arrived_seller',
    'arrived_pickup',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isCollection(RiderDelivery order) {
    return _collectionStatuses.contains(order.status);
  }

  int _stage(RiderDelivery order) {
    switch (order.status) {
      case 'pickup_assigned':
      case 'pickup_accepted':
      case 'courier_accepted':
        return 0;
      case 'heading_seller':
      case 'heading_pickup':
        return 1;
      case 'arrived_seller':
      case 'arrived_pickup':
        return 2;
      default:
        return -1;
    }
  }

  String _stageLabel(RiderDelivery order) {
    switch (_stage(order)) {
      case 0:
        return 'Assigned';
      case 1:
        return 'Heading to Seller';
      case 2:
        return 'At Seller';
      default:
        return order.statusLabel;
    }
  }

  List<RiderDelivery> get _orders {
    final query = _searchController.text.trim().toLowerCase();

    return widget.orders.where((order) {
      if (!_isCollection(order)) return false;

      final stage = _stage(order);

      if (_filter == 'Assigned' && stage != 0) {
        return false;
      }

      if (_filter == 'Heading' && stage != 1) {
        return false;
      }

      if (_filter == 'At Seller' && stage != 2) {
        return false;
      }

      if (query.isEmpty) return true;

      return [
        order.orderNumber,
        order.packageCode,
        order.sellerName,
        order.pickupName,
        order.pickupAddress,
        order.statusLabel,
      ].any(
        (value) => value.toLowerCase().contains(query),
      );
    }).toList();
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openScannerInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: RiderColors.blueSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: RiderColors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Parcel Scanner',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The Laravel Rider web app has a dedicated '
                  'Parcel Scanner page. In Flutter, parcel '
                  'scanning is available in the delivery '
                  'verification workflow. A dedicated mobile '
                  'scanner shortcut will be connected through '
                  'RiderShell.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionOrders =
        widget.orders.where(_isCollection).toList();

    final total = collectionOrders.length;

    final assigned = collectionOrders
        .where((order) => _stage(order) == 0)
        .length;

    final heading = collectionOrders
        .where((order) => _stage(order) == 1)
        .length;

    final arrived = collectionOrders
        .where((order) => _stage(order) == 2)
        .length;

    return Scaffold(
      backgroundColor: RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: RiderColors.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: RiderColors.text,
        elevation: 0,
        titleSpacing: 16,
        title: const RiderHeaderTitle(
          title: 'Seller Pickups',
          subtitle: 'Seller Collection Workflow',
        ),
        actions: [
          IconButton(
            tooltip: 'Parcel Scanner',
            onPressed: _openScannerInfo,
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
        children: [
          _hero(),
          const SizedBox(height: 20),
          _summary(
            total: total,
            assigned: assigned,
            heading: heading,
            arrived: arrived,
          ),
          const SizedBox(height: 25),
          _sectionHeader(total),
          const SizedBox(height: 15),
          _searchBar(),
          const SizedBox(height: 12),
          _filters(
            total: total,
            assigned: assigned,
            heading: heading,
            arrived: arrived,
          ),
          const SizedBox(height: 16),
          if (_orders.isEmpty)
            _emptyState()
          else
            ..._orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _pickupCard(order),
              ),
            ),
          const SizedBox(height: 12),
          _footer(_orders.length),
          const SizedBox(height: 15),
          _previewNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RiderColors.heroGradient,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Colors.white70,
                size: 17,
              ),
              SizedBox(width: 8),
              Text(
                'PICKUP OPERATIONS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Seller Pickups',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track Seller collections from assignment '
            'to pickup confirmation.',
            style: TextStyle(
              color: Color(0xFFE2E9ED),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _openScannerInfo,
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 18,
                ),
                label: const Text('Scan Parcel QR'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.white54,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onOpenWorkflow,
                icon: const Icon(
                  Icons.assignment_outlined,
                  size: 18,
                ),
                label: const Text('Assignments'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF263E4B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summary({
    required int total,
    required int assigned,
    required int heading,
    required int arrived,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _stat(
                'Total Pickups',
                total,
                'Collection stage',
                Icons.inventory_2_outlined,
                RiderColors.blue,
                RiderColors.blueSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                'Assigned',
                assigned,
                'Waiting to start',
                Icons.assignment_outlined,
                RiderColors.goldDark,
                RiderColors.goldSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _stat(
                'Heading to Seller',
                heading,
                'On the way',
                Icons.navigation_outlined,
                RiderColors.blue,
                RiderColors.blueSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _stat(
                'At Seller',
                arrived,
                'Confirm pickup',
                Icons.storefront_outlined,
                RiderColors.green,
                RiderColors.greenSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(
    String label,
    int count,
    String caption,
    IconData icon,
    Color accent,
    Color soft,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RiderColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            '$count',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            maxLines: 2,
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(int total) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: RiderColors.blueSoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.route_outlined,
            color: RiderColors.blue,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup Stage',
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Follow each collection through its current stage.',
                style: TextStyle(
                  color: RiderColors.muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        _statusBadge(
          '$total',
          RiderColors.blue,
          RiderColors.blueSoft,
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        color: RiderColors.text,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: 'Search order, seller, parcel...',
        hintStyle: TextStyle(
          color: RiderColors.muted,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: RiderColors.muted,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: RiderColors.field,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: RiderColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: RiderColors.blue),
        ),
      ),
    );
  }

  Widget _filters({
    required int total,
    required int assigned,
    required int heading,
    required int arrived,
  }) {
    final items = <(String, int)>[
      ('All', total),
      ('Assigned', assigned),
      ('Heading', heading),
      ('At Seller', arrived),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final selected = _filter == item.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${item.$1} (${item.$2})'),
              selected: selected,
              onSelected: (_) {
                setState(() => _filter = item.$1);
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
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pickupCard(RiderDelivery order) {
    final stage = _stage(order);

    final accent = stage == 2
        ? RiderColors.green
        : stage == 1
            ? RiderColors.blue
            : RiderColors.goldDark;

    final soft = stage == 2
        ? RiderColors.greenSoft
        : stage == 1
            ? RiderColors.blueSoft
            : RiderColors.goldSoft;

    return Container(
      decoration: BoxDecoration(
        color: RiderColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RiderColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(17),
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
                    _statusBadge(
                      _stageLabel(order),
                      accent,
                      soft,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  order.pickupName.isNotEmpty
                      ? order.pickupName
                      : order.sellerName,
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                _timeline(stage),
                const SizedBox(height: 20),
                Divider(color: RiderColors.border),
                const SizedBox(height: 12),
                _detail(
                  Icons.location_on_outlined,
                  'PICKUP ADDRESS',
                  order.pickupAddress.isEmpty
                      ? 'Pickup address unavailable'
                      : order.pickupAddress,
                ),
                const SizedBox(height: 15),
                _detail(
                  Icons.hub_outlined,
                  'NEXT HANDOFF',
                  'Confirm whether this parcel requires '
                  'origin hub intake or direct Buyer delivery.',
                ),
                const SizedBox(height: 12),
                _info(
                  'After pickup, the next step depends on '
                  'the order assigned by SARI Logistics. '
                  'Logistics pickups require physical '
                  'acceptance at the origin hub.',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            width: double.infinity,
            color: RiderColors.surfaceSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage == 2
                      ? 'Verify the parcel with the Seller '
                          'before continuing the handoff.'
                      : 'Follow the assigned collection stage '
                          'before advancing the order.',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openPickupDetails(order),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                    label: const Text(
                      'Open Pickup Workflow',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Parcel: ${order.packageCode}',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(int current) {
    const stages = [
      'Assigned',
      'Heading to Seller',
      'At Seller',
    ];

    return Row(
      children: List.generate(stages.length, (index) {
        final completed = index < current;
        final selected = index == current;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index <= current
                            ? RiderColors.green
                            : RiderColors.border,
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 220,
                    ),
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? RiderColors.green
                          : selected
                              ? RiderColors.blue
                              : RiderColors.surfaceSoft,
                      border: Border.all(
                        color: selected
                            ? RiderColors.blue
                            : RiderColors.border,
                      ),
                    ),
                    child: Center(
                      child: completed
                          ? const Icon(
                              Icons.check_rounded,
                              size: 17,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : RiderColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index < current
                            ? RiderColors.green
                            : RiderColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stages[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? RiderColors.blue
                      : RiderColors.muted,
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w900
                      : FontWeight.w600,
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
        Icon(
          icon,
          color: RiderColors.blue,
          size: 20,
        ),
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
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: RiderColors.text,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _info(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RiderColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
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

  Widget _statusBadge(
    String text,
    Color foreground,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _openPickupDetails(RiderDelivery order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pickup Workflow',
                  style: TextStyle(
                    color: RiderColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Order ${order.orderNumber}',
                  style: TextStyle(
                    color: RiderColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 17),
                _detail(
                  Icons.storefront_outlined,
                  'SELLER',
                  order.pickupName,
                ),
                const SizedBox(height: 14),
                _detail(
                  Icons.inventory_2_outlined,
                  'PARCEL CODE',
                  order.packageCode,
                ),
                const SizedBox(height: 14),
                _detail(
                  Icons.route_outlined,
                  'CURRENT STAGE',
                  _stageLabel(order),
                ),
                const SizedBox(height: 16),
                _info(
                  'This screen is a mobile preview. '
                  'Order-specific workflow navigation '
                  'must be connected in RiderShell '
                  'before enabling status updates.',
                ),
                const SizedBox(height: 19),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: RiderColors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return RiderEmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No Seller pickups in progress',
      message: 'Check Pickup Assignments for newly '
          'dispatched Seller collections.',
    );
  }

  Widget _footer(int count) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing $count '
            '${count == 1 ? 'pickup' : 'pickups'} '
            'at collection stage.',
            style: TextStyle(
              color: RiderColors.muted,
              fontSize: 11,
            ),
          ),
        ),
        TextButton(
          onPressed: widget.onOpenWorkflow,
          child: Text(
            'Assignments',
            style: TextStyle(
              color: RiderColors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: RiderColors.goldSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RiderColors.goldDark,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Preview mode: Pickup records are currently '
              'supplied by Flutter. This page does not '
              'submit delivery status changes to Laravel.',
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
}
