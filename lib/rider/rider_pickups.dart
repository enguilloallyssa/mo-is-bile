import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderPickups extends StatefulWidget {
  final List<RiderDelivery> orders;

  final ValueChanged<RiderDelivery> onAdvanceDelivery;

  final VoidCallback onOpenWorkflow;

  final VoidCallback? onOpenScanner;

  const RiderPickups({
    super.key,
    required this.orders,
    required this.onAdvanceDelivery,
    required this.onOpenWorkflow,
    this.onOpenScanner,
  });

  @override
  State<RiderPickups> createState() =>
      _RiderPickupsState();
}

class _RiderPickupsState extends State<RiderPickups> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  static const List<String> _pickupStatuses = [
    // Current Laravel Rider API.
    'courier_accepted',
    'heading_pickup',
    'arrived_pickup',

    // Legacy compatibility.
    'pickup_assigned',
    'pickup_accepted',
    'heading_seller',
    'arrived_seller',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isPickup(
    RiderDelivery order,
  ) {
    return _pickupStatuses.contains(
      order.status,
    );
  }

  int _stage(
    RiderDelivery order,
  ) {
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

  String _stageLabel(
    RiderDelivery order,
  ) {
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

  List<RiderDelivery> get _filteredOrders {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    return widget.orders.where(
      (order) {
        if (!_isPickup(order)) {
          return false;
        }

        final stage = _stage(order);

        if (_filter == 'Assigned' &&
            stage != 0) {
          return false;
        }

        if (_filter == 'Heading' &&
            stage != 1) {
          return false;
        }

        if (_filter == 'At Seller' &&
            stage != 2) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final values = [
          order.orderNumber,
          order.packageCode,
          order.sellerName,
          order.pickupName,
          order.pickupAddress,
          order.statusLabel,
        ];

        return values.any(
          (value) => value
              .toLowerCase()
              .contains(query),
        );
      },
    ).toList();
  }

  List<RiderDelivery> get _allPickupOrders {
    return widget.orders
        .where(_isPickup)
        .toList();
  }

  void _openScanner() {
    if (widget.onOpenScanner != null) {
      widget.onOpenScanner!();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor:
          RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              22,
              10,
              22,
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
                        RiderColors
                            .blueSoft,
                    borderRadius:
                        BorderRadius.circular(
                      19,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .qr_code_scanner_rounded,
                    color:
                        RiderColors.blue,
                    size: 31,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'Parcel Scanner',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Use the Rider parcel scanner to verify the QR or barcode assigned to your pickup.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 11,
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
                      FilledButton(
                    onPressed: () =>
                        Navigator.of(
                          sheetContext,
                        ).pop(),
                    child:
                        const Text(
                      'Close',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _advance(
    RiderDelivery order,
  ) async {
    if (order.actionLabel
        .trim()
        .isEmpty) {
      return;
    }

    // onAdvanceDelivery is ValueChanged<RiderDelivery>,
    // therefore it returns void.
    // Do not use await here.
    widget.onAdvanceDelivery(
      order,
    );
  }

  void _openDetails(
    RiderDelivery order,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor:
          RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child:
              SingleChildScrollView(
            padding:
                EdgeInsets.fromLTRB(
              18,
              5,
              18,
              24 +
                  MediaQuery.of(
                    sheetContext,
                  ).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color:
                            RiderColors
                                .blueSoft,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: Icon(
                        Icons
                            .inventory_2_outlined,
                        color:
                            RiderColors
                                .blue,
                        size: 21,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            order
                                .orderNumber,
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .text,
                              fontSize:
                                  17,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            _stageLabel(
                              order,
                            ),
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .blue,
                              fontSize:
                                  10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                _sheetSection(
                  icon: Icons
                      .storefront_outlined,
                  label: 'Seller',
                  value: order
                          .sellerName
                          .trim()
                          .isNotEmpty
                      ? order
                          .sellerName
                      : order
                          .pickupName,
                ),

                const SizedBox(
                  height: 14,
                ),

                _sheetSection(
                  icon: Icons
                      .location_on_outlined,
                  label:
                      'Pickup Address',
                  value: order
                          .pickupAddress
                          .trim()
                          .isNotEmpty
                      ? order
                          .pickupAddress
                      : 'Pickup address unavailable',
                ),

                if (order.packageCode
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 14,
                  ),
                  _sheetSection(
                    icon: Icons
                        .qr_code_2_rounded,
                    label:
                        'Parcel Code',
                    value: order
                        .packageCode,
                  ),
                ],

                const SizedBox(
                  height: 18,
                ),

                _workflowNotice(
                  order,
                ),

                const SizedBox(
                  height: 18,
                ),

                _timeline(
                  _stage(order),
                ),

                const SizedBox(
                  height: 22,
                ),

                if (order.actionLabel
                    .trim()
                    .isNotEmpty)
                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        await _advance(
                          order,
                        );
                      },
                      icon: Icon(
                        _actionIcon(
                          order,
                        ),
                      ),
                      label: Text(
                        order
                            .actionLabel,
                      ),
                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            RiderColors
                                .blue,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical:
                              14,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 9,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        _openScanner,
                    icon:
                        const Icon(
                      Icons
                          .qr_code_scanner_rounded,
                    ),
                    label:
                        const Text(
                      'Open Parcel Scanner',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _actionIcon(
    RiderDelivery order,
  ) {
    switch (order.status) {
      case 'courier_accepted':
      case 'pickup_assigned':
      case 'pickup_accepted':
        return Icons
            .navigation_rounded;

      case 'heading_pickup':
      case 'heading_seller':
        return Icons
            .storefront_rounded;

      case 'arrived_pickup':
      case 'arrived_seller':
        return Icons
            .inventory_2_rounded;

      default:
        return Icons
            .arrow_forward_rounded;
    }
  }

  Widget _sheetSection({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color:
              RiderColors.blue,
          size: 20,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                label.toUpperCase(),
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      .7,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                value,
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 11,
                  height: 1.45,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workflowNotice(
    RiderDelivery order,
  ) {
    String message;

    switch (_stage(order)) {
      case 0:
        message =
            'Proceed to the Seller pickup location before confirming arrival.';
        break;

      case 1:
        message =
            'You are heading to the Seller. Confirm arrival only when you reach the pickup location.';
        break;

      case 2:
        message =
            'Verify the assigned parcel before confirming pickup.';
        break;

      default:
        message =
            order.actionMessage;
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.blueSoft,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .info_outline_rounded,
            color:
                RiderColors.blue,
            size: 19,
          ),
          const SizedBox(
            width: 9,
          ),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final all =
        _allPickupOrders;

    final assigned = all
        .where(
          (order) =>
              _stage(order) == 0,
        )
        .length;

    final heading = all
        .where(
          (order) =>
              _stage(order) == 1,
        )
        .length;

    final arrived = all
        .where(
          (order) =>
              _stage(order) == 2,
        )
        .length;

    final orders =
        _filteredOrders;

    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        backgroundColor:
            RiderColors.surface,
        surfaceTintColor:
            Colors.transparent,
        foregroundColor:
            RiderColors.text,
        elevation: 0,
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title: 'Seller Pickups',
          subtitle:
              'Seller Collection Workflow',
        ),
        actions: [
          IconButton(
            tooltip:
                'Parcel Scanner',
            onPressed:
                _openScanner,
            icon: const Icon(
              Icons
                  .qr_code_scanner_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          34,
        ),
        children: [
          _hero(),

          const SizedBox(
            height: 20,
          ),

          _summary(
            total:
                all.length,
            assigned:
                assigned,
            heading:
                heading,
            arrived:
                arrived,
          ),

          const SizedBox(
            height: 25,
          ),

          _sectionHeader(
            all.length,
          ),

          const SizedBox(
            height: 15,
          ),

          _searchBar(),

          const SizedBox(
            height: 12,
          ),

          _filters(
            total:
                all.length,
            assigned:
                assigned,
            heading:
                heading,
            arrived:
                arrived,
          ),

          const SizedBox(
            height: 16,
          ),

          if (orders.isEmpty)
            _emptyState()
          else
            ...orders.map(
              (order) =>
                  Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 13,
                ),
                child:
                    _pickupCard(
                  order,
                ),
              ),
            ),

          const SizedBox(
            height: 9,
          ),

          _footer(
            orders.length,
          ),

          const SizedBox(
            height: 15,
          ),

          _apiNotice(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding:
          const EdgeInsets.all(
        21,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors:
              RiderColors
                  .heroGradient,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .inventory_2_outlined,
                color:
                    Colors.white70,
                size: 17,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'PICKUP OPERATIONS',
                style:
                    TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      1.3,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'Seller Pickups',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize: 27,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Follow each Seller collection from assignment to confirmed parcel pickup.',
            style: TextStyle(
              color:
                  Color(
                0xFFE2E9ED,
              ),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 19,
          ),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    _openScanner,
                icon:
                    const Icon(
                  Icons
                      .qr_code_scanner_rounded,
                  size: 18,
                ),
                label:
                    const Text(
                  'Scan Parcel',
                ),
                style:
                    OutlinedButton
                        .styleFrom(
                  foregroundColor:
                      Colors.white,
                  side:
                      const BorderSide(
                    color:
                        Colors.white54,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed:
                    widget
                        .onOpenWorkflow,
                icon:
                    const Icon(
                  Icons
                      .assignment_outlined,
                  size: 18,
                ),
                label:
                    const Text(
                  'Assignments',
                ),
                style:
                    FilledButton
                        .styleFrom(
                  backgroundColor:
                      Colors.white,
                  foregroundColor:
                      Color(
                    0xFF263E4B,
                  ),
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
                label:
                    'Total Pickups',
                value: total,
                caption:
                    'Active collection stage',
                icon: Icons
                    .inventory_2_outlined,
                accent:
                    RiderColors.blue,
                soft:
                    RiderColors
                        .blueSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _stat(
                label:
                    'Assigned',
                value:
                    assigned,
                caption:
                    'Waiting to start',
                icon: Icons
                    .assignment_outlined,
                accent:
                    RiderColors
                        .goldDark,
                soft:
                    RiderColors
                        .goldSoft,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: _stat(
                label:
                    'Heading',
                value:
                    heading,
                caption:
                    'Going to Seller',
                icon: Icons
                    .navigation_outlined,
                accent:
                    RiderColors.blue,
                soft:
                    RiderColors
                        .blueSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _stat(
                label:
                    'At Seller',
                value:
                    arrived,
                caption:
                    'Pickup confirmation',
                icon: Icons
                    .storefront_outlined,
                accent:
                    RiderColors.green,
                soft:
                    RiderColors
                        .greenSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat({
    required String label,
    required int value,
    required String caption,
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.all(
              9,
            ),
            decoration:
                BoxDecoration(
              color: soft,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '$value',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 25,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            label,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            caption,
            maxLines: 2,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    int total,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color:
                RiderColors.blueSoft,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            Icons.route_outlined,
            color:
                RiderColors.blue,
          ),
        ),
        const SizedBox(
          width: 11,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup Stage',
                style:
                    TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Follow each active Seller collection.',
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
        _badge(
          '$total',
          RiderColors.blueSoft,
          RiderColors.blue,
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller:
          _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration:
          InputDecoration(
        hintText:
            'Search order, seller, parcel...',
        prefixIcon:
            const Icon(
          Icons.search_rounded,
        ),
        suffixIcon:
            _searchController
                    .text
                    .isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      setState(
                        () {},
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .close_rounded,
                    ),
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
    final values =
        <(String, int)>[
      ('All', total),
      ('Assigned', assigned),
      ('Heading', heading),
      ('At Seller', arrived),
    ];

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        children: values.map(
          (item) {
            final selected =
                _filter ==
                    item.$1;

            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 7,
              ),
              child: ChoiceChip(
                label: Text(
                  '${item.$1} (${item.$2})',
                ),
                selected:
                    selected,
                showCheckmark:
                    false,
                onSelected: (_) {
                  setState(() {
                    _filter =
                        item.$1;
                  });
                },
                backgroundColor:
                    RiderColors
                        .surface,
                selectedColor:
                    RiderColors
                        .blueSoft,
                side:
                    BorderSide(
                  color: selected
                      ? RiderColors
                          .blue
                      : RiderColors
                          .border,
                ),
                labelStyle:
                    TextStyle(
                  color: selected
                      ? RiderColors
                          .blue
                      : RiderColors
                          .muted,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget _pickupCard(
    RiderDelivery order,
  ) {
    final stage =
        _stage(order);

    late final Color accent;
    late final Color soft;

    if (stage == 0) {
      accent =
          RiderColors.goldDark;
      soft =
          RiderColors.goldSoft;
    } else if (stage == 1) {
      accent =
          RiderColors.blue;
      soft =
          RiderColors.blueSoft;
    } else {
      accent =
          RiderColors.green;
      soft =
          RiderColors.greenSoft;
    }

    final pickupName =
        order.pickupName
                .trim()
                .isNotEmpty
            ? order.pickupName
            : order.sellerName;

    return Container(
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          19,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order
                            .orderNumber,
                        style:
                            TextStyle(
                          color:
                              RiderColors
                                  .text,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                    _badge(
                      _stageLabel(
                        order,
                      ),
                      soft,
                      accent,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  pickupName,
                  style:
                      TextStyle(
                    color:
                        RiderColors
                            .muted,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                _timeline(stage),

                const SizedBox(
                  height: 18,
                ),

                Divider(
                  color:
                      RiderColors.border,
                ),

                const SizedBox(
                  height: 11,
                ),

                _location(
                  icon: Icons
                      .storefront_outlined,
                  label:
                      'SELLER PICKUP',
                  name:
                      pickupName,
                  address: order
                          .pickupAddress
                          .trim()
                          .isNotEmpty
                      ? order
                          .pickupAddress
                      : 'Pickup address unavailable',
                  accent:
                      RiderColors.blue,
                ),

                if (order
                    .packageCode
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 13,
                  ),
                  _location(
                    icon: Icons
                        .qr_code_2_rounded,
                    label:
                        'PARCEL CODE',
                    name: order
                        .packageCode,
                    address:
                        'Use the scanner to verify this parcel when required.',
                    accent:
                        RiderColors
                            .goldDark,
                  ),
                ],

                const SizedBox(
                  height: 13,
                ),

                _workflowNotice(
                  order,
                ),
              ],
            ),
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets.all(
              13,
            ),
            color:
                RiderColors.surfaceSoft,
            child: Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () =>
                        _openDetails(
                      order,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .visibility_outlined,
                      size: 17,
                    ),
                    label:
                        const Text(
                      'Details',
                    ),
                  ),
                ),
                if (order.actionLabel
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                        FilledButton.icon(
                      onPressed: () =>
                          _advance(
                        order,
                      ),
                      icon: Icon(
                        _actionIcon(
                          order,
                        ),
                        size: 17,
                      ),
                      label: Text(
                        order
                            .actionLabel,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                      ),
                      style:
                          FilledButton
                              .styleFrom(
                        backgroundColor:
                            RiderColors
                                .blue,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(
    int current,
  ) {
    const labels = [
      'Assigned',
      'Heading',
      'At Seller',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final done =
              index < current;

          final active =
              index == current;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child:
                            Container(
                          height: 2,
                          color: index <=
                                  current
                              ? RiderColors
                                  .green
                              : RiderColors
                                  .border,
                        ),
                      ),

                    Container(
                      width: 30,
                      height: 30,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: done
                            ? RiderColors
                                .green
                            : active
                                ? RiderColors
                                    .blue
                                : RiderColors
                                    .surfaceSoft,
                        border:
                            Border.all(
                          color: done
                              ? RiderColors
                                  .green
                              : active
                                  ? RiderColors
                                      .blue
                                  : RiderColors
                                      .border,
                        ),
                      ),
                      child: done
                          ? const Icon(
                              Icons
                                  .check_rounded,
                              color:
                                  Colors.white,
                              size: 16,
                            )
                          : Text(
                              '${index + 1}',
                              style:
                                  TextStyle(
                                color: active
                                    ? Colors
                                        .white
                                    : RiderColors
                                        .muted,
                                fontSize:
                                    10,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                    ),

                    if (index <
                        labels.length - 1)
                      Expanded(
                        child:
                            Container(
                          height: 2,
                          color: index <
                                  current
                              ? RiderColors
                                  .green
                              : RiderColors
                                  .border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  labels[index],
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color: active
                        ? RiderColors
                            .blue
                        : RiderColors
                            .muted,
                    fontSize: 8,
                    fontWeight: active
                        ? FontWeight
                            .w800
                        : FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _location({
    required IconData icon,
    required String label,
    required String name,
    required String address,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: accent,
          size: 22,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                label,
                style:
                    TextStyle(
                  color: accent,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing:
                      .7,
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                name,
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
                address,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 9,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badge(
    String text,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style:
            TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        30,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .inventory_2_outlined,
            color:
                RiderColors.muted,
            size: 45,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            'No Seller pickups found',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 14,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'New Seller pickup assignments will appear here when dispatched by SARI Logistics.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(
    int count,
  ) {
    return Text(
      'Showing $count active Seller '
      '${count == 1 ? 'pickup' : 'pickups'}.',
      style: TextStyle(
        color:
            RiderColors.muted,
        fontSize: 9,
      ),
    );
  }

  Widget _apiNotice() {
    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.goldSoft,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .verified_user_outlined,
            color:
                RiderColors.goldDark,
            size: 18,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              'Pickup status changes are validated by the authenticated Laravel Rider API. The mobile app does not advance an assignment locally.',
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 9.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}