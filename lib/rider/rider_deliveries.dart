import 'package:flutter/material.dart';

import 'models/rider_delivery_model.dart';
import 'widgets/rider_ui.dart';

class RiderDeliveries extends StatefulWidget {
  final List<RiderDelivery> orders;

  final ValueChanged<RiderDelivery> onAdvanceDelivery;

  final VoidCallback onOpenWorkflow;
  final VoidCallback onOpenHistory;

  // Kept for compatibility with the current rider_shell.dart.
  final ValueChanged<RiderDelivery> onMarkSuccessful;

  final void Function(
    RiderDelivery order,
    String reason,
  ) onMarkFailed;

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
  State<RiderDeliveries> createState() =>
      _RiderDeliveriesState();
}

class _RiderDeliveriesState
    extends State<RiderDeliveries> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  static const Set<String> _directDeliveryStatuses = {
    // Current Laravel Rider API.
    'in_transit',
    'arrived_buyer',

    // Legacy compatibility.
    'delivery_assigned',
    'delivery_accepted',
    'parcel_released',
    'out_for_delivery',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isDirectDelivery(
    RiderDelivery order,
  ) {
    if (order.isLogisticsPickup) {
      return false;
    }

    return _directDeliveryStatuses.contains(
      order.status,
    );
  }

  int _stage(
    RiderDelivery order,
  ) {
    switch (order.status) {
      case 'delivery_assigned':
      case 'delivery_accepted':
      case 'parcel_released':
      case 'in_transit':
      case 'out_for_delivery':
        return 0;

      case 'arrived_buyer':
        return 1;

      default:
        return -1;
    }
  }

  String _stageLabel(
    RiderDelivery order,
  ) {
    switch (_stage(order)) {
      case 0:
        return 'In Transit';

      case 1:
        return 'At Buyer';

      default:
        return order.statusLabel;
    }
  }

  List<RiderDelivery> get _allDeliveries {
    return widget.orders
        .where(_isDirectDelivery)
        .toList();
  }

  List<RiderDelivery> get _filteredDeliveries {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    return _allDeliveries.where(
      (order) {
        final stage = _stage(order);

        if (_filter == 'In Transit' &&
            stage != 0) {
          return false;
        }

        if (_filter == 'At Buyer' &&
            stage != 1) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final values = [
          order.orderNumber,
          order.packageCode,
          order.buyerName,
          order.buyerAddress,
          order.sellerName,
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

  void _advance(
    RiderDelivery order,
  ) {
    if (order.actionLabel
        .trim()
        .isEmpty) {
      return;
    }

    // This callback is handled by rider_shell.dart,
    // which calls the authenticated Laravel Rider API.
    widget.onAdvanceDelivery(
      order,
    );
  }

  void _openDetails(
    RiderDelivery order,
  ) {
    final bool atBuyer = _stage(order) == 1;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor:
          RiderColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding:
                EdgeInsets.fromLTRB(
              18,
              4,
              18,
              24 +
                  MediaQuery.of(
                    sheetContext,
                  ).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _detailsHeader(
                  order,
                ),

                const SizedBox(
                  height: 20,
                ),

                _detailsSection(
                  icon: Icons
                      .person_outline_rounded,
                  label: 'Buyer',
                  value: order.buyerName
                          .trim()
                          .isNotEmpty
                      ? order.buyerName
                      : 'Buyer',
                ),

                const SizedBox(
                  height: 14,
                ),

                _detailsSection(
                  icon: Icons
                      .location_on_outlined,
                  label:
                      'Delivery Address',
                  value: order
                          .buyerAddress
                          .trim()
                          .isNotEmpty
                      ? order.buyerAddress
                      : 'Buyer address unavailable',
                ),

                if (order.packageCode
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 14,
                  ),
                  _detailsSection(
                    icon: Icons
                        .qr_code_2_rounded,
                    label:
                        'Parcel Code',
                    value:
                        order.packageCode,
                  ),
                ],

                const SizedBox(
                  height: 18,
                ),

                _deliveryNotice(
                  order,
                ),

                const SizedBox(
                  height: 18,
                ),

                _deliveryTimeline(
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
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        _advance(
                          order,
                        );
                      },
                      icon: Icon(
                        _actionIcon(
                          order,
                        ),
                      ),
                      label: Text(
                        atBuyer
                            ? 'Scan & POD'
                            : order
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
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 10,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        widget.onMarkFailed(
                          order,
                          'Rider reported a failed delivery from mobile.',
                        );
                      },
                      icon: const Icon(
                        Icons
                            .report_problem_outlined,
                        size: 17,
                      ),
                      label:
                          const Text(
                        'Report Failed',
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        widget
                            .onReschedule(
                          order,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .event_repeat_rounded,
                        size: 17,
                      ),
                      label:
                          const Text(
                        'Reschedule',
                      ),
                    ),

                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        widget
                            .onReturnToSorting(
                          order,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .keyboard_return_rounded,
                        size: 17,
                      ),
                      label:
                          const Text(
                        'Return',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailsHeader(
    RiderDelivery order,
  ) {
    final atBuyer =
        _stage(order) == 1;

    return Row(
      children: [
        Container(
          width: 47,
          height: 47,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: atBuyer
                ? RiderColors
                    .greenSoft
                : RiderColors
                    .blueSoft,
            borderRadius:
                BorderRadius.circular(
              13,
            ),
          ),
          child: Icon(
            atBuyer
                ? Icons
                    .location_on_rounded
                : Icons
                    .local_shipping_outlined,
            color: atBuyer
                ? RiderColors.green
                : RiderColors.blue,
            size: 23,
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
                order.orderNumber,
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
                height: 3,
              ),

              Text(
                _stageLabel(
                  order,
                ),
                style:
                    TextStyle(
                  color: atBuyer
                      ? RiderColors.green
                      : RiderColors.blue,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailsSection({
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
                CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: .7,
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

  Widget _proofHelpCard() {
    return Container(
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .add_a_photo_outlined,
            color:
                RiderColors.goldDark,
            size: 21,
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
                  'Proof of Delivery',
                  style:
                      TextStyle(
                    color:
                        RiderColors.text,
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'After arriving at the Buyer, tap Scan & POD on the order. '
                  'Verify the parcel QR, take a delivery photo, and upload it. '
                  'The server will then check COD and complete the order.',
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveryNotice(
    RiderDelivery order,
  ) {
    String message;

    if (_stage(order) == 1) {
      message =
          'Arrived at Buyer. Tap Scan & POD below: scan parcel QR, capture a handoff photo, then upload proof before delivery completion.';
    } else {
      message =
          'The parcel is on the way to the Buyer. Confirm arrival only when you have reached the delivery location.';
    }

    return Container(
      width:
          double.infinity,
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
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _actionIcon(
    RiderDelivery order,
  ) {
    switch (order.status) {
      case 'in_transit':
      case 'out_for_delivery':
        return Icons
            .location_on_outlined;

      case 'arrived_buyer':
        return Icons
            .check_circle_outline_rounded;

      default:
        return Icons
            .arrow_forward_rounded;
    }
  }

  Widget _deliveryTimeline(
    int current,
  ) {
    const steps = [
      (
        'In Transit',
        Icons
            .local_shipping_outlined,
      ),
      (
        'At Buyer',
        Icons
            .location_on_outlined,
      ),
      (
        'Delivered',
        Icons
            .check_circle_outline_rounded,
      ),
    ];

    return Column(
      children: List.generate(
        steps.length,
        (index) {
          final reached =
              index <= current;

          final active =
              index == current;

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    alignment:
                        Alignment.center,
                    decoration:
                        BoxDecoration(
                      color: reached
                          ? RiderColors
                              .blue
                          : RiderColors
                              .surfaceSoft,
                      shape:
                          BoxShape.circle,
                      border:
                          Border.all(
                        color: reached
                            ? RiderColors
                                .blue
                            : RiderColors
                                .border,
                      ),
                    ),
                    child: Icon(
                      steps[index].$2,
                      color: reached
                          ? Colors.white
                          : RiderColors
                              .muted,
                      size: 16,
                    ),
                  ),

                  if (index <
                      steps.length - 1)
                    Container(
                      width: 2,
                      height: 30,
                      color: index <
                              current
                          ? RiderColors
                              .blue
                          : RiderColors
                              .border,
                    ),
                ],
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 6,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        steps[index].$1,
                        style:
                            TextStyle(
                          color: reached
                              ? RiderColors
                                  .text
                              : RiderColors
                                  .muted,
                          fontSize: 10,
                          fontWeight:
                              active
                                  ? FontWeight
                                      .w800
                                  : FontWeight
                                      .w600,
                        ),
                      ),

                      if (active) ...[
                        const SizedBox(
                          height: 2,
                        ),

                        Text(
                          'Current stage',
                          style:
                              TextStyle(
                            color:
                                RiderColors
                                    .blue,
                            fontSize: 10,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final all =
        _allDeliveries;

    final inTransit = all
        .where(
          (order) =>
              _stage(order) == 0,
        )
        .length;

    final atBuyer = all
        .where(
          (order) =>
              _stage(order) == 1,
        )
        .length;

    final deliveries =
        _filteredDeliveries;

    return Scaffold(
      backgroundColor:
          RiderColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        backgroundColor:
            RiderColors.surface,
        foregroundColor:
            RiderColors.text,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title:
              'Active Deliveries',
          subtitle:
              'Last-Mile Buyer Delivery',
        ),
        actions: [const RiderHeaderActions()],
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
            total: all.length,
            inTransit:
                inTransit,
            atBuyer:
                atBuyer,
          ),

          const SizedBox(
            height: 24,
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
            total: all.length,
            inTransit:
                inTransit,
            atBuyer:
                atBuyer,
          ),

          const SizedBox(
            height: 16,
          ),

          if (deliveries.isEmpty)
            _emptyState()
          else
            ...deliveries.map(
              (order) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 13,
                ),
                child:
                    _deliveryCard(
                  order,
                ),
              ),
            ),

          const SizedBox(
            height: 8,
          ),

          Text(
            'Showing ${deliveries.length} active '
            '${deliveries.length == 1 ? 'delivery' : 'deliveries'}.',
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 11,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          _proofHelpCard(),
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
              RiderColors.heroGradient,
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
                    .local_shipping_outlined,
                color:
                    Colors.white70,
                size: 17,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'RIDER DELIVERY OPERATIONS',
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
            'Active Deliveries',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 27,
              fontWeight:
                  FontWeight.w900,
              letterSpacing:
                  -.5,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Review assigned deliveries, confirm arrival, and complete each order using Laravel-approved actions.',
            style:
                TextStyle(
              color:
                  Color(
                0xFFE2E9ED,
              ),
              fontSize: 12,
              height: 1.5,
            ),
          ),

        ],
      ),
    );
  }

  Widget _summary({
    required int total,
    required int inTransit,
    required int atBuyer,
  }) {
    return Row(
      children: [
        Expanded(
          child: _stat(
            label:
                'Active',
            value:
                total,
            icon: Icons
                .inventory_2_outlined,
            accent:
                RiderColors.goldDark,
            soft:
                RiderColors.goldSoft,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: _stat(
            label:
                'In Transit',
            value:
                inTransit,
            icon: Icons
                .local_shipping_outlined,
            accent:
                RiderColors.blue,
            soft:
                RiderColors.blueSoft,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: _stat(
            label:
                'At Buyer',
            value:
                atBuyer,
            icon: Icons
                .location_on_outlined,
            accent:
                RiderColors.green,
            soft:
                RiderColors.greenSoft,
          ),
        ),
      ],
    );
  }

  Widget _stat({
    required String label,
    required int value,
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border:
            Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color:
                  soft,
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color:
                  accent,
              size: 19,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            '$value',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 22,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    int count,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color:
                RiderColors.blueSoft,
            borderRadius:
                BorderRadius.circular(
              12,
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
                'Buyer Delivery Queue',
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
                height: 3,
              ),

              Text(
                'Current parcels assigned for Buyer delivery.',
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        _badge(
          '$count',
          RiderColors.blueSoft,
          RiderColors.blue,
        ),
      ],
    );
  }

  Widget _searchBar() {
    return RiderSearchField(
      controller: _searchController,
      hintText: 'Search order, buyer, address...',
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _filters({
    required int total,
    required int inTransit,
    required int atBuyer,
  }) {
    final items =
        <(String, int)>[
      (
        'All',
        total,
      ),
      (
        'In Transit',
        inTransit,
      ),
      (
        'At Buyer',
        atBuyer,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        children: items.map(
          (item) {
            final selected =
                _filter ==
                    item.$1;

            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 7,
              ),
              child:
                  ChoiceChip(
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
                    RiderColors.surface,
                selectedColor:
                    RiderColors.blueSoft,
                side:
                    BorderSide(
                  color: selected
                      ? RiderColors.blue
                      : RiderColors
                          .border,
                ),
                labelStyle:
                    TextStyle(
                  color: selected
                      ? RiderColors.blue
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

  Widget _deliveryCard(
    RiderDelivery order,
  ) {
    final atBuyer =
        _stage(order) == 1;

    final accent = atBuyer
        ? RiderColors.green
        : RiderColors.blue;

    final soft = atBuyer
        ? RiderColors.greenSoft
        : RiderColors.blueSoft;

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
                  CrossAxisAlignment.start,
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
                          fontSize:
                              16,
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

                if (order
                    .sellerName
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    order
                        .sellerName,
                    style:
                        TextStyle(
                      color:
                          RiderColors
                              .muted,
                      fontSize: 10,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 17,
                ),

                _compactTimeline(
                  _stage(order),
                ),

                const SizedBox(
                  height: 18,
                ),

                Divider(
                  color:
                      RiderColors.border,
                ),

                const SizedBox(
                  height: 10,
                ),

                _location(
                  icon:
                      Icons
                          .person_outline_rounded,
                  label:
                      'BUYER',
                  name: order
                          .buyerName
                          .trim()
                          .isNotEmpty
                      ? order
                          .buyerName
                      : 'Buyer',
                  address: order
                          .buyerAddress
                          .trim()
                          .isNotEmpty
                      ? order
                          .buyerAddress
                      : 'Delivery address unavailable',
                  accent:
                      accent,
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
                    name:
                        order.packageCode,
                    address:
                        'Verify this parcel during the required delivery flow.',
                    accent:
                        RiderColors
                            .goldDark,
                  ),
                ],

                const SizedBox(
                  height: 14,
                ),

                _deliveryNotice(
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

                if (order
                    .actionLabel
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
                            accent,
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

  Widget _compactTimeline(
    int current,
  ) {
    const labels = [
      'In Transit',
      'At Buyer',
      'Delivered',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final reached =
              index <= current;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index >
                        0)
                      Expanded(
                        child:
                            Container(
                          height: 2,
                          color: index <=
                                  current
                              ? RiderColors
                                  .blue
                              : RiderColors
                                  .border,
                        ),
                      ),

                    Container(
                      width: 27,
                      height: 27,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: reached
                            ? RiderColors
                                .blue
                            : RiderColors
                                .surfaceSoft,
                        border:
                            Border.all(
                          color: reached
                              ? RiderColors
                                  .blue
                              : RiderColors
                                  .border,
                        ),
                      ),
                      child: reached
                          ? const Icon(
                              Icons
                                  .check_rounded,
                              color:
                                  Colors.white,
                              size: 14,
                            )
                          : Text(
                              '${index + 1}',
                              style:
                                  TextStyle(
                                color:
                                    RiderColors
                                        .muted,
                                fontSize: 11,
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
                                  .blue
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
                    color: index ==
                            current
                        ? RiderColors
                            .blue
                        : RiderColors
                            .muted,
                    fontSize: 10,
                    fontWeight:
                        index ==
                                current
                            ? FontWeight
                                .w800
                            : FontWeight
                                .w500,
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
          color:
              accent,
          size: 22,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    TextStyle(
                  color:
                      accent,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w900,
                  letterSpacing: .7,
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
                  fontSize: 11,
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
        color:
            background,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style:
            TextStyle(
          color:
              foreground,
          fontSize: 10,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width:
          double.infinity,
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
                .local_shipping_outlined,
            color:
                RiderColors.muted,
            size: 45,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            'No active Buyer deliveries',
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
            'Assigned last-mile deliveries will appear here when a parcel is ready for Buyer delivery.',
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

          const SizedBox(
            height: 14,
          ),

          OutlinedButton.icon(
            onPressed:
                widget.onOpenHistory,
            icon:
                const Icon(
              Icons.history_rounded,
            ),
            label:
                const Text(
              'View History',
            ),
          ),
        ],
      ),
    );
  }
}