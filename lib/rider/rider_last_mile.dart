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
    return const <String>{
      'assigned',
      'out_for_delivery',
      'in_transit',
    }.contains(status);
  }

  bool get isCompleted {
    return status == 'completed';
  }

  int get deliveredCount {
    return parcels.where(
      (RiderLastMileParcel parcel) {
        return parcel.isDelivered;
      },
    ).length;
  }

  int get pendingCount {
    return parcels.length - deliveredCount;
  }

  String get statusLabel {
    return _statusLabel(status);
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

  bool get isActive => !isDelivered;

  String get statusLabel {
    return _statusLabel(status);
  }
}

String _statusLabel(String value) {
  final String cleaned = value
      .replaceAll('_', ' ')
      .trim();

  if (cleaned.isEmpty) {
    return 'Unknown';
  }

  return cleaned
      .split(' ')
      .where(
        (String part) => part.isNotEmpty,
      )
      .map(
        (String part) =>
            '${part[0].toUpperCase()}'
            '${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

class RiderLastMile extends StatefulWidget {
  const RiderLastMile({
    super.key,
    this.batches = const <RiderLastMileBatch>[],
    this.onScanParcel,
    this.onOpenParcel,
    this.onBackToDashboard,
  });

  final List<RiderLastMileBatch> batches;

  final ValueChanged<RiderLastMileParcel>?
      onScanParcel;

  final ValueChanged<RiderLastMileParcel>?
      onOpenParcel;

  final VoidCallback? onBackToDashboard;

  @override
  State<RiderLastMile> createState() =>
      _RiderLastMileState();
}

class _RiderLastMileState
    extends State<RiderLastMile> {
  final TextEditingController _searchController =
      TextEditingController();

  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<RiderLastMileBatch> get _filtered {
    final String query =
        _searchController.text
            .trim()
            .toLowerCase();

    return widget.batches.where(
      (RiderLastMileBatch batch) {
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

        final bool batchMatches =
            <String>[
          batch.assignmentCode,
          batch.facilityName,
          batch.facilityAddress,
          batch.deliveryArea,
          batch.statusLabel,
        ].any(
          (String value) {
            return value
                .toLowerCase()
                .contains(query);
          },
        );

        if (batchMatches) {
          return true;
        }

        return batch.parcels.any(
          (RiderLastMileParcel parcel) {
            return <String>[
              parcel.orderNumber,
              parcel.parcelCode,
              parcel.buyerName,
              parcel.buyerAddress,
              parcel.buyerPhone ?? '',
              parcel.statusLabel,
            ].any(
              (String value) {
                return value
                    .toLowerCase()
                    .contains(query);
              },
            );
          },
        );
      },
    ).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.green;

      case 'arrived_buyer':
      case 'out_for_delivery':
      case 'in_transit':
        return RiderColors.blue;

      default:
        return RiderColors.goldDark;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return RiderColors.greenSoft;

      case 'arrived_buyer':
      case 'out_for_delivery':
      case 'in_transit':
        return RiderColors.blueSoft;

      default:
        return RiderColors.goldSoft;
    }
  }

  void _continueParcel(
    RiderLastMileParcel parcel,
  ) {
    if (widget.onOpenParcel != null) {
      widget.onOpenParcel!(parcel);
      return;
    }

    _showDetails(parcel);
  }

  void _scanParcel(
    RiderLastMileParcel parcel,
  ) {
    if (widget.onScanParcel != null) {
      widget.onScanParcel!(parcel);
      return;
    }

    _showDetails(parcel);
  }

  void _showDetails(
    RiderLastMileParcel parcel,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: RiderColors.surface,
      builder: (
        BuildContext sheetContext,
      ) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      alignment:
                          Alignment.center,
                      decoration:
                          BoxDecoration(
                        color: _statusBackground(
                          parcel.status,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                      child: Icon(
                        parcel.isDelivered
                            ? Icons
                                .task_alt_rounded
                            : Icons
                                .inventory_2_outlined,
                        color: _statusColor(
                          parcel.status,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            parcel.orderNumber,
                            style: TextStyle(
                              color:
                                  RiderColors.text,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            parcel.statusLabel,
                            style: TextStyle(
                              color: _statusColor(
                                parcel.status,
                              ),
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w700,
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

                _detail(
                  icon:
                      Icons.qr_code_2_rounded,
                  label: 'PARCEL CODE',
                  value: parcel.parcelCode
                          .trim()
                          .isEmpty
                      ? 'Not available'
                      : parcel.parcelCode,
                ),

                const SizedBox(
                  height: 15,
                ),

                _detail(
                  icon: Icons
                      .person_outline_rounded,
                  label: 'BUYER',
                  value: parcel.buyerName,
                ),

                const SizedBox(
                  height: 15,
                ),

                _detail(
                  icon: Icons
                      .location_on_outlined,
                  label:
                      'DELIVERY ADDRESS',
                  value: parcel
                          .buyerAddress
                          .trim()
                          .isEmpty
                      ? 'Address unavailable'
                      : parcel.buyerAddress,
                ),

                if (parcel.buyerPhone
                        ?.trim()
                        .isNotEmpty ==
                    true) ...<Widget>[
                  const SizedBox(
                    height: 15,
                  ),
                  _detail(
                    icon:
                        Icons.phone_outlined,
                    label: 'CONTACT',
                    value:
                        parcel.buyerPhone!,
                  ),
                ],

                const SizedBox(
                  height: 22,
                ),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        RiderColors.blueSoft,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons
                            .info_outline_rounded,
                        color:
                            RiderColors.blue,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 9,
                      ),
                      Expanded(
                        child: Text(
                          parcel.isDelivered
                              ? 'This parcel has already been recorded as delivered in Laravel.'
                              : 'The next action will be checked against the latest Laravel status before changing anything.',
                          style: TextStyle(
                            color:
                                RiderColors.text,
                            fontSize: 10,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!parcel.isDelivered) ...<Widget>[
                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child:
                        FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _continueParcel(
                          parcel,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .local_shipping_outlined,
                      ),
                      label: const Text(
                        'Continue Delivery',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        _scanParcel(
                          parcel,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .qr_code_scanner_rounded,
                      ),
                      label: const Text(
                        'Scan Parcel',
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

  Widget _detail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color: RiderColors.bg,
            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color:
                RiderColors.goldDark,
          ),
        ),

        const SizedBox(
          width: 11,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 8,
                  letterSpacing: .8,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                value,
                style: TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 12,
                  height: 1.4,
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

  @override
  Widget build(BuildContext context) {
    final List<RiderLastMileBatch>
        active = widget.batches
            .where(
              (RiderLastMileBatch batch) =>
                  batch.isActive,
            )
            .toList();

    final int totalParcels =
        widget.batches.fold<int>(
      0,
      (
        int total,
        RiderLastMileBatch batch,
      ) =>
          total +
          batch.parcels.length,
    );

    final int delivered =
        widget.batches.fold<int>(
      0,
      (
        int total,
        RiderLastMileBatch batch,
      ) =>
          total +
          batch.deliveredCount,
    );

    final List<RiderLastMileBatch>
        filtered = _filtered;

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
        titleSpacing: 16,
        title:
            const RiderHeaderTitle(
          title:
              'Last-Mile Deliveries',
          subtitle:
              'Hub to Buyer workflow',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Dashboard',
            onPressed: widget
                    .onBackToDashboard ??
                () {
                  Navigator.maybePop(
                    context,
                  );
                },
            icon: const Icon(
              Icons.home_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          34,
        ),
        children: <Widget>[
          _hero(),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: <Widget>[
              Expanded(
                child: _metric(
                  icon:
                      Icons.route_rounded,
                  value:
                      '${active.length}',
                  label:
                      'Active Routes',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _metric(
                  icon: Icons
                      .inventory_2_outlined,
                  value:
                      '$totalParcels',
                  label: 'Parcels',
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _metric(
                  icon:
                      Icons.task_alt_rounded,
                  value: '$delivered',
                  label: 'Delivered',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 23,
          ),

          Text(
            'Delivery Workflow',
            style: TextStyle(
              color: RiderColors.text,
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Container(
            padding:
                const EdgeInsets.all(15),
            decoration:
                BoxDecoration(
              color: RiderColors.surface,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color:
                    RiderColors.border,
              ),
            ),
            child: Column(
              children: <Widget>[
                _flowStep(
                  '1',
                  'Start route',
                  'The batch starts through Laravel.',
                ),
                _connector(),
                _flowStep(
                  '2',
                  'Arrive at Buyer',
                  'Arrival is saved to the shared backend.',
                ),
                _connector(),
                _flowStep(
                  '3',
                  'Scan parcel',
                  'The QR is verified against the assigned order.',
                ),
                _connector(),
                _flowStep(
                  '4',
                  'Proof + COD',
                  'Upload proof and confirm cash only when required.',
                ),
                _connector(),
                _flowStep(
                  '5',
                  'Complete delivery',
                  'Web and mobile read the same final status.',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Assigned Batches',
                  style: TextStyle(
                    color:
                        RiderColors.text,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${filtered.length}',
                style: TextStyle(
                  color:
                      RiderColors.muted,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          TextField(
            controller:
                _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration:
                InputDecoration(
              hintText:
                  'Search order, Buyer, area...',
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
                            setState(() {});
                          },
                          icon:
                              const Icon(
                            Icons
                                .close_rounded,
                          ),
                        ),
              filled: true,
              fillColor:
                  RiderColors.surface,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide(
                  color:
                      RiderColors.border,
                ),
              ),
              enabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide(
                  color:
                      RiderColors.border,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Wrap(
            spacing: 8,
            children: <String>[
              'All',
              'Active',
              'Completed',
            ].map(
              (String value) {
                return ChoiceChip(
                  label: Text(value),
                  selected:
                      _filter == value,
                  onSelected: (_) {
                    setState(() {
                      _filter = value;
                    });
                  },
                );
              },
            ).toList(),
          ),

          const SizedBox(
            height: 16,
          ),

          if (filtered.isEmpty)
            _empty()
          else
            ...filtered.map(
              (RiderLastMileBatch batch) {
                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: _batchCard(
                    batch,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors:
              RiderColors.heroGradient,
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          23,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'LAST MILE',
                  style: TextStyle(
                    color:
                        Color(0xFFEBC867),
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                const Text(
                  'Deliver with confidence',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  'Every action is synced through the SARI Laravel backend.',
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(.72),
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Container(
            width: 62,
            height: 62,
            alignment:
                Alignment.center,
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(
                19,
              ),
            ),
            child: const Icon(
              Icons
                  .delivery_dining_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration:
          BoxDecoration(
        color: RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color:
                RiderColors.goldDark,
            size: 19,
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  RiderColors.text,
              fontSize: 18,
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
            style: TextStyle(
              color:
                  RiderColors.muted,
              fontSize: 8,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowStep(
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 30,
          height: 30,
          alignment:
              Alignment.center,
          decoration:
              BoxDecoration(
            color:
                RiderColors.goldSoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color:
                  RiderColors.goldDark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color:
                      RiderColors.text,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                description,
                style: TextStyle(
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

  Widget _connector() {
    return Container(
      margin:
          const EdgeInsets.only(
        left: 14,
      ),
      width: 1,
      height: 13,
      color: RiderColors.border,
    );
  }

  Widget _batchCard(
    RiderLastMileBatch batch,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        color: RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              RiderColors.border,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black
                .withOpacity(.035),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 45,
                  height: 45,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        _statusBackground(
                      batch.status,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .route_rounded,
                    color: _statusColor(
                      batch.status,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        batch.assignmentCode,
                        style: TextStyle(
                          color:
                              RiderColors.text,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        batch.facilityName,
                        style: TextStyle(
                          color:
                              RiderColors.muted,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      if (batch.deliveryArea
                          .trim()
                          .isNotEmpty) ...<Widget>[
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          batch.deliveryArea,
                          style: TextStyle(
                            color:
                                RiderColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        _statusBackground(
                      batch.status,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    batch.statusLabel,
                    style: TextStyle(
                      color:
                          _statusColor(
                        batch.status,
                      ),
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color:
                RiderColors.border,
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              13,
              16,
              13,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  '${batch.deliveredCount}/${batch.parcels.length} delivered',
                  style: TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${batch.pendingCount} remaining',
                  style: TextStyle(
                    color:
                        RiderColors.goldDark,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (batch.parcels.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              child: Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  13,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      RiderColors.bg,
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Text(
                  'Parcel details are not available yet. Refresh the assignment from the server.',
                  style: TextStyle(
                    color:
                        RiderColors.muted,
                    fontSize: 9,
                  ),
                ),
              ),
            )
          else
            ...batch.parcels.map(
              (RiderLastMileParcel parcel) {
                return _parcelTile(
                  parcel,
                );
              },
            ),

          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _parcelTile(
    RiderLastMileParcel parcel,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _continueParcel(parcel);
        },
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            11,
            16,
            11,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      _statusBackground(
                    parcel.status,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  parcel.isDelivered
                      ? Icons
                          .check_rounded
                      : Icons
                          .inventory_2_outlined,
                  color: _statusColor(
                    parcel.status,
                  ),
                  size: 19,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      parcel.orderNumber,
                      style: TextStyle(
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
                      parcel.buyerName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            RiderColors.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                parcel.statusLabel,
                style: TextStyle(
                  color: _statusColor(
                    parcel.status,
                  ),
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Icon(
                Icons
                    .chevron_right_rounded,
                color:
                    RiderColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 24,
      ),
      decoration:
          BoxDecoration(
        color: RiderColors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              RiderColors.border,
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons
                .local_shipping_outlined,
            size: 42,
            color:
                RiderColors.muted,
          ),
          const SizedBox(
            height: 13,
          ),
          Text(
            'No last-mile assignments',
            style: TextStyle(
              color:
                  RiderColors.text,
              fontSize: 15,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'New batches released by the destination hub will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
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
}