import 'package:flutter/material.dart';

import 'widgets/rider_ui.dart';

class RiderLastMileBatch {
  final int id;
  final String assignmentCode;
  final String status;

  final String facilityName;
  final String facilityAddress;

  final String deliveryArea;

  final List<RiderLastMileParcel> parcels;

  const RiderLastMileBatch({
    required this.id,
    required this.assignmentCode,
    required this.status,
    required this.facilityName,
    required this.facilityAddress,
    required this.deliveryArea,
    required this.parcels,
  });

  bool get isActive {
    return const {
      'assigned',
      'out_for_delivery',
      'in_transit',
    }.contains(status);
  }

  bool get isCompleted {
    return status == 'completed';
  }

  int get deliveredCount {
    return parcels
        .where(
          (parcel) =>
              parcel.isDelivered,
        )
        .length;
  }

  int get pendingCount {
    return parcels.length -
        deliveredCount;
  }

  String get statusLabel {
    return _lastMileLabel(
      status,
    );
  }
}

class RiderLastMileParcel {
  final int id;

  final String orderNumber;
  final String parcelCode;

  final String buyerName;
  final String buyerAddress;
  final String? buyerPhone;

  final String status;

  const RiderLastMileParcel({
    required this.id,
    required this.orderNumber,
    required this.parcelCode,
    required this.buyerName,
    required this.buyerAddress,
    this.buyerPhone,
    required this.status,
  });

  bool get isDelivered {
    return status == 'delivered' ||
        status == 'completed';
  }

  bool get isActive {
    return !isDelivered;
  }

  String get statusLabel {
    return _lastMileLabel(
      status,
    );
  }
}

String _lastMileLabel(
  String value,
) {
  final cleaned = value
      .trim()
      .replaceAll(
        '_',
        ' ',
      );

  if (cleaned.isEmpty) {
    return 'Unknown';
  }

  return cleaned
      .split(' ')
      .where(
        (part) =>
            part.isNotEmpty,
      )
      .map(
        (part) =>
            '${part[0].toUpperCase()}'
            '${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

class RiderLastMile
    extends StatefulWidget {
  final List<RiderLastMileBatch>
      batches;

  final ValueChanged<
      RiderLastMileParcel>?
      onScanParcel;

  final ValueChanged<
      RiderLastMileParcel>?
      onOpenParcel;

  final VoidCallback?
      onBackToDashboard;

  const RiderLastMile({
    super.key,
    this.batches = const [],
    this.onScanParcel,
    this.onOpenParcel,
    this.onBackToDashboard,
  });

  @override
  State<RiderLastMile>
      createState() =>
          _RiderLastMileState();
}

class _RiderLastMileState
    extends State<RiderLastMile> {
  final TextEditingController
      _searchController =
      TextEditingController();

  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<RiderLastMileBatch>
      get _filteredBatches {
    final query =
        _searchController.text
            .trim()
            .toLowerCase();

    return widget.batches.where(
      (batch) {
        if (_filter == 'Active' &&
            !batch.isActive) {
          return false;
        }

        if (_filter == 'Completed' &&
            !batch.isCompleted) {
          return false;
        }

        if (query.isEmpty) {
          return true;
        }

        final batchValues = [
          batch.assignmentCode,
          batch.facilityName,
          batch.facilityAddress,
          batch.deliveryArea,
          batch.statusLabel,
        ];

        if (batchValues.any(
          (value) => value
              .toLowerCase()
              .contains(query),
        )) {
          return true;
        }

        return batch.parcels.any(
          (parcel) {
            return [
              parcel.orderNumber,
              parcel.parcelCode,
              parcel.buyerName,
              parcel.buyerAddress,
              parcel.buyerPhone ?? '',
              parcel.statusLabel,
            ].any(
              (value) => value
                  .toLowerCase()
                  .contains(query),
            );
          },
        );
      },
    ).toList();
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.green;

      case 'out_for_delivery':
      case 'in_transit':
      case 'arrived_buyer':
        return RiderColors.blue;

      default:
        return RiderColors.goldDark;
    }
  }

  Color _statusBackground(
    String status,
  ) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.greenSoft;

      case 'out_for_delivery':
      case 'in_transit':
      case 'arrived_buyer':
        return RiderColors.blueSoft;

      default:
        return RiderColors.goldSoft;
    }
  }

  void _notice(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  void _scanParcel(
    RiderLastMileParcel parcel,
  ) {
    if (widget.onScanParcel ==
        null) {
      _notice(
        'Parcel scanner is not connected from this screen yet.',
      );

      return;
    }

    widget.onScanParcel!(
      parcel,
    );
  }

  void _openParcel(
    RiderLastMileParcel parcel,
  ) {
    if (widget.onOpenParcel ==
        null) {
      _showParcelDetails(
        parcel,
      );

      return;
    }

    widget.onOpenParcel!(
      parcel,
    );
  }

  void _showParcelDetails(
    RiderLastMileParcel parcel,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor:
          RiderColors.surface,
      builder: (
        sheetContext,
      ) {
        return SafeArea(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              5,
              18,
              26,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: parcel
                                .isDelivered
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
                        parcel.isDelivered
                            ? Icons
                                .task_alt_rounded
                            : Icons
                                .inventory_2_outlined,
                        color: parcel
                                .isDelivered
                            ? RiderColors
                                .green
                            : RiderColors
                                .blue,
                        size: 23,
                      ),
                    ),

                    const SizedBox(
                      width: 11,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            parcel
                                .orderNumber,
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .text,
                              fontSize:
                                  18,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            parcel
                                .statusLabel,
                            style:
                                TextStyle(
                              color:
                                  _statusColor(
                                parcel
                                    .status,
                              ),
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
                  height: 22,
                ),

                _detailRow(
                  icon: Icons
                      .qr_code_2_rounded,
                  label:
                      'PARCEL CODE',
                  value: parcel
                          .parcelCode
                          .trim()
                          .isNotEmpty
                      ? parcel
                          .parcelCode
                      : 'Not available',
                ),

                const SizedBox(
                  height: 15,
                ),

                _detailRow(
                  icon: Icons
                      .person_outline_rounded,
                  label:
                      'BUYER',
                  value: parcel
                          .buyerName
                          .trim()
                          .isNotEmpty
                      ? parcel
                          .buyerName
                      : 'Buyer',
                ),

                const SizedBox(
                  height: 15,
                ),

                _detailRow(
                  icon: Icons
                      .location_on_outlined,
                  label:
                      'DELIVERY ADDRESS',
                  value: parcel
                          .buyerAddress
                          .trim()
                          .isNotEmpty
                      ? parcel
                          .buyerAddress
                      : 'Delivery address unavailable',
                ),

                if (parcel.buyerPhone
                        ?.trim()
                        .isNotEmpty ==
                    true) ...[
                  const SizedBox(
                    height: 15,
                  ),

                  _detailRow(
                    icon: Icons
                        .phone_outlined,
                    label:
                        'CONTACT',
                    value:
                        parcel.buyerPhone!,
                  ),
                ],

                const SizedBox(
                  height: 20,
                ),

                _infoBox(
                  parcel.isDelivered
                      ? 'This parcel is already recorded as delivered in the loaded last-mile batch.'
                      : 'Verify the parcel code before completing the Buyer handoff.',
                ),

                if (!parcel
                    .isDelivered) ...[
                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        _scanParcel(
                          parcel,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .qr_code_scanner_rounded,
                      ),
                      label:
                          const Text(
                        'Scan Parcel QR',
                      ),
                      style:
                          FilledButton.styleFrom(
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
                    height: 9,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          sheetContext,
                        ).pop();

                        _openParcel(
                          parcel,
                        );
                      },
                      icon:
                          const Icon(
                        Icons
                            .local_shipping_outlined,
                      ),
                      label:
                          const Text(
                        'Open Delivery',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final activeBatches =
        widget.batches
            .where(
              (batch) =>
                  batch.isActive,
            )
            .toList();

    final completedBatches =
        widget.batches
            .where(
              (batch) =>
                  batch.isCompleted,
            )
            .length;

    final totalParcels =
        activeBatches.fold<int>(
      0,
      (
        total,
        batch,
      ) =>
          total +
          batch.parcels.length,
    );

    final deliveredParcels =
        widget.batches.fold<int>(
      0,
      (
        total,
        batch,
      ) =>
          total +
          batch.deliveredCount,
    );

    final filtered =
        _filteredBatches;

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
              'Last-Mile Deliveries',
          subtitle:
              'Hub to Buyer Delivery',
        ),
        actions: [
          IconButton(
            tooltip:
                'Dashboard',
            onPressed: widget
                    .onBackToDashboard ??
                () {
                  Navigator.maybePop(
                    context,
                  );
                },
            icon:
                const Icon(
              Icons.home_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color:
            RiderColors.gold,
        onRefresh: () async {
          // Current page receives batch data
          // from the parent/shell.
          setState(() {});
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            36,
          ),
          children: [
            _hero(),

            const SizedBox(
              height: 18,
            ),

            _summary(
              activeBatches:
                  activeBatches.length,
              activeParcels:
                  totalParcels,
              deliveredParcels:
                  deliveredParcels,
              completedBatches:
                  completedBatches,
            ),

            const SizedBox(
              height: 23,
            ),

            _workflowGuide(),

            const SizedBox(
              height: 25,
            ),

            _sectionHeading(),

            const SizedBox(
              height: 14,
            ),

            _searchField(),

            const SizedBox(
              height: 11,
            ),

            _filters(),

            const SizedBox(
              height: 16,
            ),

            if (filtered.isEmpty)
              _emptyState()
            else
              ...filtered.map(
                (batch) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 15,
                  ),
                  child:
                      _batchCard(
                    batch,
                  ),
                ),
              ),

            const SizedBox(
              height: 8,
            ),

            _integrationNotice(),
          ],
        ),
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
                Icons.route_rounded,
                color:
                    Colors.white70,
                size: 18,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                'LAST-MILE OPERATIONS',
                style:
                    TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      1.2,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          const Text(
            'Last-Mile Deliveries',
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 26,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Collect parcels from the destination hub and deliver within your assigned area.',
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          OutlinedButton.icon(
            onPressed: () {
              _notice(
                'Select a parcel below to scan its assigned QR or barcode.',
              );
            },
            icon:
                const Icon(
              Icons
                  .qr_code_scanner_rounded,
              size: 18,
            ),
            label:
                const Text(
              'Scan Assigned Parcel',
            ),
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  Colors.white,
              side:
                  const BorderSide(
                color:
                    Colors.white54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary({
    required int activeBatches,
    required int activeParcels,
    required int deliveredParcels,
    required int completedBatches,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                label:
                    'Active Batches',
                value:
                    '$activeBatches',
                icon: Icons
                    .inventory_2_outlined,
                accent:
                    RiderColors.goldDark,
                soft:
                    RiderColors.goldSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _statCard(
                label:
                    'Active Parcels',
                value:
                    '$activeParcels',
                icon: Icons
                    .local_shipping_outlined,
                accent:
                    RiderColors.blue,
                soft:
                    RiderColors.blueSoft,
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
              child: _statCard(
                label:
                    'Delivered',
                value:
                    '$deliveredParcels',
                icon: Icons
                    .task_alt_rounded,
                accent:
                    RiderColors.green,
                soft:
                    RiderColors.greenSoft,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _statCard(
                label:
                    'Completed Batches',
                value:
                    '$completedBatches',
                icon: Icons
                    .done_all_rounded,
                accent:
                    RiderColors.green,
                soft:
                    RiderColors.greenSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
    required Color soft,
  }) {
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
          17,
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
            width: 36,
            height: 36,
            alignment:
                Alignment.center,
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
            height: 11,
          ),

          Text(
            value,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 23,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            label,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _workflowGuide() {
    final steps = <
        (
          IconData,
          String,
          String,
        )>[
      (
        Icons.hub_outlined,
        'Destination Hub',
        'Collect assigned parcels',
      ),
      (
        Icons.route_outlined,
        'Local Route',
        'Travel to the Buyer',
      ),
      (
        Icons
            .qr_code_scanner_rounded,
        'Buyer Handoff',
        'Verify the parcel',
      ),
    ];

    return Container(
      padding:
          const EdgeInsets.all(
        16,
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
          Text(
            'Delivery Workflow',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 17,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: List.generate(
              steps.length,
              (index) {
                final step =
                    steps[index];

                return Expanded(
                  child: Column(
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
                            13,
                          ),
                        ),
                        child: Icon(
                          step.$1,
                          color:
                              RiderColors
                                  .blue,
                          size: 21,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        step.$2,
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              RiderColors
                                  .text,
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        step.$3,
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              RiderColors
                                  .muted,
                          fontSize: 7.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading() {
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
            Icons
                .delivery_dining_outlined,
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
                'Assigned Last-Mile Batches',
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
                'Parcels grouped by hub and delivery area.',
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
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      controller:
          _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration:
          InputDecoration(
        hintText:
            'Search batch, parcel, buyer...',
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
                      Icons.close_rounded,
                    ),
                  ),
      ),
    );
  }

  Widget _filters() {
    final values = [
      'All',
      'Active',
      'Completed',
    ];

    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,
      child: Row(
        children: values.map(
          (value) {
            final selected =
                _filter == value;

            return Padding(
              padding:
                  const EdgeInsets.only(
                right: 7,
              ),
              child: ChoiceChip(
                label:
                    Text(value),
                selected:
                    selected,
                showCheckmark:
                    false,
                onSelected: (_) {
                  setState(() {
                    _filter =
                        value;
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

  Widget _batchCard(
    RiderLastMileBatch batch,
  ) {
    final color =
        _statusColor(
      batch.status,
    );

    final background =
        _statusBackground(
      batch.status,
    );

    return Container(
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
                      child: Column(
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
                                  RiderColors
                                      .text,
                              fontSize:
                                  16,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            batch
                                .deliveryArea,
                            style:
                                TextStyle(
                              color:
                                  RiderColors
                                      .muted,
                              fontSize:
                                  10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _badge(
                      batch.statusLabel,
                      color,
                      background,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                _detail(
                  icon:
                      Icons.hub_outlined,
                  label:
                      'DESTINATION HUB',
                  value: batch
                          .facilityName
                          .trim()
                          .isNotEmpty
                      ? batch
                          .facilityName
                      : 'Assigned Hub',
                  subtitle: batch
                          .facilityAddress
                          .trim()
                          .isNotEmpty
                      ? batch
                          .facilityAddress
                      : 'Hub address unavailable',
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _miniMetric(
                        label:
                            'Parcels',
                        value:
                            '${batch.parcels.length}',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _miniMetric(
                        label:
                            'Delivered',
                        value:
                            '${batch.deliveredCount}',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: _miniMetric(
                        label:
                            'Pending',
                        value:
                            '${batch.pendingCount}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (batch.parcels
              .isNotEmpty)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                13,
                12,
                13,
                13,
              ),
              color:
                  RiderColors.surfaceSoft,
              child: Column(
                children:
                    batch.parcels.map(
                  (parcel) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child:
                          _parcelCard(
                        parcel,
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _parcelCard(
    RiderLastMileParcel parcel,
  ) {
    final color =
        _statusColor(
      parcel.status,
    );

    final background =
        _statusBackground(
      parcel.status,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          14,
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
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      background,
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Icon(
                  parcel.isDelivered
                      ? Icons
                          .check_circle_outline_rounded
                      : Icons
                          .inventory_2_outlined,
                  color: color,
                  size: 19,
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
                      parcel
                          .orderNumber,
                      style:
                          TextStyle(
                        color:
                            RiderColors
                                .text,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      parcel
                          .buyerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          TextStyle(
                        color:
                            RiderColors
                                .muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              _badge(
                parcel.statusLabel,
                color,
                background,
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Icon(
                Icons
                    .location_on_outlined,
                color:
                    RiderColors.muted,
                size: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  parcel.buyerAddress
                          .trim()
                          .isNotEmpty
                      ? parcel
                          .buyerAddress
                      : 'Delivery address unavailable',
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 8.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          if (!parcel
              .isDelivered) ...[
            const SizedBox(
              height: 11,
            ),

            Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () =>
                        _scanParcel(
                      parcel,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .qr_code_scanner_rounded,
                      size: 16,
                    ),
                    label:
                        const Text(
                      'Scan',
                    ),
                  ),
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child:
                      FilledButton.icon(
                    onPressed: () =>
                        _openParcel(
                      parcel,
                    ),
                    icon:
                        const Icon(
                      Icons
                          .arrow_forward_rounded,
                      size: 16,
                    ),
                    label:
                        const Text(
                      'Delivery',
                    ),
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          RiderColors.blue,
                      foregroundColor:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(
              height: 10,
            ),
            _infoBox(
              'Delivery recorded for this parcel.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color:
              RiderColors.blue,
          size: 21,
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
                      RiderColors.muted,
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w900,
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
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                subtitle,
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

  Widget _detailRow({
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
                label,
                style:
                    TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 8,
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
                  fontWeight:
                      FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniMetric({
    required String label,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surfaceSoft,
        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 14,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            label,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(
    String label,
    Color foreground,
    Color background,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
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
        label,
        maxLines: 1,
        overflow:
            TextOverflow.ellipsis,
        style:
            TextStyle(
          color: foreground,
          fontSize: 7.5,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  Widget _infoBox(
    String message,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.blueSoft,
        borderRadius:
            BorderRadius.circular(
          11,
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
            size: 17,
          ),
          const SizedBox(
            width: 7,
          ),
          Expanded(
            child: Text(
              message,
              style:
                  TextStyle(
                color:
                    RiderColors.text,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 40,
      ),
      decoration:
          BoxDecoration(
        color:
            RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
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
            size: 44,
            color:
                RiderColors.muted,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            'No Last-Mile Batches',
            style:
                TextStyle(
              color:
                  RiderColors.text,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            'Hub-assigned delivery batches will appear here when they are loaded for this Rider.',
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
        ],
      ),
    );
  }

  Widget _integrationNotice() {
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
                .info_outline_rounded,
            color:
                RiderColors.goldDark,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              'This screen currently uses last-mile batch data supplied by the Rider shell. QR scanning is local until an authenticated Laravel mobile last-mile endpoint is exposed.',
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