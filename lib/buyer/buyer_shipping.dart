import 'package:flutter/material.dart';

import '../services/sari_live_data.dart';
import 'buyer_theme.dart';

class BuyerShipping extends StatefulWidget {
  const BuyerShipping({
    super.key,
  });

  @override
  State<BuyerShipping> createState() =>
      _BuyerShippingState();
}

class _BuyerShippingState
    extends State<BuyerShipping> {
  final List<Map<String, dynamic>>
      _shipments =
      <Map<String, dynamic>>[];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _load();
  }

  Map<String, dynamic> _map(
    dynamic value,
  ) {
    return value is Map
        ? Map<String, dynamic>.from(
            value,
          )
        : <String, dynamic>{};
  }

  String _text(
    dynamic value, [
    String fallback = '',
  ]) {
    final String text =
        value?.toString().trim() ?? '';

    return text.isEmpty
        ? fallback
        : text;
  }

  int _integer(
    dynamic value,
  ) {
    return value is num
        ? value.toInt()
        : int.tryParse(
              '$value',
            ) ??
            0;
  }

  String _dateTime(
    dynamic raw,
  ) {
    final String value =
        _text(raw);

    final DateTime? date =
        DateTime.tryParse(
      value,
    )?.toLocal();

    if (date == null) {
      return value;
    }

    const List<String> months =
        <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final int hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final String minute =
        date.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '${months[date.month - 1]} '
        '${date.day} • '
        '$hour:$minute $period';
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _load() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final List<Map<String, dynamic>>
          all =
          <Map<String, dynamic>>[];

      int page = 1;

      while (true) {
        final Map<String, dynamic> response =
            await SariLiveData.instance
                .buyerShipping(
          page: page,
        );

        final dynamic raw =
            response['data'];

        if (raw is List) {
          all.addAll(
            raw.map(_map),
          );
        }

        final Map<String, dynamic> meta =
            _map(
          response['meta'],
        );

        final int lastPage =
            _integer(
          meta['last_page'],
        );

        if (lastPage <= page ||
            lastPage <= 0) {
          break;
        }

        page++;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _shipments
          ..clear()
          ..addAll(all);

        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  // ============================================================
  // TRACKING
  // ============================================================

  Future<void> _openTracking(
    Map<String, dynamic> shipment,
  ) async {
    final int id =
        _integer(
      shipment['id'],
    );

    if (id <= 0) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (
            BuildContext context,
          ) =>
              const Center(
        child:
            CircularProgressIndicator(),
      ),
    );

    try {
      final Map<String, dynamic> response =
          await SariLiveData.instance
              .buyerTracking(id);

      final Map<String, dynamic> data =
          _map(
        response['data'],
      );

      final List<Map<String, dynamic>>
          events =
          data['events'] is List
              ? (data['events']
                      as List)
                  .map(_map)
                  .toList()
              : <Map<String, dynamic>>[];

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor:
            BuyerTheme.canvas,
        builder:
            (
              BuildContext context,
            ) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: .80,
            minChildSize: .50,
            maxChildSize: .95,
            builder:
                (
              BuildContext context,
              ScrollController controller,
            ) {
              return ListView(
                controller: controller,
                padding:
                    const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  35,
                ),
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
                          color:
                              BuyerTheme
                                  .goldPale,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .local_shipping_rounded,
                          color:
                              BuyerTheme
                                  .goldDark,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: <Widget>[
                            Text(
                              _text(
                                data[
                                    'order_number'],
                                'Order Tracking',
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    BuyerTheme
                                        .ink,
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              _text(
                                data[
                                    'status_label'],
                              ),
                              style:
                                  const TextStyle(
                                color:
                                    BuyerTheme
                                        .goldDark,
                                fontSize: 10,
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

                  if (_text(
                    data[
                        'courier_name'],
                  ).isNotEmpty) ...[
                    const SizedBox(
                      height: 18,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(
                        13,
                      ),
                      decoration:
                          BuyerTheme.card(
                        radius: 15,
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons
                                .delivery_dining_rounded,
                            color:
                                BuyerTheme
                                    .goldDark,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: <Widget>[
                                const Text(
                                  'Assigned Rider',
                                  style:
                                      TextStyle(
                                    color:
                                        BuyerTheme
                                            .muted,
                                    fontSize:
                                        8,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  _text(
                                    data[
                                        'courier_name'],
                                  ),
                                  style:
                                      const TextStyle(
                                    color:
                                        BuyerTheme
                                            .ink,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 23,
                  ),

                  const Text(
                    'Tracking Timeline',
                    style: TextStyle(
                      color:
                          BuyerTheme.ink,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (events.isEmpty)
                    Container(
                      padding:
                          const EdgeInsets.all(
                        22,
                      ),
                      decoration:
                          BuyerTheme.card(),
                      child:
                          const Column(
                        children: <Widget>[
                          Icon(
                            Icons
                                .hourglass_empty_rounded,
                            color:
                                BuyerTheme
                                    .muted,
                            size: 38,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'No tracking events yet.',
                            style:
                                TextStyle(
                              color:
                                  BuyerTheme
                                      .muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...List<Widget>.generate(
                      events.length,
                      (
                        int index,
                      ) {
                        final Map<String,
                                dynamic>
                            event =
                            events[index];

                        final bool last =
                            index ==
                                events.length -
                                    1;

                        return _trackingEvent(
                          event,
                          last: last,
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      _show(
        'Unable to load tracking: $error',
      );
    }
  }

  Widget _trackingEvent(
    Map<String, dynamic> event, {
    required bool last,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 31,
              height: 31,
              alignment:
                  Alignment.center,
              decoration:
                  const BoxDecoration(
                color:
                    BuyerTheme
                        .successSoft,
                shape:
                    BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .check_rounded,
                color:
                    BuyerTheme.success,
                size: 17,
              ),
            ),

            if (!last)
              Container(
                width: 2,
                height: 54,
                color:
                    BuyerTheme.border,
              ),
          ],
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              top: 2,
              bottom: 19,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: <Widget>[
                Text(
                  _text(
                    event['title'],
                    _text(
                      event['status'],
                      'Order Update',
                    ),
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.ink,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                if (_text(
                  event['message'],
                ).isNotEmpty) ...[
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    _text(
                      event['message'],
                    ),
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.muted,
                      fontSize: 9.5,
                      height: 1.45,
                    ),
                  ),
                ],

                if (_text(
                  event['created_at'],
                ).isNotEmpty) ...[
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    _dateTime(
                      event['created_at'],
                    ),
                    style:
                        const TextStyle(
                      color:
                          BuyerTheme.muted,
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS DESIGN
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    if (status == 'delivered') {
      return BuyerTheme.success;
    }

    if (status == 'cancelled') {
      return BuyerTheme.danger;
    }

    if (<String>{
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    }.contains(status)) {
      return BuyerTheme.blue;
    }

    return BuyerTheme.goldDark;
  }

  Color _statusBackground(
    String status,
  ) {
    if (status == 'delivered') {
      return BuyerTheme.successSoft;
    }

    if (status == 'cancelled') {
      return const Color(
        0xFFFFECEB,
      );
    }

    if (<String>{
      'courier_accepted',
      'heading_pickup',
      'arrived_pickup',
      'in_transit',
      'arrived_buyer',
    }.contains(status)) {
      return BuyerTheme.blueSoft;
    }

    return BuyerTheme.goldPale;
  }

  double _progress(
    String status,
  ) {
    switch (status) {
      case 'ready_for_pickup':
        return .15;

      case 'courier_accepted':
        return .28;

      case 'heading_pickup':
        return .40;

      case 'arrived_pickup':
        return .50;

      case 'in_transit':
        return .72;

      case 'arrived_buyer':
        return .90;

      case 'delivered':
        return 1;

      default:
        return .08;
    }
  }

  void _show(
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
              SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // SHIPMENT CARD
  // ============================================================

  Widget _shipmentCard(
    Map<String, dynamic> shipment,
  ) {
    final String status =
        _text(
      shipment['status'],
    );

    final String label =
        _text(
      shipment['status_label'],
      status
          .replaceAll('_', ' '),
    );

    final Color color =
        _statusColor(status);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BuyerTheme.card(
        radius: 19,
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 47,
                height: 47,
                alignment:
                    Alignment.center,
                decoration:
                    BoxDecoration(
                  color:
                      _statusBackground(
                    status,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  status == 'delivered'
                      ? Icons
                          .task_alt_rounded
                      : Icons
                          .local_shipping_outlined,
                  color: color,
                  size: 23,
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
                      _text(
                        shipment[
                            'order_number'],
                        'SARI Order',
                      ),
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.ink,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      _text(
                        shipment[
                            'store_name'],
                        'SARI Seller',
                      ),
                      style:
                          const TextStyle(
                        color:
                            BuyerTheme.muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      _statusBackground(
                    status,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  label,
                  style:
                      TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
            child:
                LinearProgressIndicator(
              minHeight: 6,
              value:
                  _progress(status),
              backgroundColor:
                  BuyerTheme.border,
              color: color,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            children: <Widget>[
              Icon(
                Icons
                    .schedule_rounded,
                size: 15,
                color:
                    BuyerTheme.muted,
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  _dateTime(
                    shipment[
                        'updated_at'],
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.muted,
                    fontSize: 9,
                  ),
                ),
              ),

              if (_text(
                shipment[
                    'courier_name'],
              ).isNotEmpty)
                Text(
                  _text(
                    shipment[
                        'courier_name'],
                  ),
                  style:
                      const TextStyle(
                    color:
                        BuyerTheme.ink,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          SizedBox(
            width: double.infinity,
            child:
                OutlinedButton.icon(
              onPressed: () {
                _openTracking(
                  shipment,
                );
              },
              icon:
                  const Icon(
                Icons
                    .route_outlined,
                size: 18,
              ),
              label:
                  const Text(
                'View Tracking',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    final int active =
        _shipments.where(
      (
        Map<String, dynamic>
            item,
      ) =>
          _text(
            item['status'],
          ) !=
          'delivered',
    ).length;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors:
              BuyerTheme.heroGradient,
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
                  'SHIPPING CENTER',
                  style: TextStyle(
                    color:
                        Color(
                      0xFFFFD98A,
                    ),
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing:
                        1.2,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                const Text(
                  'Track every\nparcel journey.',
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 23,
                    height: 1.05,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  '$active active shipment${active == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons
                .local_shipping_rounded,
            color:
                Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          BuyerTheme.canvas,
      appBar: AppBar(
        title:
            const Text(
          'Shipping & Tracking',
          style: TextStyle(
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        color:
            BuyerTheme.gold,
        onRefresh: _load,
        child: _loading
            ? ListView(
                children:
                    const <Widget>[
                  SizedBox(
                    height: 200,
                  ),
                  Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ],
              )
            : _error != null &&
                    _shipments.isEmpty
                ? ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(
                      30,
                    ),
                    children: <Widget>[
                      const SizedBox(
                        height: 70,
                      ),
                      const Icon(
                        Icons
                            .wifi_off_rounded,
                        size: 50,
                        color:
                            BuyerTheme
                                .muted,
                      ),
                      const SizedBox(
                        height: 14,
                      ),
                      Text(
                        _error!,
                        textAlign:
                            TextAlign
                                .center,
                        style:
                            const TextStyle(
                          color:
                              BuyerTheme
                                  .muted,
                        ),
                      ),
                      const SizedBox(
                        height: 17,
                      ),
                      FilledButton.icon(
                        onPressed:
                            _load,
                        icon:
                            const Icon(
                          Icons
                              .refresh_rounded,
                        ),
                        label:
                            const Text(
                          'Retry',
                        ),
                      ),
                    ],
                  )
                : _shipments.isEmpty
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.all(
                          30,
                        ),
                        children:
                            const <Widget>[
                          SizedBox(
                            height: 80,
                          ),
                          Icon(
                            Icons
                                .local_shipping_outlined,
                            size: 60,
                            color:
                                BuyerTheme
                                    .muted,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'No active shipments',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  BuyerTheme
                                      .ink,
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Text(
                            'Orders released for shipping will appear here.',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  BuyerTheme
                                      .muted,
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(
                          14,
                          16,
                          14,
                          30,
                        ),
                        children: <Widget>[
                          _hero(),
                          ..._shipments.map(
                            _shipmentCard,
                          ),
                        ],
                      ),
      ),
    );
  }
}